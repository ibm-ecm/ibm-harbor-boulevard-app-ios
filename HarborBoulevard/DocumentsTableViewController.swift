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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if let uploadViewController = segue.destination as? UploadViewController{
            uploadViewController.success = sender as! Bool
        }else if let navigationController = segue.destination as? UINavigationController{
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
            let alert = UIAlertController(title: "Missing information", message: "Some documents appeared to not be valid, please review the documents provided", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: UITableView Datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.document?.pages.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "PageCell") as! PageCell
        
        if let page = self.document?.pages[indexPath.section]{
            cell.configureWithPage(page, error: page.isValid().message)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let page = self.document?.pages[indexPath.section]{
            if page.type?.typeId == "Form"{
                self.performSegue(withIdentifier: "recaptureForm", sender: page)
            }else if page.type?.typeId == "Driver License"{
                self.performSegue(withIdentifier: "recaptureLicense", sender: page)
            }else if page.type?.typeId == "Check"{
                self.performSegue(withIdentifier: "recaptureCheck", sender: page)
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
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.labelText = "Uploading batch"
        hud?.mode = .determinateHorizontalBar
        hud?.progress = 0.1
        
        
        let serviceClientProgressionBlock : ICPSessionManagerUpdateProgess = { (progress : Float, uploadingObject : Any?) -> Void in
            hud?.labelText = "Uploading..."
            hud?.progress = 0.6
            print(progress)
        }
        
        self.serviceClient.uploadBatch(self.batch, withProgressBlock: serviceClientProgressionBlock, andCompletion: { (success : Bool, results : Any?, error: Error?) -> Void in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.performSegue(withIdentifier: "next", sender: (error == nil))
        })
    }

}
