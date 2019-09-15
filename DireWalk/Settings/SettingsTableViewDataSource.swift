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

// もっといい書き方あると思うんだけど時間と技術的にここが限界
final class SettingsTableViewDataSource: NSObject, UITableViewDataSource {
    
    var sections: [TableViewSection<SettingsTableViewCellType>] = [
        TableViewSection(cells: [.about]),
        TableViewSection(cells: [.arrowColor, .showFar],
                         footer: "captionDoNotShowFar".localized),
//        TableViewSection(cells: [.darkMode],
//                         footer: "captionAlwaysDarkMode".localized),
        TableViewSection(cells: [.review, .share],
                         header: "reviewSection".localized),
//        TableViewSection(cells: [.purchase, .restore],
//                         header: "adAndPurchase".localizedYet),
        TableViewSection(cells: [.version, .createdBy],
                         header: "about".localized)
    ]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        sections[section].header
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        sections[section].cells.count
    }
    
    func tableView(_ tableView: UITableView,
                   titleForFooterInSection section: Int) -> String? {
        sections[section].footer
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = sections[indexPath.section].cells[indexPath.row]
        switch cellType {
        case .about:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextTableViewCell
            cell.textView.text = "aboutStrings".localized
            return cell
        case .arrowColor:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectColorCell", for: indexPath)
            cell.textLabel?.text = "arrowColor".localized
            return cell
        case .showFar:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell", for: indexPath)
            cell.textLabel?.text = "doNotAlwaysShowFar".localized
            return cell
        case .darkMode:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChangeDarkMode", for: indexPath)
            cell.textLabel?.text = "alwaysDarkMode".localized
            return cell
        case .review:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TappableCell", for: indexPath)
            cell.textLabel?.text = "review".localized
            return cell
        case .share:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TappableCell", for: indexPath)
            cell.textLabel?.text = "share".localized
            return cell
        case .version:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            cell.textLabel?.text = "version".localized
            cell.detailTextLabel?.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            return cell
        case .createdBy:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            cell.textLabel?.text = "createdby".localized
            cell.detailTextLabel?.text = "Masashi Aso"
            return cell
        case .purchase:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TappableCell", for: indexPath)
            cell.textLabel?.text = "Remove Ad".localizedYet
            return cell
        case .restore:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TappableCell", for: indexPath)
            cell.textLabel?.text = "Restore Purchase".localizedYet
            return cell
        }
    }
}
