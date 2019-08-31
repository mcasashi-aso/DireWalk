//
//  SettingsViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/05.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import Accounts

class SettingsViewController: UIViewController, UITableViewDelegate {
    
    private var viewModel = ViewModel.shared
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
