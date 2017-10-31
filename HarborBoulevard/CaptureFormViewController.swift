//
//  CaptureFormViewController.swift
//  HarborBoulevad
//
//  © Copyright IBM Corp. 2015 All rights reserved.
//

import UIKit

class CaptureFormViewController: CameraViewController {

    override var pageTypeName : String {
        get{
            return "Form"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if TARGET_IPHONE_SIMULATOR == 1 && self.image == nil{
            self.imageCaptured(UIImage(named: "Form.png")!)
        }
    }
}
