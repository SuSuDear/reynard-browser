//
//  AddonPermissionSupport.swift
//  Reynard
//
//  Created by Minh Ton on 23/5/26.
//

import Foundation

private func tr(_ key: String) -> String { L10n.string(key) }
private func tr(_ key: String, _ arguments: CVarArg...) -> String { String(format: L10n.string(key), arguments: arguments) }

public struct AddonLocalizedPermission {
    public let name: String
    public let localizedName: String
    public let granted: Bool
    
    public init(name: String, localizedName: String, granted: Bool) {
        self.name = name
        self.localizedName = localizedName
        self.granted = granted
    }
}

public struct AddonHostPermissions {
    public let allUrls: String?
    public let wildcards: [String]
    public let sites: [String]
    
    public init(allUrls: String?, wildcards: [String], sites: [String]) {
        self.allUrls = allUrls
        self.wildcards = wildcards
        self.sites = sites
    }
}

private enum AddonHostPermissionKind: Equatable {
    case allUrls
    case domain(String)
    case site(String)
}

public enum AddonPermissionSupport {
    public static let allowForAllSitesTitle = tr("addons.permission.allow_all_sites.title")
    public static let allowForAllSitesSubtitle = tr("addons.permission.allow_all_sites.subtitle")
    public static let noPermissionsRequiredDescription = tr("addons.permission.none_required")
    public static let noDataCollectionRequiredDescription = tr("addons.data.none_required")
    public static let userScriptsWarning = tr("addons.permission.user_scripts.warning")
    
    private static let permissionDescriptions = [
        "<all_urls>": tr("addons.permission.all_urls"),
        "bookmarks": tr("addons.permission.bookmarks"),
        "browserSettings": tr("addons.permission.browser_settings"),
        "browsingData": tr("addons.permission.browsing_data"),
        "clipboardRead": tr("addons.permission.clipboard_read"),
        "clipboardWrite": tr("addons.permission.clipboard_write"),
        "declarativeNetRequest": tr("addons.permission.declarative_net_request"),
        "declarativeNetRequestFeedback": tr("addons.permission.declarative_net_request_feedback"),
        "devtools": tr("addons.permission.devtools"),
        "downloads": tr("addons.permission.downloads"),
        "downloads.open": tr("addons.permission.downloads_open"),
        "find": tr("addons.permission.find"),
        "geolocation": tr("addons.permission.geolocation"),
        "history": tr("addons.permission.history"),
        "management": tr("addons.permission.management"),
        "nativeMessaging": tr("addons.permission.native_messaging"),
        "notifications": tr("addons.permission.notifications"),
        "pkcs11": tr("addons.permission.pkcs11"),
        "privacy": tr("addons.permission.privacy"),
        "proxy": tr("addons.permission.proxy"),
        "sessions": tr("addons.permission.sessions"),
        "tabHide": tr("addons.permission.tab_hide"),
        "tabs": tr("addons.permission.tabs"),
        "topSites": tr("addons.permission.top_sites"),
        "trialML": tr("addons.permission.trial_ml"),
        "userScripts": tr("addons.permission.user_scripts"),
        "webNavigation": tr("addons.permission.web_navigation"),
    ]
    
    private static let dataCollectionShortDescriptions = [
        "authenticationInfo": tr("addons.data.short.authentication_info"),
        "bookmarksInfo": tr("addons.data.short.bookmarks_info"),
        "browsingActivity": tr("addons.data.short.browsing_activity"),
        "financialAndPaymentInfo": tr("addons.data.short.financial_payment_info"),
        "healthInfo": tr("addons.data.short.health_info"),
        "locationInfo": tr("addons.data.short.location_info"),
        "personalCommunications": tr("addons.data.short.personal_communications"),
        "personallyIdentifyingInfo": tr("addons.data.short.personally_identifying_info"),
        "searchTerms": tr("addons.data.short.search_terms"),
        "technicalAndInteraction": tr("addons.data.short.technical_interaction"),
        "websiteActivity": tr("addons.data.short.website_activity"),
        "websiteContent": tr("addons.data.short.website_content"),
    ]
    
    private static let dataCollectionLongDescriptions = [
        "authenticationInfo": tr("addons.data.long.authentication_info"),
        "bookmarksInfo": tr("addons.data.long.bookmarks_info"),
        "browsingActivity": tr("addons.data.long.browsing_activity"),
        "financialAndPaymentInfo": tr("addons.data.long.financial_payment_info"),
        "healthInfo": tr("addons.data.long.health_info"),
        "locationInfo": tr("addons.data.long.location_info"),
        "personalCommunications": tr("addons.data.long.personal_communications"),
        "personallyIdentifyingInfo": tr("addons.data.long.personally_identifying_info"),
        "searchTerms": tr("addons.data.long.search_terms"),
        "technicalAndInteraction": tr("addons.data.long.technical_interaction"),
        "websiteActivity": tr("addons.data.long.website_activity"),
        "websiteContent": tr("addons.data.long.website_content"),
    ]
    
