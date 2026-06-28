//
//  HomepageOpeningScreen.swift
//  Reynard
//
//  Created by Minh Ton on 27/6/26.
//

enum HomepageOpeningScreen: String, CaseIterable {
    case homepage
    case lastTab
    
    var title: String {
        switch self {
        case .homepage:
            return L10n.string("common.homepage")
        case .lastTab:
            return L10n.string("settings.homepage.last_tab")
        }
    }
}
