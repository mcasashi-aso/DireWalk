//
//  SelectColorViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/03/25.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

final class ArrowSettingViewController: UIViewController {
    
    var sections: [TableViewSection<ArrowTableViewCellType>] = [
        TableViewSection(cells: [.imageStyle, .color],
                         footer: "about color".localized),
        TableViewSection(cells: [.aboutOnly],
                         header: "about".localized)
    ]
    
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let settings = Settings.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrowImageView.transform = CGAffineTransform(rotationAngle: (45 * CGFloat.pi / 180))
        
        self.navigationItem.title = "arrowColor".localized
        previewLabel.text = "preview".localized
        
        tableView.dataSource = self
    }
    
    func updatePreview() {
        let arrowColor = settings.arrowColor
        let image = settings.arrowImage.image
        
        arrowImageView.image = image.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = UIColor(white: arrowColor, alpha: 1)
    }
}


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
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageStyle", for: indexPath) as! ArrowImageStyleTableViewCell
            cell.delegate = self
            return cell
        case .color:
            let cell: SliderTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.setup(title: "color".localizedYet, initialValue: Float(settings.arrowColor)) { value in
                self.settings.arrowColor = CGFloat(value)
                self.updatePreview()
            }
            return cell
        case .aboutOnly:
            let cell: TextTableViewCell = tableView.getCell(indexPath: indexPath)
            cell.textView.text = "arrowAbout".localizedYet
            return cell
        }
    }
}


extension ArrowSettingViewController: ArrowImageStyleTableViewCellDelegate {
    func didChangeArrowImageStyle(_ style: Settings.ArrowImage) {
        settings.arrowImage = style
        updatePreview()
    }
}
