//
//  SiteCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/14/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class SiteCell: TableCell {

    private var props: SiteCellProperties!
    
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var siteIndexImageView: UIImageView!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var arrowLabel: UILabel!

    @discardableResult
    func configure(props: SiteCellProperties) -> SiteCell {
        self.props = props
        loadOrderDependentViews()
        nameLabel.text = props.site?.name
        siteIndexImageView.image = PDIcons.siteIndexIcon.withRenderingMode(.alwaysTemplate)
        reflectTheme()
        prepareBackgroundSelectedView()
        return self
    }

    public func reflectActionState(cellIndex: Index, actionState: SiteTableActionState) {
        let shouldHide = actionState == .Editing
        orderLabel.isHidden = shouldHide
        arrowLabel.isHidden = shouldHide

        if cellIndex == props?.nextSiteIndex {
            nextLabel.isHidden = false
            siteIndexImageView.isHidden = true
        }
    }

    private func loadOrderDependentViews() {
        guard let order = props.site?.order else { return }
        orderLabel.text = "\(order + 1)."
        loadNextLabel(order)
        reflectActionState(cellIndex: order, actionState: .Reading)
    }

    private func loadNextLabel(_ index: Index) {
        nextLabel.isHidden = nextTitleShouldHide(at: index, isEditing: isEditing)
        siteIndexImageView.isHidden = !nextLabel.isHidden
    }

    private func reflectTheme() {
        guard let theme = props.theme else { return }
        orderLabel.textColor = theme[.text]
        arrowLabel.textColor = theme[.text]
        nameLabel.textColor = theme[.purple]
        nextLabel.textColor = theme[.green]
        siteIndexImageView.tintColor = theme[.text]
        backgroundColor = theme[.bg]
    }
    
    /// Should hide if not the the next index.
    private func nextTitleShouldHide(at index: Index, isEditing: Bool) -> Bool {
        props.nextSiteIndex != index || isEditing
    }
    
    private func prepareBackgroundSelectedView() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = props.theme?[.selected]
        selectedBackgroundView = backgroundView
    }
}
