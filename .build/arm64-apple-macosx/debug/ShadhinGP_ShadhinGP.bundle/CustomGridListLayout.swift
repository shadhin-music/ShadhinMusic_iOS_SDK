//
//  CustomGridListLayout.swift
//  Shadhin
//
//  Created by Gakk Alpha on 6/14/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
import UIKit


class CustomGridListLayout: UICollectionViewFlowLayout {
    
    var vc: FollowingArtistVC!
    var inTransition = false
    
    override init() {
        super.init()
        self.sectionHeadersPinToVisibleBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sectionHeadersPinToVisibleBounds = true
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }

        for attribute in attributes {
            adjustAttributesIfNeeded(attribute)
        }
        return attributes
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) else { return nil }
        adjustAttributesIfNeeded(attributes)
        return attributes
    }

    func adjustAttributesIfNeeded(_ attributes: UICollectionViewLayoutAttributes) {
        switch attributes.representedElementKind {
        case UICollectionView.elementKindSectionHeader:
            adjustHeaderAttributesIfNeeded(attributes)
        default:
            break
        }
    }

    private func adjustHeaderAttributesIfNeeded(_ attributes: UICollectionViewLayoutAttributes) {
        guard attributes.indexPath.section == 0 else { return }
    }


    
}
