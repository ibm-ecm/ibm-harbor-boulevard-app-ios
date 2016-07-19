//
//  CaptureLicenseViewController.swift
//  HarborBoulevad
//
//  © Copyright IBM Corp. 2015 All rights reserved.
//

import UIKit

class CaptureLicenseViewController: CameraViewController {

    override var pageTypeName : String {
        get{
            return "Driver License"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if TARGET_IPHONE_SIMULATOR == 1 && self.image == nil{
            self.imageCaptured(UIImage(named: "License.png")!)
        }
    }
    
}
