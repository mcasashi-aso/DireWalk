//
//  TextFieldTableViewCell.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/16.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell, NibReusable, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    var placeholderText: String?
    var didChange: ((String?) -> Void)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }
    
    func setup(placeholderText: String?, initialValue: String?,
               didChange: @escaping (String?) -> Void) {
        textField.placeholder = placeholderText
        textField.text = initialValue
        self.didChange = didChange
    }

    // MARK: - TextViewDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = NSString(string: textField.text ?? "")
        let text = nsString.replacingCharacters(in: range, with: string) as String
        didChange(text)
        return true
    }
}
