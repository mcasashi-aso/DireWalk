//
//  SettingsTableViewDataSource.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/31.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

enum SettingsTableViewCellType: TableViewCellType {
    case about, arrowColor, showFar, darkMode, review, share, version, createdBy, purchase, restore
}

final class SettingsTableViewDataSource: NSObject, UITableViewDataSource {
    
    private let settings = Settings.shared
    
    var sections: [TableViewSection<SettingsTableViewCellType>] = [
        TableViewSection(cells: [.about]),
        TableViewSection(cells: [.arrowColor, .showFar],
                         footer: "doNotShowFarCaption".localized),
//        TableViewSection(cells: [.darkMode],
//                         footer: "captionAlwaysDarkMode".localizedYet),
        TableViewSection(cells: [.review, .share],
                         header: "reviewSection".localized),
//        TableViewSection(cells: [.purchase, .restore],
//                         header: "adAndPurchase".localizedYet),
        TableViewSection(cells: [.version, .createdBy],
                         header: "aboutSection".localized)
    ]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].header
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].cells.count
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].footer
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = sections[indexPath.section].cells[indexPath.row]
        switch cellType {
        // MARK: about
        case .about:
            let cell: TextTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.textView.text = "aboutStrings".localized
            return cell
        // MARK: arrow color
        case .arrowColor:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToSelectColorCell", for: indexPath)
            cell.textLabel?.text = "arrow".localized
            return cell
        // MARK: show far
        case .showFar:
            let cell: ToggleTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.setup(title: "doNotAlwaysShowFar".localizedYet,
                       initialValue: !settings.showFar,
                       didChange: { (isOn) in self.settings.showFar = !isOn })
            return cell
        // MARK: dark mode
        case .darkMode:
            let cell: ToggleTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.setup(title: "alwaysDarkMode".localizedYet,
                       initialValue: settings.isAlwaysDarkAppearance,
                       didChange: { (isOn) in self.settings.isAlwaysDarkAppearance = isOn})
            return cell
        // MARK: review
        case .review:
            let cell: TappableTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.textLabel?.text = "review".localized
            return cell
        // MARK: share
        case .share:
            let cell: TappableTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.textLabel?.text = "share".localized
            return cell
        // MARK: version
        case .version:
            let cell: DetailTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.textLabel?.text = "version".localized
            cell.detailTextLabel?.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            return cell
        // MARK: created by
        case .createdBy:
            let cell: DetailTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.textLabel?.text = "createdby".localized
            cell.detailTextLabel?.text = "Masashi Aso"
            return cell
        // MARK: purchase
        case .purchase:
            let cell: TappableTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.textLabel?.text = "removeAd".localized
            return cell
        // MARK: restore
        case .restore:
            let cell: TappableTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.textLabel?.text = "restorePurchase".localized
            return cell
        }
    }
}
