// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

//
//  Package.swift
//  RestfulPropertyKit
//
//  Created by David Greven on 25.04.21.
//  Copyright (c) 2021 David Greven. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import PackageDescription

let package = Package(
    name: "RestfulPropertyKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "RestfulPropertyKit",
            targets: ["RestfulPropertyKit"])
    ],
    targets: [
        .target(
            name: "RestfulPropertyKit",
            dependencies: []),
        .testTarget(
            name: "RestfulPropertyKitTests",
            dependencies: ["RestfulPropertyKit"])
    ]
)
