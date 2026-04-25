// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "snap_toast_flutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "snap-toast-flutter", targets: ["snap_toast_flutter"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "snap_toast_flutter",
            dependencies: []
        )
    ]
)
