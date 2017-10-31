//
//  PageCheckViewController.swift
//  HarborBoulevad
//
//  © Copyright IBM Corp. 2015 All rights reserved.
//

import UIKit

class PageCheckViewController: PageViewController {
    
    override var progressMessage : String { get { return "Validating signature" }}
    
    let applyBlackAndWhiteFilter = true
 
    lazy var signatureField : ICPField? =
    {
        return self.page!.fieldWithType("Signature")
        
        }()
    
    // MARK: PageViewController
    
    override func process() {
        super.process()
        
        if let field = self.signatureField {
            
            self.headerImageView.addOcrZones([field], refSize: self.refSize)
            
            if applyBlackAndWhiteFilter == true{
                let imageEngine = ICPCoreImageImageEngine()
                
                imageEngine.rotate(toRightImage: self.image!, completionBlock: { (image : UIImage?) -> Void in
                    
                    imageEngine.apply(ICPFilterType.blackAndWhite, to: self.image!, completionBlock: { (image : UIImage?) -> Void in
                        
                        if let blackAndWhiteCheck = image {
                            self.ocrCheck(field, image: blackAndWhiteCheck)
                        }
                        
                    })
                    
                })
                
                
            }else{
                self.ocrCheck(field, image: self.image!)
            }
        }else{
            self.processFinished(false)
        }
    }
    
    private func ocrCheck(_ field : ICPField, image : UIImage){
        if let signatureFieldType = field.type as? ICPFieldType{
            let zone = signatureFieldType.scaledZone(self.refSize, actualSize: image.size)
            
            let textRecognizedBlock : ICPOcrEngineTextRecognizedBlock = { (image : UIImage, text : String, metadata: [String : [Any]]) -> Void in
                print("found signature: \(text)")
                field.value = text
                self.processFinished(true)
            }
            
            self.ocrEngine.recognizeText(in: image, with: zone, whitelist: nil, highlightChars: false, completionBlock: textRecognizedBlock)
        }
    }
}
