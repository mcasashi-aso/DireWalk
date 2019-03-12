//
//  SettingsViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/05.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import Accounts

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return nil  // NSLocalizedString("reviewSection", comment: "")
        case 2:
            return NSLocalizedString("about", comment: "")
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 0    // 2
        case 2: return 2
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextTableViewCell
            cell.textView.text = NSLocalizedString("aboutStrings", comment: "")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TapableCell", for: indexPath)
            switch indexPath.row {
            case 0: cell.textLabel?.text = NSLocalizedString("review", comment: "")
            case 1: cell.textLabel?.text = NSLocalizedString("share", comment: "")
            default: break
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            switch indexPath.row {
            case 0: cell.textLabel?.text = NSLocalizedString("version", comment: "")
                    cell.detailTextLabel?.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            case 1: cell.textLabel?.text = NSLocalizedString("createdby", comment: "")
                    cell.detailTextLabel?.text = "Masashi Aso"
            default: break
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 1 { return }
        switch indexPath.row {
        case 0:
            // https://dev.classmethod.jp/smartphone/launching-app-store-from-ios-app/
            break
        case 1:
            // ActivityViewControllerを呼ぶ
            break
        default:
            break
        }
    }
    
    @IBOutlet weak var doneButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("settings", comment: "")
        doneButton.setTitle(NSLocalizedString("done", comment: ""), for: .normal)
    }
    
    @IBAction func tapDone() {
        self.dismiss(animated: true, completion: nil)
    }

}
