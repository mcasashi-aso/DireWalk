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
        vc.original = place
        vc.place = place
        return vc
    }
    
    // MARK: - Table View Data
    enum EditFavoriteTableViewCellType: TableViewCellType {
        case name, address, map, delete
    }
    
    var sections: [TableViewSection<EditFavoriteTableViewCellType>] = [
        TableViewSection(cells: [.name],
                         header: "name".localizedYet),
        TableViewSection(cells: [.address, .map],
                         header: "data".localizedYet),
        TableViewSection(cells: [.delete])
    ]
    
    // MARK: - Model
    var original: Place!
    var place: Place! {
        didSet {
            let titleIsEmpty = place.placeTitle?.isEmpty ?? true
            doneButton.isEnabled = !titleIsEmpty
        }
    }
    
    // MARK: - Views
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(DetailTableViewCell.self)
            tableView.register(TappableTableViewCell.self)
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = "editPlace".localizedYet
    }
}

// MARK: - UITableViewDataSource
extension EditFavoriteViewController: UITableViewDataSource {
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
        let type = sections[indexPath.section].cells[indexPath.row]
        switch type {
        case .name:
            let cell: TextFieldTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.setup(placeholderText: original.placeTitle, initialValue: original.placeTitle,
                       didChange: { self.place.placeTitle = $0 })
            return cell
        case .address:
            let cell: DetailTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.textLabel?.text = "address".localizedYet
            cell.detailTextLabel?.text = place.address
            return cell
        case .map:
            let cell: MapTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.setPlace(place)
            return cell
        case .delete:
            let cell: TappableTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.textLabel?.text = "removeFromFavorite".localizedYet
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.textAlignment = .center
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension EditFavoriteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = sections[indexPath.section].cells[indexPath.row]
        switch type {
        case .delete:
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete".localizedYet, style: .destructive) { _ in
                self.place.isFavorite.toggle()
                self.dismiss(animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        case .name, .address, .map: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
