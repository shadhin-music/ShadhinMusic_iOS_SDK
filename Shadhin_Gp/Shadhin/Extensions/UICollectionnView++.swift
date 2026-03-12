//
//  UICollectionnView++.swift
//  Shadhin
//
//  Created by Admin on 21/6/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {

    /// Iterates through all sections & items and selects them.
    func selectAll(animated: Bool) {
        (0..<numberOfSections).compactMap { (section) -> [IndexPath]? in
            return (0..<numberOfItems(inSection: section)).compactMap({ (item) -> IndexPath? in
                return IndexPath(item: item, section: section)
            })
        }.flatMap { $0 }.forEach { (indexPath) in
            selectItem(at: indexPath, animated: true, scrollPosition: [])
        }

    }

    /// Deselects all selected cells.
    func deselectAll(animated: Bool) {
        indexPathsForSelectedItems?.forEach({ (indexPath) in
            deselectItem(at: indexPath, animated: animated)
        })
    }

}
