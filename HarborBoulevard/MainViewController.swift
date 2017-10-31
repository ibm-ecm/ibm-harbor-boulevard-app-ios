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
    
    let mainCapture = ICPCapture.instance(with: .nonPersistent)
    let credential = URLCredential(user: SampleDatacapConfiguration.userName, password: SampleDatacapConfiguration.userPassword, persistence: .none)
    
    lazy var datacapService : ICPDatacapService =
    {
        let service = self.mainCapture!.objectFactory!.datacapService(withBaseURL: URL(string: SampleDatacapConfiguration.url)!)
        service.allowInvalidCertificates = true
        service.station = self.capture.objectFactory?.station(withStationId: SampleDatacapConfiguration.stationId, andIndex: SampleDatacapConfiguration.stationIndex, andDescription: "")
        service.application = self.capture.objectFactory?.application(withName: SampleDatacapConfiguration.applicationName)
        service.workflow = self.capture.objectFactory?.workflow(withWorkflowId: SampleDatacapConfiguration.workflowId, andIndex: SampleDatacapConfiguration.workflowIndex)
        service.job = self.capture.objectFactory?.job(withJobId: SampleDatacapConfiguration.jobId, andIndex: SampleDatacapConfiguration.jobIndex)
        service.setupDCO = self.capture.objectFactory?.setupDCO(withName: SampleDatacapConfiguration.setupDCOName)
        
        return service
        }()
    
    var objectFactory : ICPPersistentObjectFactory? {
        get{
            return self.mainCapture!.objectFactory as? ICPPersistentObjectFactory
        }
    }
    
    lazy var datacapHelper:ICPDatacapHelper = { [unowned self] in
        let datacapHelper = ICPDatacapHelper(datacapService: self.datacapService, objectFactory: self.capture.objectFactory!, credential: self.credential)
        return datacapHelper
        }()
    
    override var batchType : ICPBatchType? {
        
        didSet {
            if self.batchType != nil{
                self.button2.isEnabled = true
            }
        }
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.capture = self.mainCapture
        self.serviceClient = self.mainCapture!.datacapSessionManager(for: self.datacapService, with: self.credential)
        
        self.fetchBatchType()
    }

    
    // MARK: Private methods
    
    @IBAction private func login(){
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.labelText = "Logging in"
        
        self.serviceClient.downloadBatchType(withSetup: self.datacapService.setupDCO!) { (success, result, error) -> Void in
            if let batchTypeResponse = result {
                self.batchType = batchTypeResponse
                self.objectFactory?.save()
                self.listConfigurations()
            }else{
                self.showLoginError(error?.localizedDescription)
            }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            
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
    
    private func showLoginError(_ errorMessage : String?)
    {
        if let message = errorMessage{
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}

extension MainViewController {
    
    fileprivate func listConfigurations() {
        
        self.datacapHelper.getApplicationList { (success, applications, error) in
            guard success else {
                return
            }
            
            for application in applications {
                print("application name: \(application.name)")
            }
        }
        
        guard let application = self.datacapService.application else {
            return
        }
        
        self.datacapHelper.getStationList(for: application) { (success, stations, error) in
            guard success,
                let stations = stations else {
                    return
            }
            
            for station in stations {
                print("station id: \(station.stationId)")
            }
        }
        
        self.datacapHelper.getWorkflowList(for: application) { (success, workflows, error) in
            guard success,
                let workflows = workflows else {
                    return
            }
            
            for workflow in workflows {
                print("workflow id: \(workflow.workflowId)")
            }
        }
        
        guard let workflow = self.datacapService.workflow else {
            return
        }
        
        self.datacapHelper.getJobList(for: application, workflow: workflow) { (success, jobs, error) in
            guard success,
                let jobs = jobs else {
                    return
            }
            
            for job in jobs {
                print("job id: \(job.jobId)")
            }
        }
        
        self.datacapHelper.getSetupDCOs(for: application) { (success, setupDCOs, error) in
            guard success,
                let setupDCOs = setupDCOs else {
                    return
            }
            
            
            for setupDCO in setupDCOs {
                print("setup DCO name: \(setupDCO.name)")
            }
        }
    }
}

