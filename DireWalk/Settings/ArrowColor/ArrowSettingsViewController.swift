//
//  SelectColorViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

final class ArrowSettingViewController: UIViewController {
    
    // MARK: - Model
    var sections: [TableViewSection<ArrowTableViewCellType>] = [
        TableViewSection(cells: [.imageStyle, .color],
                         footer: "about color".localizedYet),
        TableViewSection(cells: [.aboutOnly],
                         header: "about".localized)
    ]
    
    private let settings = Settings.shared
    
    // MARK: - Views
    @IBOutlet weak var arrowImageView: UIImageView! {
        didSet {
            let transform = CGAffineTransform(rotationAngle: 45 * .pi / 180)
            arrowImageView.transform = transform
            updatePreview()
        }
    }
    @IBOutlet weak var previewLabel: UILabel! {
        didSet {
            previewLabel.text = "preview".localized
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(SegmentedTableViewCell.self)
            tableView.register(SliderTableViewCell.self)
            tableView.register(TextTableViewCell.self)
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "arrowColor".localized
    }
    
    func updatePreview() {
        let arrowColor = settings.arrowColor
        let image = settings.arrowImage.image
        
        arrowImageView.image = image.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = UIColor(white: arrowColor, alpha: 1)
    }
}


// MARK: - TableViewDataSource
enum ArrowTableViewCellType: TableViewCellType {
    case imageStyle, color, aboutOnly
}

extension ArrowSettingViewController: UITableViewDataSource {
    
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
        case .imageStyle:
            let cell: SegmentedTableViewCell = tableView.getCell(indexPath: indexPath)
            let didChange = { (index: Int) -> Void in
                let array = Settings.ArrowImage.allCases.map({$0})
                self.settings.arrowImage = array[index]
                self.updatePreview()
            }
            cell.setup(title: "arrowStyle".localizedYet,
                       array: Settings.ArrowImage.allCases.map({$0.rawValue}),
                       initialValue: settings.arrowImage.rawValue,
                       didChange: didChange)
            return cell
        case .color:
            let cell: SliderTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.setup(title: "color".localizedYet, initialValue: Float(settings.arrowColor)) { value in
                self.settings.arrowColor = CGFloat(value)
                self.updatePreview()
            }
            cell.slider.minimumTrackTintColor = .white
            cell.slider.maximumTrackTintColor = .black
            return cell
        case .aboutOnly:
            let cell: TextTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.textView.text = "arrowAbout".localizedYet
            return cell
        }
    }
}
