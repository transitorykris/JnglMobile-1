# Jngl Mobile

This is a work in progress. It is not suitable for use in production and is likely to be broken at various times.

The code is published here for auditing.

## Goals for this project:

* Manage Upspin identities on iOS
* Provide read and write access to files and directories in Upspin
* Mediate between non-Upspin enabled apps and Upspin

## Notes

* Running in the simulator you may need to set `settings set plugin.os.goroutines.enable false` in `~/.lldbinit` if you experience LLDB crashes see [https://github.com/golang/go/issues/19846](https://github.com/golang/go/issues/19846)

## License

```
Copyright © 2017 Ahead by a Century, LLC. All rights reserved.
```
