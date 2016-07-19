//
//  ViewController.swift
//  HarborBoulevad
//
//  © Copyright IBM Corp. 2015 All rights reserved.
//

import UIKit

struct SampleDatacapConfiguration {
    @nonobjc static let url = "<IBM Datacap Server URL>"
    @nonobjc static let userName = "<IBM Datacap user name>"
    @nonobjc static let userPassword = "<IBM Datacap user password>"
    @nonobjc static let stationId = "<IBM Datacap station ID>"
    @nonobjc static let stationIndex:Int32 = 0 //Station Index related to that Id
    @nonobjc static let applicationName = "<IBM Datacap application>"
    @nonobjc static let workflowId = "<Application Workflow id>"
    @nonobjc static let workflowIndex:Int32 = 0 //Index related to the selected Application Workflow
    @nonobjc static let jobId = "<Workflow Job Id>"
    @nonobjc static let jobIndex:Int32 = 0 //Index related to the selected Workflow Job
    @nonobjc static let setupDCOName = "<Setup DCO configuration name>"
}

class MainViewController: BaseViewController {

    @IBOutlet weak var button1 : UIButton!
    @IBOutlet weak var button2 : UIButton!
    @IBOutlet weak var button3 : UIButton!
    
    let mainCapture = ICPCapture.instanceWithObjectFactoryType(ICPCaptureObjectFactoryType.NonPersistent)
    let credential = NSURLCredential(user: SampleDatacapConfiguration.userName, password: SampleDatacapConfiguration.userPassword, persistence: NSURLCredentialPersistence.None)
    
    lazy var datacapService : ICPDatacapService =
    {
        let service = self.mainCapture!.objectFactory!.datacapServiceWithBaseURL(NSURL(string: SampleDatacapConfiguration.url)!)
        service.allowInvalidCertificates = true
        service.station = self.capture.objectFactory?.stationWithStationId(SampleDatacapConfiguration.stationId, andIndex: SampleDatacapConfiguration.stationIndex, andDescription: "")
        service.application = self.capture.objectFactory?.applicationWithName(SampleDatacapConfiguration.applicationName)
        service.workflow = self.capture.objectFactory?.workflowWithWorkflowId(SampleDatacapConfiguration.workflowId, andIndex: SampleDatacapConfiguration.workflowIndex)
        service.job = self.capture.objectFactory?.jobWithJobId(SampleDatacapConfiguration.jobId, andIndex: SampleDatacapConfiguration.jobIndex)
        service.setupDCO = self.capture.objectFactory?.setupDCOWithName(SampleDatacapConfiguration.setupDCOName)
        return service
        }()
    
    var objectFactory : ICPPersistentObjectFactory? {
        get{
            return self.mainCapture!.objectFactory as? ICPPersistentObjectFactory
        }
    }
    
    override var batchType : ICPBatchType? {
        
        didSet {
            if self.batchType != nil{
                self.button2.enabled = true
            }
        }
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.capture = self.mainCapture
        self.serviceClient = self.mainCapture!.datacapSessionManagerForService(self.datacapService, withCredential: self.credential)
        
        self.fetchBatchType()
    }

    
    // MARK: Private methods
    
    @IBAction private func login(){
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Logging in"
        
        self.serviceClient.downloadBatchTypeWithSetup(self.datacapService.setupDCO!) { (success, result, error) -> Void in
            if let batchTypeResponse = result {
                self.batchType = batchTypeResponse
                self.objectFactory?.save()
            }else{
                self.showLoginError(error?.localizedDescription)
            }
            
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
        }
    }
    
    private func fetchBatchType() {
        
        let batches = self.objectFactory!.fetchAllProtocolObjects(ICPBatchType.self)
        if let fetchedObjects = batches as? [ICPBatchType]{
            if fetchedObjects.count > 0 {
                if let lastBatchType = fetchedObjects.first{
                    self.batchType = lastBatchType
                }
            }
        }
        
    }
    
    private func showLoginError(errorMessage : String?)
    {
        if let message = errorMessage{
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
}