    public static func localizePermissions(_ permissions: [String], forUpdate: Bool = false) -> [String] {
        var localizedURLAccessPermissions: [String] = []
        let requireAllUrlsAccess = permissions.contains("<all_urls>")
        var notFoundPermissions: [String] = []
        
        let localizedNormalPermissions = permissions.compactMap { permission -> String? in
            guard let localizedPermission = localizedPermissionDescription(for: permission, forUpdate: forUpdate) else {
                notFoundPermissions.append(permission)
                return nil
            }
            
            return localizedPermission
        }
        
        if !requireAllUrlsAccess && !notFoundPermissions.isEmpty {
            localizedURLAccessPermissions = localizeURLAccessPermissions(notFoundPermissions, forUpdate: forUpdate)
        }
        
        return localizedNormalPermissions + localizedURLAccessPermissions
    }
    
    public static func localizeOptionalPermissions(
        _ permissions: [String],
        grantedPermissions: [String]
    ) -> [AddonLocalizedPermission] {
        let granted = Set(grantedPermissions)
        var localizedPermissions: [AddonLocalizedPermission] = []
        var unresolved: [String] = []
        var allUrlsFound = false
        
        permissions.forEach { permission in
            guard let localizedName = localizedPermissionDescription(for: permission, forUpdate: false) else {
                unresolved.append(permission)
                return
            }
            
            if permission == "<all_urls>" {
                allUrlsFound = true
            }
            
            localizedPermissions.append(
                AddonLocalizedPermission(name: permission, localizedName: localizedName, granted: granted.contains(permission))
            )
        }
        
        if !allUrlsFound {
            unresolved.forEach { permission in
                guard let localizedName = localizeHostPermission(permission, forUpdate: false) else {
                    return
                }
                
                localizedPermissions.append(
                    AddonLocalizedPermission(name: permission, localizedName: localizedName, granted: granted.contains(permission))
                )
            }
        }
        
        return localizedPermissions
    }
    
    public static func localizeOptionalOrigins(
        _ origins: [String],
        grantedOrigins: [String]
    ) -> [AddonLocalizedPermission] {
        let granted = Set(grantedOrigins)
        var localizedOrigins: [AddonLocalizedPermission] = []
        var seen = Set<String>()
        
        origins.forEach { origin in
            guard !seen.contains(origin),
                  let localizedName = localizeHostPermission(origin, forUpdate: false) else {
                return
            }
            
            seen.insert(origin)
            localizedOrigins.append(
                AddonLocalizedPermission(name: origin, localizedName: localizedName, granted: granted.contains(origin))
            )
        }
        
        return localizedOrigins
    }
    
    public static func localizeDataCollectionPermissions(_ permissions: [String]) -> [String] {
        permissions.compactMap { dataCollectionShortDescriptions[$0] }
    }
    
    public static func localizeOptionalDataCollectionPermissions(
        _ permissions: [String],
        grantedPermissions: [String]
    ) -> [AddonLocalizedPermission] {
        let granted = Set(grantedPermissions)
        return permissions.compactMap { permission in
            guard let localizedName = dataCollectionLongDescriptions[permission] else {
                return nil
            }
            
            return AddonLocalizedPermission(name: permission, localizedName: localizedName, granted: granted.contains(permission))
        }
    }
    
    public static func formatLocalizedDataCollectionPermissions(_ localizedPermissions: [String]) -> String {
        ListFormatter.localizedString(byJoining: localizedPermissions)
    }
    
    public static func requiredDataCollectionDescription(for permissions: [String]) -> String? {
        if permissions.count == 1, permissions.contains("none") {
            return noDataCollectionRequiredDescription
        }
        
        let localizedPermissions = localizeDataCollectionPermissions(permissions)
        guard !localizedPermissions.isEmpty else {
            return nil
        }
        
        return tr("addons.data.required_description", formatLocalizedDataCollectionPermissions(localizedPermissions))
    }
    
    public static func optionalDataCollectionDescription(for permissions: [String]) -> String? {
        let localizedPermissions = localizeDataCollectionPermissions(permissions)
        guard !localizedPermissions.isEmpty else {
            return nil
        }
        
        return tr("addons.data.optional_description", formatLocalizedDataCollectionPermissions(localizedPermissions))
    }
    
    public static func updateDataCollectionDescription(for permissions: [String]) -> String? {
        let localizedPermissions = localizeDataCollectionPermissions(permissions)
        guard !localizedPermissions.isEmpty else {
            return nil
        }
        
        return tr("addons.data.update_description", formatLocalizedDataCollectionPermissions(localizedPermissions))
    }
    
    public static func updatePermissionDescription(for permissions: [String]) -> String? {
        let localizedPermissions = localizePermissions(permissions, forUpdate: true)
        guard !localizedPermissions.isEmpty else {
            return nil
        }
        
        return tr("addons.permission.update_description", localizedPermissions.joined(separator: " "))
    }
    
    public static func allSiteOriginPermissions(_ origins: [String]) -> [String] {
        origins.filter { hostPermissionKind(for: $0) == .allUrls }
    }
    
