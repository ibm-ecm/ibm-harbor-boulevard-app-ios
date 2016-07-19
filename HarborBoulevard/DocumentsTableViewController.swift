//
//  DocumentsTableViewController.swift
//  HarborBoulevad
//
//  © Copyright IBM Corp. 2015 All rights reserved.
//

import UIKit

class DocumentsTableViewController: UITableViewController {

    var batch : ICPBatch!
    var batchType : ICPBatchType!
    var capture : ICPCapture!
    var serviceClient : ICPSessionManager!
    
    lazy var document : ICPDocument? =
    {
        return self.batch.documents.first
        }()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let uploadViewController = segue.destinationViewController as? UploadViewController{
            uploadViewController.success = sender as! Bool
        }else if let navigationController = segue.destinationViewController as? UINavigationController{
            if let cameraViewController = navigationController.viewControllers[0] as? CameraViewController{
                
                if let page = sender as? ICPPage{
                    cameraViewController.page = page
                    cameraViewController.capture = self.capture
                    cameraViewController.batchType = self.batchType
                }
                
            }
        }
    }

    @IBAction func upload(){
        if self.allDocumentsAreValid() == true{
            self.uploadBatch()
        }else{
            let alert = UIAlertController(title: "Missing information", message: "Some documents appeared to not be valid, please review the documents provided", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: UITableView Datasource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.document?.pages.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("PageCell") as! PageCell
        
        if let page = self.document?.pages[indexPath.section]{
            cell.configureWithPage(page, error: page.isValid().message)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let page = self.document?.pages[indexPath.section]{
            if page.type?.typeId == "Form"{
                self.performSegueWithIdentifier("recaptureForm", sender: page)
            }else if page.type?.typeId == "Driver License"{
                self.performSegueWithIdentifier("recaptureLicense", sender: page)
            }else if page.type?.typeId == "Check"{
                self.performSegueWithIdentifier("recaptureCheck", sender: page)
            }
        }
        
    }
    
    // MARK: Private functions
    
    private func allDocumentsAreValid() -> Bool{

        if let pages = self.document?.pages{
            for page in pages{
                if page.isValid().valid == false{
                    return false
                }
            }
        }
        return true
    }
    
    private func uploadBatch(){
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Uploading batch"
        hud.mode = MBProgressHUDMode.DeterminateHorizontalBar
        
        var pageIndex = 1
        
        let serviceClientProgressionBlock : ICPSessionManagerUpdateProgess = { (progress : Float, uploadingObject : AnyObject?) -> Void in
            
            if uploadingObject is ICPPage{
                hud.labelText = "Uploading page \(pageIndex)/3"
                if progress > 1.0 {
                    pageIndex += 1
                }
            }
            
            print("\(progress)")
            hud.progress = progress
        }
        
        self.serviceClient.uploadBatch(self.batch, withProgressBlock: serviceClientProgressionBlock, andCompletion: { (success : Bool, results : AnyObject?, error: NSError?) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.performSegueWithIdentifier("next", sender: (error == nil))
        })
    }

}
