# libui-swift-examples

These are examples programs for using [libui-swift](https://github.com/sclukey/libui-swift).

## Swift Version

This package is tested with Swift 3, earlier versions of Swift will be ignored completely.

## Compiling

You need to have a compiled version of libui. You can either [download the supported release](https://github.com/andlabs/libui/releases/tag/alpha3.1) or compile libui yourself. See [libui-swift's README](https://github.com/sclukey/libui-swift/blob/master/README.md#usage) for more info.

To compile you need to provide Swift the location of the the compiled libui library and the `ui.h` header file. Assuming you extracted the libui release package to `/path/to/libui`, you are on 64-bit Linux, and you want a static build, then you would need to use

```
swift build -Xswiftc -I/path/to/libui/src -Xlinker -L/path/to/libui/linux_amd64/static
```
