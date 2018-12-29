//
//  SiteTableViewCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/14/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

class SiteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var estrogenScheduleImage: UIImageView!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var arrowLabel: UILabel!
    
    public func configure(at index: Index, name: String, siteCount: Int, isEditing: Bool) {
        if index >= 0 && index < siteCount,
            let site = PDSchedule.siteSchedule.getSite(at: index) {
            orderLabel.text = "\(index + 1)."
            nameLabel.text = name
            estrogenScheduleImage.tintColor = UIColor.red
            nextLabel.textColor = PDColors.pdGreen
            estrogenScheduleImage.image = loadEstrogenImages(for: site)
            nextLabel.isHidden = nextTitleShouldHide(at: index, isEditing: isEditing)
            backgroundColor = (index % 2 != 0) ? UIColor.white : PDColors.pdLightBlue
            setBackgroundSelected()
        }
    }
    
    // Hides labels in the table cells for edit mode.
    public func swapVisibilityOfCellFeatures(cellIndex: Index, shouldHide: Bool) {
        orderLabel.isHidden = shouldHide
        arrowLabel.isHidden = shouldHide
        estrogenScheduleImage.isHidden = shouldHide
        let current = PDDefaults.getSiteIndex()
        if cellIndex == PDSchedule.siteSchedule.nextIndex(current: current) {
            nextLabel.isHidden = shouldHide
        }
    }
    
    private func loadEstrogenImages(for site: MOSite) -> UIImage? {
        if site.isOccupiedByMany() || (!PDDefaults.usingPatches() && site.isOccupied()) {
            return  #imageLiteral(resourceName: "ES Icon")
        }
        else if site.isOccupied() {
            let estro = Array(site.estrogenRelationship!)[0] as! MOEstrogen
            if let i = PDSchedule.estrogenSchedule.getIndex(for: estro) {
                return PDImages.getSiteIcon(at: i)
            }
        }
        return nil
    }
    
    private func nextTitleShouldHide(at index: Index, isEditing: Bool) -> Bool {
        let current = PDDefaults.getSiteIndex()
        if PDSchedule.siteSchedule.nextIndex(current: current) == index && !isEditing {
            return false
        }
        return true
    }
    
    private func setBackgroundSelected() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = PDColors.pdPink
        selectedBackgroundView = backgroundView
    }
    
}