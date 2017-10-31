//
//  FieldCell.swift
//  HarborBoulevad
//
//  © Copyright IBM Corp. 2015 All rights reserved.
//

import UIKit

class FieldCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var textField : UITextField!
    
    private var field : ICPField?
    
    // MARK: Public methods
    
    func configureWithField(_ field : ICPField){
        
        self.textField.delegate = self
        self.field = field
        self.label.text = field.type!.typeId
        self.textField.text = field.value as? String
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text as NSString? {
            let newString = text.replacingCharacters(in: range, with: string)
            
            self.field!.value = newString;
        }
        
        return true
        
    }

}
