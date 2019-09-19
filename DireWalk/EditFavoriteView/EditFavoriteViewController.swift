//
//  EditFavoriteViewController.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/15.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

protocol EditFavoriteViewControllerDelegate: class {
    func editFavoriteViewControllerDidFinish()
}

class EditFavoriteViewController: UIViewController, UIAdaptivePresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    static func create(_ place: Place) -> UINavigationController {
        let sb = UIStoryboard(name: "EditFavorite", bundle: nil)
        let navigationController = sb.instantiateInitialViewController() as! UINavigationController
        let vc = navigationController.topViewController as! EditFavoriteViewController
        vc.original = place
        vc.editingText = place.title
        navigationController.presentationController?.delegate = vc
        return navigationController
    }
    
    // MARK: - Table View Data
    enum EditFavoriteTableViewCellType: TableViewCellType {
        case name, address, map, delete
    }
    
    var sections: [TableViewSection<EditFavoriteTableViewCellType>] = [
        TableViewSection(cells: [.name],
                         header: "placeName".localized),
        TableViewSection(cells: [.address, .map],
                         header: "address".localized),
        TableViewSection(cells: [.delete])
    ]
    
    // MARK: - Model
    var original: Place!
    var editingText: String? {
        didSet {
            doneButton.isEnabled = doneble
            if #available(iOS 13, *) {
                isModalInPresentation = doneble
            }
        }
    }
    var hasChanges: Bool { original.title != editingText }
    var doneble: Bool {
        let titleIsEmpty = editingText?.isEmpty ?? true
        return !titleIsEmpty && hasChanges
    }
    
    var firstForKeyboard = true
    
    weak var delegate: EditFavoriteViewControllerDelegate?
    
    // MARK: - Views
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(TextFieldTableViewCell.self)
            tableView.register(TappableTableViewCell.self)
            tableView.register(TitleTableViewCell.self)
            tableView.register(MapTableViewCell.self)
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "editName".localized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // firstForKeyboardがないとちょっとmodalを下げた時に
        // 毎度キーボードが出てきてしまう
        if firstForKeyboard {
            if let cell = tableView.visibleCells.first(where: { $0 is TextFieldTableViewCell }) {
                let nameCell = cell as! TextFieldTableViewCell
                nameCell.textField.becomeFirstResponder()
                firstForKeyboard = false
            }
        }
    }
    
    // MARK: - Events
    @IBAction func cancel() {
        delegate?.editFavoriteViewControllerDidFinish()
    }
    
    @IBAction func done() {
        save()
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        if doneble {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let doneAction = UIAlertAction(title: "save".localized, style: .default) { _ in
                self.save()
            }
            let discardAction = UIAlertAction(title: "discardChanges".localized, style: .destructive) { _ in
                self.delegate?.editFavoriteViewControllerDidFinish()
            }
            let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel)
            alert.addAction(discardAction)
            alert.addAction(doneAction)
            alert.addAction(cancelAction)
            alert.popoverPresentationController?.barButtonItem = cancelButton
            present(alert, animated: true)
        }else {
            delegate?.editFavoriteViewControllerDidFinish()
        }
    }
    
    func save() {
        original.title = editingText
        delegate?.editFavoriteViewControllerDidFinish()
    }

    // MARK: - UITableViewDataSource
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
            cell.setup(placeholderText: original.title, initialValue: original.title,
                       didChange: { self.editingText = $0 })
            cell.textField.returnKeyType = .done
            return cell
        case .address:
            let cell: TitleTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.titleLabel.text = original.address
            cell.separatorInset = .zero
            return cell
        case .map:
            let cell: MapTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.setPlace(original)
            // 無駄に操作できるよりはこっちの方がいいかな
            cell.mapView.isScrollEnabled = false
            cell.mapView.isPitchEnabled = false
            cell.mapView.isRotateEnabled = false
            cell.mapView.isZoomEnabled = false
            cell.mapView.setupGesture()
            // mapViewのzoom操作をtableViewと衝突しないように
            cell.mapView.gestureRecognizers?.forEach { recognizer in
                let name = String(describing: recognizer)
                guard name.contains("UILongPressGestureRecognizer"),
                    name.contains("doubleLongPress") else { return }
                tableView.panGestureRecognizer.require(toFail: recognizer)
            }
            return cell
        case .delete:
            let cell: TappableTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.textLabel?.text = "removeFromFavorite".localized
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.textAlignment = .center
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = sections[indexPath.section].cells[indexPath.row]
        switch type {
        case .name, .address, .delete: return 50
        case .map: return 200
        }
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = sections[indexPath.section].cells[indexPath.row]
        switch type {
        case .delete:
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete".localized, style: .destructive) { _ in
                self.original.isFavorite.toggle()
                self.delegate?.editFavoriteViewControllerDidFinish()
            }
            let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            present(alert, animated: true)
        case .name, .address, .map: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
