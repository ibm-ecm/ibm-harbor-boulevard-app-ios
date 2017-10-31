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
        
        if let page = self.capture?.objectFactory!.page(with: self.document, type: self.pageType){
            page.modifiedImage = self.image
            page.originalImage = self.image
            page.status = .queued
            return page
        }
        return nil
        
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.batch == nil{
            if let newBatch = self.capture?.objectFactory!.batch(with: self.service, type: self.batchType){
                newBatch.status = .queued
                if let documentType = self.batchType?.documentTypes.first{
                    self.capture?.objectFactory!.document(with: newBatch, type: documentType)
                }
                self.batch = newBatch
            }
        }
        
        self.cameraView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.cameraView.restartPreview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.cameraView.stopPreview()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if let pageViewController = segue.destination as? PageViewController{
            pageViewController.batchType = self.batchType
            pageViewController.capture = self.capture
            pageViewController.batch = self.batch
            pageViewController.serviceClient = self.serviceClient
            if self.page != nil{
                pageViewController.page = self.page
            }
        } else if let cameraViewController = segue.destination as? CameraViewController{
            cameraViewController.batchType = self.batchType
            cameraViewController.capture = self.capture
            cameraViewController.batch = self.batch
            cameraViewController.serviceClient = self.serviceClient
        }
    }
    
    // MARK: ICPCameraViewDelegate
    
    func cameraView(_ cameraView: ICPCameraView, didTakeOriginalPhoto originalPhoto: UIImage?, modifiedPhoto: UIImage?) {
        self.imageCaptured(modifiedPhoto!)
    }
    
    func cameraViewDidDetectDocument(_ cameraView: ICPCameraView){
        self.cameraView.takePhoto()
    }
    
    // MARK: Public methods
    
    func imageCaptured(_ image: UIImage){
        self.page?.modifiedImage = image
        self.performSegue(withIdentifier: "next", sender: self)
    }

}
