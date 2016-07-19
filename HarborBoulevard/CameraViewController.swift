//
//  CameraViewController.swift
//  HarborBoulevad
//
//  © Copyright IBM Corp. 2015 All rights reserved.
//

import UIKit

class CameraViewController: BaseViewController, ICPCameraViewDelegate {
    
    var image : UIImage?
    var batch : ICPBatch!
    var pageTypeName : String {
        get{
            return ""
        }
    }
    
    @IBOutlet weak var cameraView : ICPCameraView!

    lazy var document : ICPDocument? = { return self.batch.documents.first }()
    
    lazy var pageType : ICPPageType? = { return self.batchType.pageTypeWithType(self.pageTypeName) }()
    
    lazy var page : ICPPage? =
    {
        
        if let page = self.capture?.objectFactory!.pageWithDocument(self.document, type: self.pageType){
            page.modifiedImage = self.image
            page.originalImage = self.image
            page.status = ICPStatus.Queued
            return page
        }
        return nil
        
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.batch == nil{
            if let newBatch = self.capture?.objectFactory!.batchWithService(self.service, type: self.batchType){
                newBatch.status = ICPStatus.Queued
                if let documentType = self.batchType?.documentTypes.first{
                    self.capture?.objectFactory!.documentWithBatch(newBatch, type: documentType)
                }
                self.batch = newBatch
            }
        }
        
        self.cameraView.delegate = self
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.cameraView.restartPreview()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.cameraView.stopPreview()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let pageViewController = segue.destinationViewController as? PageViewController{
            pageViewController.batchType = self.batchType
            pageViewController.capture = self.capture
            pageViewController.batch = self.batch
            pageViewController.serviceClient = self.serviceClient
            if self.page != nil{
                pageViewController.page = self.page
            }
        }
    }
    
    // MARK: ICPCameraViewDelegate
    
    func cameraView(cameraView: ICPCameraView, didTakeOriginalPhoto originalPhoto: UIImage?, modifiedPhoto: UIImage?) {
        self.imageCaptured(modifiedPhoto!)
    }
    
    func cameraViewDidDetectDocument(cameraView: ICPCameraView){
        self.cameraView.takePhoto()
    }
    
    // MARK: Public methods
    
    func imageCaptured(image: UIImage){
        self.page?.modifiedImage = image
        self.performSegueWithIdentifier("next", sender: self)
    }

}
