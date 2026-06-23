//
//  main.swift
//  Reynard
//
//  Created by Minh Ton on 1/2/26.
//

import Foundation
import GeckoView
import UIKit
import Darwin

@available(iOS, introduced: 13.0, obsoleted: 14.0)
private func configureUnsandboxedAppDataDirectories() {
    guard let cachesDirectory = FileManager.default.urls(
        for: .cachesDirectory,
        in: .userDomainMask
    ).first else {
        return
    }
    
    guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
        return
    }
    
    let appDataDirectory = cachesDirectory
        .appendingPathComponent(bundleIdentifier, isDirectory: true)
        .appendingPathComponent(".mozilla", isDirectory: true)
        .appendingPathComponent("firefox", isDirectory: true)
    
    do {
        try FileManager.default.createDirectory(
            at: appDataDirectory,
            withIntermediateDirectories: true
        )
    } catch {
        return
    }
    
    setenv("MOZ_APP_DATA", appDataDirectory.path, 1)
    setenv("MOZ_LOCAL_APP_DATA", appDataDirectory.path, 1)
}

UserDataMigration.shared.run()
JITController.shared.start()
if #unavailable(iOS 14.0),
   getEntitlementValue("com.apple.private.security.no-sandbox") {
    configureUnsandboxedAppDataDirectories()
}
GeckoEventDispatcherWrapper.setPreference(
    name: "intl.accept_languages",
    type: "string",
    value: "zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7"
)
GeckoRuntime.main(argc: CommandLine.argc, argv: CommandLine.unsafeArgv)
