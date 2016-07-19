//
//  UploadViewController.swift
//  HarborBoulevad
//

//  © Copyright IBM Corp. 2015 All rights reserved.
//

import UIKit

class UploadViewController: UIViewController {
    
    @IBOutlet weak var successLabel : UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var containerView : UIView!
    
    var success : Bool!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.success == true) {
            self.successLabel.text = "Thank you"
            self.successLabel.textColor = UIColor.themeColor()
            
            self.detailLabel.text = "Your documents have been received. You will receive an email in the next few days, once the application has been reviewed."
        } else {
            self.successLabel.text = "An error occured"
            self.successLabel.textColor = UIColor.redColor().colorWithAlphaComponent(0.5)
            
            self.detailLabel.text = "Please call our helpline for further information."
        }

    }
    
    @IBAction func restart(){
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
}
