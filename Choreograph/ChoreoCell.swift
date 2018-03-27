//
//  ChoreoCell.swift
//  Choreograph
//
//  Created by Karen McCarthy on 25/02/2017.
//  Copyright © 2017 Karen McCarthy. All rights reserved.
//

import Foundation
import UIKit

class ChoreoCell: UITableViewCell, UITextFieldDelegate {
    var inputText:String?
    
    @IBOutlet weak var countText: UITextField! {
        didSet {
            countText.sizeToFit()
            countText.text = inputText
        }
    }
    
    @IBOutlet weak var stepText: UITextField! {
        didSet {
            stepText.sizeToFit()
            stepText.text = inputText
        }
    }
    // MARK: Disable automatic keyboard dismissal
     var disablesAutomaticKeyboardDismissal: Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputText = textField.text
//                                                                                                                                                                                                       textField.resignFirstResponder()
        return false
    }
}
