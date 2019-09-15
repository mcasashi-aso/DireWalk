//
//  SettingsViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/05.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import Accounts

final class SettingsViewController: UIViewController, UITableViewDelegate {
    
    private let settings = Settings.shared
    private let dataSource = SettingsTableViewDataSource()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = dataSource
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = dataSource.sections[indexPath.section].cells[indexPath.row]
        switch type {
        case .review:
            if let url = URL(string: "https://itunes.apple.com/jp/app/id1455960079?mt=8&action=write-review") {
                UIApplication.shared.open(url)
            }
        case .share:
            let activityItemSentence = "shareString".localized
            let appURL = NSURL(fileURLWithPath: "https://itunes.apple.com/jp/app/direwalk/id1455960079")
            let activityViewController = UIActivityViewController(
                activityItems: [activityItemSentence, appURL],
                applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        case .purchase: break
        case .restore: break
        case .about, .arrowColor, .showFar, .darkMode, .version, .createdBy: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "settings".localized
        registerCells()
    }
    
    @IBAction func tapDone() {
        self.dismiss(animated: true, completion: nil)
    }

    func registerCells() {
        tableView.register(ToggleTableViewCell.self)
        tableView.register(TextTableViewCell.self)
        tableView.register(TappableTableViewCell.self)
        tableView.register(DetailTableViewCell.self)
    }
}
