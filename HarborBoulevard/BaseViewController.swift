//
//  BaseViewController.swift
//  HarborBoulevad
//
//  © Copyright IBM Corp. 2015 All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var batchType : ICPBatchType!
    var capture : ICPCapture!
    var serviceClient : ICPSessionManager!
    var service : ICPDatacapService!
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if let baseViewController = segue.destination as? BaseViewController{
            baseViewController.batchType = self.batchType
            baseViewController.capture = self.capture
            baseViewController.serviceClient = self.serviceClient
            baseViewController.service = self.service
        }
    }
    
}
