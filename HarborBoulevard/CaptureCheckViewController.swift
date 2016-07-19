//
//  CaptureCheckViewController.swift
//  HarborBoulevad
//
//  © Copyright IBM Corp. 2015 All rights reserved.
//

import UIKit

class CaptureCheckViewController: CameraViewController {

    override var pageTypeName : String {
        get{
            return "Check"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if TARGET_IPHONE_SIMULATOR == 1 && self.image == nil {
            self.imageCaptured(UIImage(named: "check-filled.png")!)
        }
    }

}
