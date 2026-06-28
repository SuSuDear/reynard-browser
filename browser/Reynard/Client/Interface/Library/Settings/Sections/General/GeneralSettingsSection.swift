//
//  GeneralSettingsSection.swift
//  Reynard
//
//  Created by Minh Ton on 18/6/26.
//

import UIKit

struct GeneralSettingsSection {
    enum Row: CaseIterable {
        case addons
        case browsing
        case search
        case newTab
        case homepage
        case appearance
        case compatibility
    }
    
    var rowCount: Int {
        return Row.allCases.count
    }
    
    func cell(at index: Int) -> UITableViewCell {
        guard Row.allCases.indices.contains(index) else {
            return UITableViewCell()
        }
        
        switch Row.allCases[index] {
        case .addons:
            return SettingsViewUtils.disclosureCell(title: L10n.string("settings.general.addons"))
        case .browsing:
            return SettingsViewUtils.disclosureCell(title: L10n.string("settings.general.browsing"))
        case .search:
            return SettingsViewUtils.disclosureCell(title: L10n.string("settings.general.search"))
        case .newTab:
            return SettingsViewUtils.disclosureCell(title: L10n.string("settings.general.new_tab"))
        case .homepage:
            return SettingsViewUtils.disclosureCell(title: L10n.string("common.homepage"))
        case .appearance:
            return SettingsViewUtils.disclosureCell(title: L10n.string("settings.general.appearance"))
        case .compatibility:
            return SettingsViewUtils.disclosureCell(title: L10n.string("settings.general.compatibility"))
        }
    }
    
    func selectRow(at index: Int, from viewController: UIViewController) {
        guard Row.allCases.indices.contains(index) else {
            return
        }
        
        let destination: UIViewController
        switch Row.allCases[index] {
        case .addons:
            destination = AddonsPreferencesViewController()
        case .browsing:
            destination = BrowsingPreferencesViewController()
        case .search:
            destination = SearchPreferencesViewController()
        case .newTab:
            destination = NewTabPreferencesViewController()
        case .homepage:
            destination = HomepagePreferencesViewController()
        case .appearance:
            destination = AppearancePreferencesViewController()
        case .compatibility:
            destination = CompatibilityPreferencesViewController()
        }
        viewController.navigationController?.pushViewController(destination, animated: true)
    }
}
