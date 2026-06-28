//
//  FavoritesItemActions.swift
//  Reynard
//
//  Created by Minh Ton on 27/6/26.
//

import UIKit

struct FavoritesItemActions {
    static func configuration(
        for bookmark: BookmarkSnapshot,
        openInNewTab: @escaping () -> Void,
        openInNewPrivateTab: @escaping () -> Void,
        shareLink: @escaping (URL) -> Void,
        editBookmark: @escaping () -> Void,
        deleteBookmark: @escaping () -> Void
    ) -> UIContextMenuConfiguration {
        return UIContextMenuConfiguration(identifier: bookmark.guid as NSString, previewProvider: nil) { _ in
            UIMenu(title: "", children: [
                UIMenu(title: "", options: .displayInline, children: [
                    UIAction(title: L10n.string("context_menu.open_new_tab"), image: UIImage(named: "reynard.plus.square.on.square")) { _ in
                        openInNewTab()
                    },
                    UIAction(title: L10n.string("context_menu.open_new_private_tab"), image: UIImage(named: "reynard.plus.square.on.square")) { _ in
                        openInNewPrivateTab()
                    },
                ]),
                UIMenu(title: "", options: .displayInline, children: [
                    UIAction(title: L10n.string("context_menu.copy_link"), image: UIImage(named: "reynard.document.on.document")) { _ in
                        UIPasteboard.general.string = bookmark.url.absoluteString
                    },
                    UIAction(title: L10n.string("context_menu.share_link"), image: UIImage(named: "reynard.square.and.arrow.up")) { _ in
                        shareLink(bookmark.url)
                    },
                ]),
                UIMenu(title: "", options: .displayInline, children: [
                    UIAction(title: L10n.string("address_bar.edit_bookmark"), image: UIImage(named: "reynard.pencil")) { _ in
                        editBookmark()
                    },
                    UIAction(
                        title: L10n.string("bookmarks.delete_bookmark"),
                        image: UIImage(named: "reynard.trash"),
                        attributes: .destructive
                    ) { _ in
                        deleteBookmark()
                    },
                ]),
            ])
        }
    }
    
    static func configuration(
        for folder: BookmarkFolderSnapshot,
        deleteFolder: @escaping () -> Void
    ) -> UIContextMenuConfiguration {
        return UIContextMenuConfiguration(identifier: folder.guid as NSString, previewProvider: nil) { _ in
            UIMenu(title: "", children: [
                UIAction(
                    title: L10n.string("bookmarks.delete_folder"),
                    image: UIImage(named: "reynard.trash"),
                    attributes: .destructive
                ) { _ in
                    deleteFolder()
                },
            ])
        }
    }
}

extension FavoritesSectionViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let anchorView = interaction.view,
              let item = favoriteItem(forContextMenuAnchor: anchorView) else {
            return nil
        }
        
        switch item {
        case let .bookmark(bookmark):
            return FavoritesItemActions.configuration(
                for: bookmark,
                openInNewTab: { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    self.delegate?.homepageSection(self, didRequestOpenURL: bookmark.url, disposition: .newTab)
                },
                openInNewPrivateTab: { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    self.delegate?.homepageSection(self, didRequestOpenURL: bookmark.url, disposition: .newPrivateTab)
                },
                shareLink: { [weak self] url in
                    guard let self else {
                        return
                    }
                    
                    self.delegate?.homepageSection(self, didRequestShareURL: url)
                },
                editBookmark: { [weak self] in
                    self?.presentBookmarkEditor(for: bookmark)
                },
                deleteBookmark: { [weak self] in
                    self?.deleteFavoriteBookmark(bookmark)
                }
            )
            
        case let .folder(folder):
            return FavoritesItemActions.configuration(
                for: folder,
                deleteFolder: { [weak self] in
                    self?.deleteFavoriteFolder(folder)
                }
            )
        }
    }
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        willDisplayMenuFor configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        cancelFavoriteReordering()
    }
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        willEndFor configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionAnimating?
    ) {
        cancelFavoriteReordering()
        removeFavoriteContextMenuInteraction(interaction)
    }
}
