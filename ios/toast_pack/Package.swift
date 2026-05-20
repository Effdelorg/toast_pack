// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "toast_pack",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "toast-pack", targets: ["toast_pack"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "toast_pack",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/toast_pack"
        )
    ]
)
