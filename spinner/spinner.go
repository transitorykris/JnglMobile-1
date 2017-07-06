package spinner

import (
	"encoding/binary"
	"fmt"

	"upspin.io/client"
	"upspin.io/config"
	"upspin.io/factotum"
	"upspin.io/key/proquint"
	"upspin.io/log"
	"upspin.io/pack/ee"
	"upspin.io/upspin"
	"upspin.io/user"
)

// User is returned after the keys are regenerated
type User struct {
	Public  string
	Private string
	Error   string
}

// Below is from:
// https://github.com/upspin/upspin/blob/master/cmd/upspin/keygen.go
func validSecretSeed(seed string) bool {
	return len(seed) == 47 && seed[5] == '-'
}

// Keygen will generate our key for the first time
func Keygen(secretStr string) (*User, error) {
	// Because obj-c and golang and.. oh man..
	var user User

	// Our secret
	b := make([]byte, 16)

	// P256 because that's default in upspin
	curveName := "p256"

	if !validSecretSeed(secretStr) {
		return nil, fmt.Errorf("Invalid seed")
	}
	for i := 0; i < 8; i++ {
		binary.BigEndian.PutUint16(b[2*i:2*i+2], proquint.Decode([]byte((secretStr)[6*i:6*i+5])))
	}

	// Regenerate our keys
	public, private, err := ee.CreateKeys(curveName, b)
	if err != nil {
		return nil, err
	}
	user.Public = string(public)
	user.Private = private

	return &user, nil
}

// Below is from:
// https://github.com/upspin/upspin/blob/master/exp/client/gobind/gobind.go

// DirEntry represents the most relevant pieces of an upspin.DirEntry for clients.
type DirEntry struct {
	Name         string
	IsDir        bool
	Size         int64
	LastModified int64
	Writer       string
	Next         *DirEntry
}

// ClientConfig is a setup data structure that configures the Client
// for a given user with keys and server endpoints.
type ClientConfig struct {
	// UserName is the upspin.UserName.
	UserName string

	// PublicKey is the user's upspin.PublicKey.
	PublicKey string

	// PrivateKey is the user's private key.
	PrivateKey string

	// KeyNetAddr is the upspin.NetAddr of an upspin.Remote KeyServer endpoint.
	KeyNetAddr string

	// StoreNetAddr is the upspin.NetAddr of an upspin.Remote StoreServer endpoint.
	StoreNetAddr string

	// DirNetAddr is the upspin.NetAddr of an upspin.Remote DirServer endpoint.
	DirNetAddr string
}

// NewClientConfig returns a new ClientConfig.
func NewClientConfig() *ClientConfig {
	return new(ClientConfig)
}

// Client is a wrapped upspin.Client.
type Client struct {
	c upspin.Client
}

// Glob returns a linked list of DirEntry listing the results of the Glob operation.
func (c *Client) Glob(pattern string) (*DirEntry, error) {
	des, err := c.c.Glob(pattern)
	if err != nil {
		return nil, err
	}
	var first *DirEntry
	var last *DirEntry
	for _, de := range des {
		size, err := de.Size()
		if err != nil {
			return nil, err
		}
		dirEntry := &DirEntry{
			Name:         string(de.Name),
			IsDir:        de.IsDir(),
			Size:         size,
			LastModified: int64(de.Time),
			Writer:       string(de.Writer),
		}
		if last != nil {
			last.Next = dirEntry
		} else {
			first = dirEntry
		}
		last = dirEntry
	}
	return first, nil
}

// Get returns the contents of a path.
func (c *Client) Get(path string) ([]byte, error) {
	return c.c.Get(upspin.PathName(path))
}

// Put puts the data as the contents of name and returns its reference in the default location (at the default store).
func (c *Client) Put(name string, data []byte) (string, error) {
	entry, err := c.c.Put(upspin.PathName(name), data)
	if err != nil {
		return "", err
	}
	if len(entry.Blocks) == 0 {
		return "<empty>", nil
	}
	return string(entry.Blocks[0].Location.Reference), nil // TODO: This should include all blocks.
}

// NewClient returns a new Client for a given user's configuration.
func NewClient(clientConfig *ClientConfig) (*Client, error) {
	userName, err := user.Clean(upspin.UserName(clientConfig.UserName))
	if err != nil {
		return nil, err
	}
	cfg := config.New()
	cfg = config.SetUserName(cfg, userName)
	cfg = config.SetPacking(cfg, upspin.EEPack)
	f, err := factotum.NewFromKeys([]byte(clientConfig.PublicKey), []byte(clientConfig.PrivateKey), nil)
	if err != nil {
		log.Error.Printf("Error creating factotum: %s", err)
		return nil, err
	}
	cfg = config.SetFactotum(cfg, f)
	se := upspin.Endpoint{
		Transport: upspin.Remote,
		NetAddr:   upspin.NetAddr(clientConfig.StoreNetAddr),
	}
	cfg = config.SetStoreEndpoint(cfg, se)
	de := upspin.Endpoint{
		Transport: upspin.Remote,
		NetAddr:   upspin.NetAddr(clientConfig.DirNetAddr),
	}
	cfg = config.SetDirEndpoint(cfg, de)
	ue := upspin.Endpoint{
		Transport: upspin.Remote,
		NetAddr:   upspin.NetAddr(clientConfig.KeyNetAddr),
	}
	cfg = config.SetKeyEndpoint(cfg, ue)
	return &Client{
		c: client.New(cfg),
	}, nil
}
