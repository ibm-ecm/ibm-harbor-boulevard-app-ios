//
//  PageLicenseViewController.swift
//  HarborBoulevad
//
//  © Copyright IBM Corp. 2015 All rights reserved.
//

import UIKit
import IBMCaptureSDK

class PageLicenseViewController: PageViewController {
    
    // MARK: PageViewController
    
    // NOTE: this instance must be in scope until completion of processIDImage is called
    lazy var processor = ICPIDProcessor(ocrEngine: self.ocrEngine)
    
    var fields: [String] = []
    var values: [String] = []
    
    override func process(){
        super.process()
        
        if let page = self.page {
            
            processor.processIDPage(page, of: .usaDrivingLicense, withCompletion: { (data, _) in
                guard let drivingLicense = data as? ICPAAMVADrivingLicense else {
                    self.processFinished(false)
                    return
                }
                
                let keys: [ICPAAMVADrivingLicenseFieldKey] = [.DAC, .DAD]
                
                let mapping: [ICPAAMVADrivingLicenseFieldKey: String] = [.DAC: "First Name",
                                                                         .DAD: "Middle Name"]
                
                var fields: [String] = []
                var values: [String] = []
                
                for key in keys {
                    let licenseField = drivingLicense.field(for: key)
                    if let licenseField = licenseField,
                    let field = mapping[key] {
                        fields.append(field)
                        values.append(licenseField.value)
                    }
                }
                
                self.fields = fields
                self.values = values
                
                self.processFinished(true)
            })
            
        }
        
    }
    
    // MARK: UITableView Datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.page != nil ? self.fields.count : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "FieldCell") as! FieldCell
        
        let field = self.fields[indexPath.row]
        let value = self.values[indexPath.row]
        
        cell.configure(with: field, value)
        
        return cell
    }
}

extension FieldCell {
    func configure(with field: String, _ value: String){
        self.textField.delegate = self
        self.label.text = field
        self.textField.text = value
    }
}
