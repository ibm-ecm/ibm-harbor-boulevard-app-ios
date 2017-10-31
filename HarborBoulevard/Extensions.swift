//
//  Extensions.swift
//  HarborBoulevad
//
//  © Copyright IBM Corp. 2015 All rights reserved.
//

extension ICPPage{

    func fieldWithType(_ typeId : String) -> ICPField?{
        
        let filtered = self.fields.filter({ (field : ICPField) -> Bool in
            return field.type!.typeId == typeId
        })
        return filtered.first
    }
    
    func isValid() -> (valid : Bool, message : String?){
        
        if(self.type?.typeId == "Check"){
            if let field = self.fieldWithType("Signature"){
                if let signature = field.value as? String{
                    if signature.characters.count == 0{
                        return (false, "Check is missing signature")
                    }
                }
            }
        }
        
        return (true, nil)
    
    }
    
    func ocrZonesAsNSValues() -> [NSValue] {
        
        var zones : [NSValue] = []
        
        for i in 0 ..< fields.count {
            let field = self.fields[i]
            if let fieldType = field.type as? ICPFieldType{
                let zone = fieldType.position()
                let value = NSValue(cgRect: zone)
                zones.append(value)
            }
        }
        
        return zones
        
    }
    
}

extension ICPPageType {
    func referenceSize() -> CGSize{
        return CGSize(width: self.referencePageWidth, height: self.referencePageHeight)
    }
}

extension ICPBatchType{
    func pageTypeWithType(_ typeId : String) -> ICPPageType? {
        
        for documentType in self.documentTypes{
            for pageType in documentType.pageTypes{
                if pageType.typeId == typeId {
                    return pageType
                }
            }
        }

        return nil
    }
}

extension ICPBatch{
    func pageWithType(_ typeId : String) -> ICPPage?{
        if let document = self.documents.first{
            for page in document.pages{
                if page.type?.typeId == typeId{
                    return page
                }
            }
        }
        return nil
    }
}

extension ICPFieldType {
    func scaledZone(_ refSize : CGSize, actualSize : CGSize) -> CGRect {
        let position = self.position()
        return position.proportionalRect(fromImageSize: refSize, toImageSize: actualSize)
    }
    
    func position() -> CGRect {
        var fieldDCODictionary: [AnyHashable: Any] = self.dcoDictionary!
        
        if let positionString: String = fieldDCODictionary["Default_Position"] as? String{
            var rectComponents: [String] = positionString.components(separatedBy: ",")
            if rectComponents.count == 4 {
                let float0: CGFloat = CGFloat((rectComponents[0] as NSString).floatValue)
                let float1: CGFloat = CGFloat((rectComponents[1] as NSString).floatValue)
                let float2: CGFloat = CGFloat((rectComponents[2] as NSString).floatValue)
                let float3: CGFloat = CGFloat((rectComponents[3] as NSString).floatValue)
                let relativeRect: CGRect = CGRect(x: float0, y: float1, width: float2 - float0, height: float3 - float1)
                return relativeRect
            }
        }
        return CGRect.zero
    }
}

extension UIImageView {
    func addOcrZones(_ fields: [ICPField], refSize : CGSize) {
        
        let scaleFactor = self.image!.size.width / self.image!.size.height
        
        var xOffset : CGFloat = 0.0
        var yOffset : CGFloat = 0.0
        var width : CGFloat = 0.0
        var height : CGFloat = 0.0
        
        if scaleFactor > 1.0{
            width = self.frame.size.width
            height = width / scaleFactor
            yOffset = (self.frame.size.height - height) / 2
        }else{
            height = self.frame.size.height
            width = scaleFactor * height
            xOffset = (self.frame.size.width - width) / 2
        }
        
        for property in fields{
            let fieldType = property.type as! ICPFieldType
            let rect: CGRect = fieldType.scaledZone(refSize, actualSize: CGSize(width: width, height: height))
            if !rect.equalTo(CGRect.zero) {
                let view: UIView = UIView(frame: CGRect(x: rect.origin.x + xOffset, y: rect.origin.y + yOffset, width: rect.size.width, height: rect.size.height))
                view.layer.borderColor = self.tintColor.cgColor
                view.layer.borderWidth = 0.5
                self.addSubview(view)
            }
        }
    }
}

extension CGRect {
    func proportionalRect(fromImageSize referenceImageSize: CGSize, toImageSize imageSize: CGSize) -> CGRect {
        if referenceImageSize.equalTo(imageSize) {
            return self
        }
        let x: CGFloat = (self.origin.x / referenceImageSize.width) * imageSize.width
        let y: CGFloat = (self.origin.y / referenceImageSize.height) * imageSize.height
        let w: CGFloat = (self.size.width / referenceImageSize.width) * imageSize.width
        let h: CGFloat = (self.size.height / referenceImageSize.height) * imageSize.height
        return CGRect(x: x, y: y, width: w, height: h)
    }
}

extension UIColor{
    
    class func ibmColor() -> UIColor{
        return UIColor(red: 70/255, green: 107/255, blue: 176/255, alpha: 1.0)
    }
    
    class func themeColor() -> UIColor{
        return UIColor.ibmColor()
    }
    
}
