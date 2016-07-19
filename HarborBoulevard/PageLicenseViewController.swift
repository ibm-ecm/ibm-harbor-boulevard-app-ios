//
//  PageLicenseViewController.swift
//  HarborBoulevad
//
//  © Copyright IBM Corp. 2015 All rights reserved.
//

import UIKit

class PageLicenseViewController: PageViewController {
    
    // MARK: PageViewController
    
    override func process(){
        
    }
    
    // dont show any fields
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
