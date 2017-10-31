//
//  PageViewController.swift
//  HarborBoulevad
//
//  © Copyright IBM Corp. 2015 All rights reserved.
//

import UIKit

class PageViewController: UITableViewController {
    
    var batchType : ICPBatchType!
    var capture : ICPCapture!
    var batch : ICPBatch!
    var processCompleted : Bool = false
    var serviceClient : ICPSessionManager!
    var page : ICPPage!
    
    var progressMessage : String { get { return "Processing" }}
    
    var image : UIImage? {
        get{
            if let image = self.page.modifiedImage{
                return image
            }
            return nil
        }
    }
    lazy var ocrEngine : ICPOcrEngine = {
        let path = Bundle.main.bundlePath
        return ICPTesseractOcrEngine(tessDataPrefixes: ["eng"], andTessdataAbsolutePath: path)
    }()
    
    lazy var hud : MBProgressHUD = { return MBProgressHUD.showAdded(to: self.view, animated: true) }()
    
    lazy var refSize : CGSize = {
        
        guard let pageType : ICPPageType = self.page.type as? ICPPageType else {
            return CGSize.zero
        }
        
        return pageType.referenceSize()
    }()
    
    @IBOutlet weak var headerImageView : UIImageView!
    
    @IBAction func done(){
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = self.image{
            self.headerImageView.image = image
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.processCompleted == false {
            self.process()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if let cameraViewController = segue.destination as? CameraViewController{
            cameraViewController.batchType = self.batchType
            cameraViewController.capture = self.capture
            cameraViewController.batch = self.batch
            cameraViewController.serviceClient = self.serviceClient
        } else if let documentsViewController = segue.destination as? DocumentsTableViewController{
            documentsViewController.capture = self.capture
            documentsViewController.batch = self.batch
            documentsViewController.serviceClient = self.serviceClient
            documentsViewController.batchType = self.batchType
        }
    }
    
    // MARK: Public functions
    
    func process(){
        self.hud.labelText = self.progressMessage
    }
    
    func processFinished(_ success : Bool){
        DispatchQueue.main.async(execute: {
            self.processCompleted = true
            self.tableView.reloadData()
            self.hud.hide(true)
        })
    }
    
    // MARK: UITableView Datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.page != nil ? self.page!.fields.count : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "FieldCell") as! FieldCell
        
        if let field = self.page?.fields[indexPath.row] {
            cell.configureWithField(field)
        }
        
        return cell
    }
    
}
