//
//  PageCell.swift
//  HarborBoulevad
//
//  © Copyright IBM Corp. 2015 All rights reserved.
//

import UIKit

class PageCell: UITableViewCell {

    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var subLabel : UILabel!
    @IBOutlet weak var thumbnailImageView : UIImageView!
    
    func configureWithPage(_ page : ICPPage, error : String?){
        self.label.text = page.type!.typeId
        self.subLabel.text = error ?? "Success"
        self.subLabel.textColor = error != nil ? .red : .green
        self.thumbnailImageView.image = page.thumbnailImage
    }
    
}
