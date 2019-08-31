//
//  SettingsTableViewDataSource.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/31.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

enum SettingsTableViewCellType {
    case about, arrowColor, showFar, darkMode, review, share, version, createdBy
}

// もっといい書き方あると思うんだけど時間と技術的にここが限界
class SettingsTableViewDataSource: NSObject, UITableViewDataSource {
    
    var sections: [TableViewSection] = [
        TableViewSection(cells: [.about]),
        TableViewSection(cells: [.arrowColor, .showFar], footer: NSLocalizedString("captionDoNotShowFar", comment: "")),
        TableViewSection(cells: [.darkMode], footer: NSLocalizedString("captionAlwaysDarkMode", comment: "")),
        TableViewSection(cells: [.review, .share], header: NSLocalizedString("reviewSection", comment: "")),
        TableViewSection(cells: [.version, .createdBy], header: NSLocalizedString("about", comment: ""))
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
            cell.textView.text = NSLocalizedString("aboutStrings", comment: "")
            return cell
        case .arrowColor:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectColorCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("arrowColor", comment: "")
            return cell
        case .showFar:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("doNotAlwaysShowFar", comment: "")
            return cell
        case .darkMode:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChangeDarkMode", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("alwaysDarkMode", comment: "")
            return cell
        case .review:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TapableCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("review", comment: "")
            return cell
        case .share:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TapableCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("share", comment: "")
            return cell
        case .version:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("version", comment: "")
            cell.detailTextLabel?.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            return cell
        case .createdBy:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("createdby", comment: "")
            cell.detailTextLabel?.text = "Masashi Aso"
            return cell
        }
    }
}
