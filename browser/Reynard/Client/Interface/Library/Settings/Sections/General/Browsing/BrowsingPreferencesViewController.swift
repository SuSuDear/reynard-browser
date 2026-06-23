//
//  BrowsingPreferencesViewController.swift
//  Reynard
//
//  Created by Minh Ton on 15/5/26.
//

import UIKit

final class BrowsingPreferencesViewController: SettingsTableViewController {
    private enum Section: CaseIterable {
        case desktopWebsite
        case webLanguage
        
        var text: SettingsSectionText {
            switch self {
            case .desktopWebsite:
                return SettingsSectionText(headerTitle: L10n.string("settings.browsing.request_desktop_on"))
            case .webLanguage:
                return SettingsSectionText(footerTitle: L10n.string("settings.browsing.web_language.footer"))
            }
        }
    }
    
    private enum DesktopWebsiteRow: CaseIterable {
        case allWebsites
    }
    
    private let requestDesktopWebsiteSwitch = UISwitch()
    
    init() {
        super.init(style: .insetGrouped)
        title = L10n.string("settings.general.browsing")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSwitch()
        refreshDisplayedState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshDisplayedState()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard Section.allCases.indices.contains(section) else {
            return 0
        }
        
        switch Section.allCases[section] {
        case .desktopWebsite:
            return DesktopWebsiteRow.allCases.count
        case .webLanguage:
            return WebLanguage.allCases.count
        }
    }
    
    override func sectionText(for section: Int) -> SettingsSectionText {
        guard Section.allCases.indices.contains(section) else {
            return SettingsSectionText()
        }
        return Section.allCases[section].text
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard Section.allCases.indices.contains(indexPath.section) else {
            return UITableViewCell()
        }
        
        switch Section.allCases[indexPath.section] {
        case .desktopWebsite:
            guard DesktopWebsiteRow.allCases.indices.contains(indexPath.row) else {
                return UITableViewCell()
            }
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = .none
            cell.textLabel?.text = L10n.string("settings.browsing.all_websites")
            cell.accessoryView = requestDesktopWebsiteSwitch
            return cell
        case .webLanguage:
            guard WebLanguage.allCases.indices.contains(indexPath.row) else {
                return UITableViewCell()
            }
            let language = WebLanguage.allCases[indexPath.row]
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = language.displayName
            cell.accessoryType = Prefs.BrowsingSettings.webLanguage == language ? .checkmark : .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        guard Section.allCases.indices.contains(indexPath.section),
              Section.allCases[indexPath.section] == .webLanguage,
              WebLanguage.allCases.indices.contains(indexPath.row) else {
            return
        }

        Prefs.BrowsingSettings.webLanguage = WebLanguage.allCases[indexPath.row]
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
    }

    private func configureSwitch() {
        requestDesktopWebsiteSwitch.addTarget(self, action: #selector(requestDesktopWebsiteSwitchDidChange(_:)), for: .valueChanged)
    }
    
    private func refreshDisplayedState() {
        requestDesktopWebsiteSwitch.isOn = Prefs.BrowsingSettings.requestDesktopWebsite
    }
    
    @objc private func requestDesktopWebsiteSwitchDidChange(_ sender: UISwitch) {
        Prefs.BrowsingSettings.requestDesktopWebsite = sender.isOn
    }
}
