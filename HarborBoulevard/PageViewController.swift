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
    var ocrCompleted : Bool = false
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
        let path = NSBundle.mainBundle().bundlePath
        return ICPTesseractOcrEngine(tessDataPrefixes: ["eng"], andTessdataAbsolutePath: path)
    }()
    
    lazy var hud : MBProgressHUD = { return MBProgressHUD.showHUDAddedTo(self.view, animated: true) }()
    
    lazy var refSize : CGSize = {
        
        guard let pageType : ICPPageType = self.page.type as? ICPPageType else {
            return CGSizeZero
        }
        
        return pageType.referenceSize()
    }()
    
    @IBOutlet weak var headerImageView : UIImageView!
    
    @IBAction func done(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = self.image{
            self.headerImageView.image = image
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.ocrCompleted == false {
            self.process()
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let cameraViewController = segue.destinationViewController as? CameraViewController{
            cameraViewController.batchType = self.batchType
            cameraViewController.capture = self.capture
            cameraViewController.batch = self.batch
            cameraViewController.serviceClient = self.serviceClient
        } else if let documentsViewController = segue.destinationViewController as? DocumentsTableViewController{
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
    
    func processFinished(success : Bool){
        dispatch_async(dispatch_get_main_queue(), {
            self.ocrCompleted = true
            self.tableView.reloadData()
            self.hud.hide(true)
        })
    }
    
    // MARK: UITableView Datasource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.page != nil ? self.page!.fields.count : 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("FieldCell") as! FieldCell
        
        if let field = self.page?.fields[indexPath.row] {
            cell.configureWithField(field)
        }
        
        return cell
    }
    
}
