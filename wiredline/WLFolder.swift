//
//  WLFolder.swift
//  wiredline
//
//  Created by flidap on 2016/10/08.
//  Copyright © 2016 flidap. All rights reserved.
//

import UIKit
var fileaddress:[String]=Array()

var lastpath:String=String()

class WLFolder: UITableViewController,StreamDelegate {
    var appdel=UIApplication.shared.delegate as! AppDelegate
    let wifile:WiredFileSend=WiredFileSend()
    let wisend:WiredSend=WiredSend()
    var lastpath:String=String()
    let hlsend:HLSend=HLSend()
    var hlpathArray=[String]()
    @IBOutlet weak var filelist:UITableView?
    override func viewDidLoad() {
        super.viewDidLoad()
        lastpath=""
        NotificationCenter.default.addObserver(self, selector: #selector(fileListReload(_nf:)), name: NSNotification.Name(rawValue: recvDirNotif), object:nil)
        filearray.removeAll()
        typearray.removeAll()
        //lastpath="/Downloads"
        if wiredflag==1{
            wisend.getWiredFileList(str:lastpath)
        }else if hlflag==1{
            hlsend.HotlineGetFileList(hlpathArray)
        }
        //wireFileStream(fileaddress)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var cnt=0
            cnt = filearray.count
        return cnt
    }
    func fileListReload(_nf:Notification)
    {
        #if DEBUG
            print("filelist reload")
        #endif
        self.filelist?.reloadData()
        NotificationCenter.default.removeObserver(listreload)
    }
    func fileReload()
    {
        self.filelist?.reloadData()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        #if DEBUG
        print("tableView did Select")
        #endif
        
        if wiredflag==1{
            lastpath=lastpath+"/"+filearray[indexPath.row]
            wisend.getWiredFileList(str: lastpath)
        }else if hlflag==1{
            hlpathArray.append(filearray[indexPath.row])
            #if DEBUG
            print("path=",hlpathArray)
            #endif
            //hlsend.HLGetFileList(filearray[indexPath.row])
            self.tableView.deselectRow(at: [indexPath.row], animated: true)
            hlsend.HotlineGetFileList(hlpathArray)
        }
        
        filearray.removeAll()
        typearray.removeAll()
        fileReload()
        
    }
    
    
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var path=NSString(string: (Bundle.main.path(forResource: "hotwireAdditional", ofType: "bundle"))!).appendingPathComponent("UIIcons")
        let cell = tableView.dequeueReusableCell(withIdentifier: "filelistcell", for: indexPath)
        if wiredflag==1{
        if typearray[(indexPath as NSIndexPath).row]=="1" || typearray[(indexPath as NSIndexPath).row]=="3" || typearray[(indexPath as NSIndexPath).row]=="2"{
            path=Bundle.path(forResource: "Open Folder-38", ofType: "png", inDirectory: path)!
        }else if typearray[(indexPath as NSIndexPath).row]=="0"{
            path=Bundle.path(forResource: "File", ofType: "png", inDirectory: path)!
        }
        cell.textLabel!.text=filearray[(indexPath as NSIndexPath).row]
        cell.imageView?.image=UIImage(contentsOfFile: path)
        }else{
            #if DEBUG
            print("hlflag=folder")
                #endif
            if typearray[(indexPath as NSIndexPath).row]=="fldr"{
                #if DEBUG
                print("fldr")
                    #endif
                path=Bundle.path(forResource: "Open Folder-38", ofType: "png", inDirectory: path)!
                
            }
            cell.textLabel!.text=filearray[(indexPath as NSIndexPath).row]
            cell.imageView?.image=UIImage(contentsOfFile: path)
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
