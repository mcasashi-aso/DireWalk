//
//  SettingsViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/05.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import Accounts

// なんかいい書き方あるのでは…？
class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var viewModel = ViewModel.shared
    
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return nil
        case 2: return NSLocalizedString("reviewSection", comment: "")
        case 3: return NSLocalizedString("about", comment: "")
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return NSLocalizedString("captionDoNotShowFar", comment: "")
        case 2: return nil
        case 3: return nil
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 2
        case 3: return 2
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
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectColorCell", for: indexPath)
                cell.textLabel?.text = NSLocalizedString("arrowColor", comment: "")
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChangeShowFarCell", for: indexPath)
                cell.textLabel?.text = NSLocalizedString("doNotAlwaysShowFar", comment: "")
                return cell
            default: break
            }
            return UITableViewCell()
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TapableCell", for: indexPath)
            switch indexPath.row {
            case 0: cell.textLabel?.text = NSLocalizedString("review", comment: "")
            case 1: cell.textLabel?.text = NSLocalizedString("share", comment: "")
            default: break
            }
            return cell
        case 3:
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
            if let url = URL(string: "https://itunes.apple.com/jp/app/id1455960079?mt=8&action=write-review") {
                UIApplication.shared.open(url)
            }
        case 1:
            let activityItemSentence = NSLocalizedString("shareString", comment: "")
            let appURL = NSURL(fileURLWithPath: "https://itunes.apple.com/jp/app/direwalk/id1455960079")
            let activityViewController = UIActivityViewController(
                activityItems: [activityItemSentence, appURL], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