    public static func classifyOriginPermissions(_ origins: [String]) -> AddonHostPermissions {
        var allUrls: String?
        var wildcards: [String] = []
        var sites: [String] = []
        
        origins.forEach { permission in
            if permission == "<all_urls>" {
                if allUrls == nil {
                    allUrls = permission
                }
                return
            }
            
            guard let translation = hostPermissionKind(for: permission) else {
                return
            }
            
            switch translation {
            case .allUrls:
                if allUrls == nil {
                    allUrls = permission
                }
            case .domain(let host):
                if !wildcards.contains(host) {
                    wildcards.append(host)
                }
            case .site(let host):
                if !sites.contains(host) {
                    sites.append(host)
                }
            }
        }
        
        return AddonHostPermissions(allUrls: allUrls, wildcards: wildcards, sites: sites)
    }
    
    public static func localizeHostPermission(_ permission: String, forUpdate: Bool) -> String? {
        switch hostPermissionKind(for: permission) {
        case .allUrls:
            return forUpdate ? tr("addons.permission.all_websites.update") : tr("addons.permission.all_websites")
        case .domain(let host):
            return forUpdate ? tr("addons.permission.domain.update", host) : tr("addons.permission.domain", host)
        case .site(let host):
            return forUpdate ? tr("addons.permission.site.update", host) : tr("addons.permission.site", host)
        case nil:
            return nil
        }
    }
    
    private static func localizedPermissionDescription(for permission: String, forUpdate: Bool) -> String? {
        guard let description = permissionDescriptions[permission] else {
            return nil
        }
        
        return forUpdate ? description + "." : description
    }
    
    private static func localizeURLAccessPermissions(_ accessPermissions: [String], forUpdate: Bool) -> [String] {
        var hostPermissions: [(String, AddonHostPermissionKind)] = []
        var seenPermissions = Set<String>()
        
        accessPermissions.forEach { permission in
            guard !seenPermissions.contains(permission),
                  let translation = hostPermissionKind(for: permission) else {
                return
            }
            
            seenPermissions.insert(permission)
            hostPermissions.append((permission, translation))
        }
        
        if hostPermissions.contains(where: { _, translation in
            if case .allUrls = translation {
                return true
            }
            return false
        }) {
            return [forUpdate ? tr("addons.permission.all_websites.update") : tr("addons.permission.all_websites")]
        }
        
        return formatURLAccessPermissions(hostPermissions, forUpdate: forUpdate)
    }
    
    private static func formatURLAccessPermissions(
        _ hostPermissions: [(String, AddonHostPermissionKind)],
        forUpdate: Bool
    ) -> [String] {
        let maxShownPermissionsEntries = forUpdate ? 2 : 4
        var descriptions: [String] = []
        var domainCount = 0
        var siteCount = 0
        
        for (_, translation) in hostPermissions {
            switch translation {
            case .allUrls:
                continue
            case .domain(let host):
                domainCount += 1
                guard domainCount <= maxShownPermissionsEntries else {
                    continue
                }
                descriptions.append(forUpdate ? tr("addons.permission.domain.update", host) : tr("addons.permission.domain", host))
            case .site(let host):
                siteCount += 1
                guard siteCount <= maxShownPermissionsEntries else {
                    continue
                }
                descriptions.append(forUpdate ? tr("addons.permission.site.update", host) : tr("addons.permission.site", host))
            }
        }
        
        if domainCount > maxShownPermissionsEntries {
            if domainCount - maxShownPermissionsEntries == 1 {
                descriptions.append(forUpdate ? tr("addons.permission.another_domain.update") : tr("addons.permission.another_domain"))
            } else {
                descriptions.append(forUpdate ? tr("addons.permission.other_domains.update") : tr("addons.permission.other_domains"))
            }
        }
        
        if siteCount > maxShownPermissionsEntries {
            if siteCount - maxShownPermissionsEntries == 1 {
                descriptions.append(forUpdate ? tr("addons.permission.another_site.update") : tr("addons.permission.another_site"))
            } else {
                descriptions.append(forUpdate ? tr("addons.permission.other_sites.update") : tr("addons.permission.other_sites"))
            }
        }
        
        return descriptions
    }
    
    private static func hostPermissionKind(for pattern: String) -> AddonHostPermissionKind? {
        if pattern == "<all_urls>" {
            return .allUrls
        }
        
        guard let schemeRange = pattern.range(of: "://") else {
            return nil
        }
        
        let scheme = pattern[..<schemeRange.lowerBound]
        if scheme != "*" && scheme != "http" && scheme != "https" && scheme != "ws" && scheme != "wss" && scheme != "file" {
            return nil
        }
        
        let hostAndPath = pattern[schemeRange.upperBound...]
        let parts = hostAndPath.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: false)
        let host = parts.first.map(String.init) ?? ""
        let path = parts.count > 1 ? "/" + parts[1] : ""
        
        switch true {
        case host == "*":
            return .allUrls
        case host.isEmpty || path.isEmpty:
            return nil
        case host.hasPrefix("*."):
            return .domain(String(host.dropFirst(2)))
        default:
            return .site(host)
        }
    }
}
