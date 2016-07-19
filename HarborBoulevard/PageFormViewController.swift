//
//  PageFormViewController.swift
//  HarborBoulevad
//
//  © Copyright IBM Corp. 2015 All rights reserved.
//

import UIKit

class PageFormViewController: PageViewController {
    
    override var progressMessage : String { get { return "Reading fields" }}
    
    // MARK: PageViewController
    
    override func process(){
        super.process()
        
        if let page = self.page {
            self.headerImageView.addOcrZones(page.fields, refSize: self.refSize)
            
            let zones = page.ocrZonesAsNSValues()
            
            self.ocrEngine.recognizeTextsInImage(self.image!, withImageSize: self.refSize, withRects: zones, whitelist: nil, completionBlock: { (texts : [String], metadatas : [[String : [AnyObject]]]) -> Void in
                
                for i in 0 ..< texts.count{
                    let field = page.fields[i]
                    field.value = texts[i]
                }
                
                self.processFinished(true)
            })
            
        }
        
    }
    
    
}
