//
//  EditFavoriteViewController.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/15.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

class EditFavoriteViewController: UIViewController {
    
    static func create(_ place: Place) -> EditFavoriteViewController {
        let sb = UIStoryboard(name: "EditFavorite", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! EditFavoriteViewController
        vc.place = place
        vc.setupViews()
        return vc
    }
    
    enum EditFavoriteTableViewCellType: TableViewCellType {
        case name, address, latitude, longitude, delete
    }
    
    var sections: [TableViewSection<EditFavoriteTableViewCellType>] = [
        TableViewSection(cells: [.name]),
        TableViewSection(cells: [.address, .latitude, .longitude],
                         header: "data".localizedYet),
        TableViewSection(cells: [.delete])
    ]
    
    var place: Place!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        navigationController?.title = "editPlace".localizedYet
    }
    
    func setupViews() {
        
    }
}


extension EditFavoriteViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        sections[section].header
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].cells.count
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].footer
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = sections[indexPath.section].cells[indexPath.row]
        switch type {
        case .name:
            break
        case .address:
            break
        case .latitude:
            break
        case .longitude:
            break
        case .delete:
            break
        }
        return UITableViewCell()
    }
}


extension EditFavoriteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = sections[indexPath.section].cells[indexPath.row]
        switch type {
        case .delete:
            place.isFavorite.toggle()
            dismiss(animated: true, completion: nil)
        case .name, .address, .latitude, .longitude: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
