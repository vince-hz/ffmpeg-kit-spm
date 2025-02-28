// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1.2.8"

let frameworks = ["ffmpegkit": "b03ed9c192668b690f016523c12f60901e652bdd48f203420818b4ce3506c16f", "libavcodec": "8e1e54a639af605987e2638c610f4c79a4f0a0ddcb76ac7060c33834b840a1cc", "libavdevice": "a066c273d31e973510ae223fbda5917afcb1c355a5f4dd1b1df43f44f7033872", "libavfilter": "d90fc131bd84c3832952d5aae92c3786029826afeea435d926f5ed59efcfdd2e", "libavformat": "34630de7fb26cfa53e72de19924c969dc66c696e4ea1d978a2c1a238601a5643", "libavutil": "eec1f5445b4854fc779fc3d8f0b296c3bae2fb1d322d9aefba2f7a5ea1260dbf", "libswresample": "3465a621e4ea6c9b2faa82e916eee4d374a2039c97eac5da480ebcb32a27dccc", "libswscale": "df28adb6d9e24e443b2fee0d2bd1a5ac2864fcc3bf884c9c8aea0a1ca57d2678"]

func xcframework(_ package: Dictionary<String, String>.Element) -> Target {
    let url = "https://github.com/vince-hz/ffmpeg-kit-spm/releases/download/\(release)/\(package.key).xcframework.zip"
    return .binaryTarget(name: package.key, url: url, checksum: package.value)
}

let linkerSettings: [LinkerSetting] = [
    .linkedFramework("AudioToolbox", .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS])),
    .linkedFramework("AVFoundation", .when(platforms: [.macOS, .iOS, .macCatalyst])),
    .linkedFramework("CoreMedia", .when(platforms: [.macOS])),
    .linkedFramework("OpenGL", .when(platforms: [.macOS])),
    .linkedFramework("VideoToolbox", .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS])),
    .linkedLibrary("z"),
    .linkedLibrary("lzma"),
    .linkedLibrary("bz2"),
    .linkedLibrary("iconv")
]

let libAVFrameworks = frameworks.filter({ $0.key != "ffmpegkit" })

let package = Package(
    name: "ffmpeg-kit-spm",
    platforms: [.iOS(.v12), .macOS(.v10_15), .tvOS(.v11), .watchOS(.v7)],
    products: [
        .library(
            name: "FFmpeg-Kit",
            type: .dynamic,
            targets: ["FFmpeg-Kit", "ffmpegkit"]),
        .library(
            name: "FFmpeg",
            type: .dynamic,
            targets: ["FFmpeg"] + libAVFrameworks.map { $0.key }),
    ] + libAVFrameworks.map { .library(name: $0.key, targets: [$0.key]) },
    dependencies: [],
    targets: [
        .target(
            name: "FFmpeg-Kit",
            dependencies: frameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings),
        .target(
            name: "FFmpeg",
            dependencies: libAVFrameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings),
    ] + frameworks.map { xcframework($0) }
)
