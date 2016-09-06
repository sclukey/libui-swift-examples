import PackageDescription

let package = Package(
    name: "swift-ui-examples",
	dependencies: [
		.Package(url: "https://github.com/sclukey/libui-swift.git", majorVersion:1),
	]
)
