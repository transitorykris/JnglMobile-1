# Jngl Mobile

This is a work in progress. It is not suitable for use in production and is likely to be broken at various times.

The code is published here for auditing.

## Goals for this project:

* Manage Upspin identities on iOS
* Provide read and write access to files and directories in Upspin
* Mediate between non-Upspin enabled apps and Upspin

## Is this in the App store?

Not yet. The file provider extension is in iOS 11 which is expected to be released in the fall.

If you're willing to experiment and you're willing to run iOS 11 beta, reach out at hello@jngl.co about getting added
to the beta.

## Screenshots

![Settings screenshot](https://github.com/jnglco/JnglMobile/blob/master/assets/settings.png)
![Browsing screenshot](https://github.com/jnglco/JnglMobile/blob/master/assets/browsing.png)
![Viewing screenshot](https://github.com/jnglco/JnglMobile/blob/master/assets/augie.png)
![Sharing screenshot](https://github.com/jnglco/JnglMobile/blob/master/assets/sharing.png)

## Progress

### What's working

* Recreate accounts using proquints
* Browse the user's directory using the Files app
* Open files
* Create new directories
* Save files from other apps using the share button (upload goes to root directory, UI partially implemented)

### What's not implemented (yet!)

* Updating files
* Deleting files, symlinks, and directories
* Create new files
* Editor for Access and Group files
* Working with other user's directories
* Following symlinks
* File Provider's working sets (favorites, tagged file, etc)

### Rough edges

* If the user has not configured their upspin account using the app, the file extension will crash
* State is not tracked yet, so multiple Upspin globs will hit the server as directories are browsed
* Files are always downloaded even if the remote has not changed
* Cannot create new directories in the user's root directory
* No tests.. yet..
* Multiple uploads could saturate the network, scheduling needed

### Future

* Multiple user accounts
* Private key generation using Secure Enclave
* Account configuration using QR codes

## Notes

* Running in the simulator you may need to set `settings set plugin.os.goroutines.enable false`
in `~/.lldbinit` if you experience LLDB crashes see [https://github.com/golang/go/issues/19846](https://github.com/golang/go/issues/19846)
* Building this for yourself will likely fail as-is. There are some hardcoded values in the project that rely on
`co.aheadbyacentury.JnglMobile` that you'll need to modify to suit your development team.

## License

```
Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
```
