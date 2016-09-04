import PackageDescription

let package = Package(
    name: "swift-ui-examples",
	dependencies: [
		.Package(url: "../ui", Version(0,3,1)),
	]
)
