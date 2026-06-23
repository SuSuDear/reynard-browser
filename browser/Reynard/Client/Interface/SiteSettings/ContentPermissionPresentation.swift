//
//  ContentPermissionPresentation.swift
//  Reynard
//
//  Created by Minh Ton on 16/6/26.
//

import GeckoView
import Foundation

extension ContentPermission {
    var alertTitle: String? {
        let host = Self.permissionHost(from: uri)
        switch permission {
        case .geolocation:
            return L10n.string("permission_prompt.location", host)
        case .desktopNotification:
            return L10n.string("permission_prompt.notifications", host)
        case .persistentStorage:
            return L10n.string("permission_prompt.persistent_storage", host)
        case .mediaKeySystemAccess:
            return L10n.string("permission_prompt.drm", host)
        case .storageAccess:
            return L10n.string("permission_prompt.storage_access", Self.permissionHost(from: thirdPartyOrigin), host)
        case .localDeviceAccess:
            return L10n.string("permission_prompt.local_device", host)
        case .localNetworkAccess:
            return L10n.string("permission_prompt.local_network", host)
        case .deviceSensors:
            return L10n.string("permission_prompt.device_sensors", host)
        case .camera,
                .microphone,
                .webxr,
                .autoplay,
                .tracking,
            nil:
            return nil
        }
    }
    
    var alertMessage: String? {
        switch permission {
        case .storageAccess:
            return L10n.string("permission_prompt.storage_access_message", Self.permissionHost(from: thirdPartyOrigin))
        case .camera,
                .microphone,
                .geolocation,
                .desktopNotification,
                .persistentStorage,
                .webxr,
                .autoplay,
                .mediaKeySystemAccess,
                .tracking,
                .localDeviceAccess,
                .localNetworkAccess,
                .deviceSensors,
            nil:
            return nil
        }
    }
    
    static func mediaAlertTitle(uri: String, videoRequested: Bool, audioRequested: Bool) -> String {
        let host = permissionHost(from: uri)
        switch (videoRequested, audioRequested) {
        case (true, true):
            return L10n.string("permission_prompt.camera_microphone", host)
        case (true, false):
            return L10n.string("permission_prompt.camera", host)
        case (false, true):
            return L10n.string("permission_prompt.microphone", host)
        case (false, false):
            return L10n.string("permission_prompt.camera_microphone", host)
        }
    }
}
