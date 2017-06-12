//
//  Bookmarks.swift
//  wiredline
//
//  Created by HiraoKazumasa on 10/18/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity


class Bookmarks: UIViewController,UITableViewDelegate,UITableViewDataSource,WCSessionDelegate {
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {

    }

    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }

    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    fileprivate var servername: [String]=Array()
    fileprivate var loginnames:[String]=Array()
    fileprivate var passwords:[String]=Array()
    fileprivate var addresses:[String]=Array()
    fileprivate var bookmarkinfo:[String]=Array()
    fileprivate var wiredflags:[String]=Array()
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var toConnect:UIButton!
    @IBOutlet weak var addbookmark:UIBarButtonItem!
    //var session:WCSession!
    override func viewDidLoad() {
        super.viewDidLoad()
        #if BOOKMARKDEBUG
        print("bookmark")
        #endif
        self.navigationItem.title="Bookmarks"
        self.fetchBookmarkData()
        myTableView.dataSource=self
        myTableView.delegate=self
        NotificationCenter.default.addObserver(self, selector: #selector(Bookmarks.callChatwindow(_:)), name: NSNotification.Name(rawValue: callchatwindow), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Bookmarks.callNewConnectionwindow(_:)), name: NSNotification.Name(rawValue: callnewconnectionwindow) , object: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        myTableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func callNewConnectionwindow(_ notif:Notification)
    {
        //print("callchat")
        OperationQueue.main.addOperation(){
            //var newcon:NewConnect=NewConnect()
            
        }
        NotificationCenter.default.removeObserver(callnewconnectionwindow)
    }
    @objc func callChatwindow(_ notif:Notification)
    {
        //print("callchat")
        OperationQueue.main.addOperation(){
            self.tabBarController!.selectedIndex = 1;
        }
        NotificationCenter.default.removeObserver(callchatwindow)
    }
    func fetchBookmarkData() {
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let Context: NSManagedObjectContext = appDel.managedObjectContext
        let workRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmarks")
        var i:Int=0
        //myItems=Array()
        workRequest.returnsObjectsAsFaults = false
        do{
            let results = try Context.fetch(workRequest)
            for data in results   {
                var test:Any
                test=(((data as Any)) as AnyObject).value(forKey: "servername")!
                servername.insert(test as! String, at: i)
                test=(data as AnyObject).value(forKey: "address")!
                addresses.insert(test as! String, at: i)
                test=(data as AnyObject).value(forKey: "loginname")!
                loginnames.insert(test as! String, at: i)
                test=(data as AnyObject).value(forKey: "password")!
                passwords.insert(test as! String, at: i)
                test=(data as AnyObject).value(forKey: "wiredflags")!
                wiredflags.insert(test as! String, at: i)
                i+=1
            }
        }catch{
            print("coredata error")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        bookmarkinfo=Array()
        bookmarkinfo.insert(addresses[(indexPath as NSIndexPath).row], at: 0)
        bookmarkinfo.insert(loginnames[(indexPath as NSIndexPath).row], at: 1)
        bookmarkinfo.insert(passwords[(indexPath as NSIndexPath).row], at: 2)
        bookmarkinfo.insert(wiredflags[(indexPath as NSIndexPath).row], at:3)
        /*var newcon=NewConnect()
        newcon.tempaddress=bookmarkinfo[0]
        newcon.templogin=bookmarkinfo[1]
        newcon.temppasswd=bookmarkinfo[2]
*/
        performSegue(withIdentifier: "pushnewcon", sender: tableView)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier=="pushnewcon"){
            let con:NewConnect=segue.destination as! NewConnect
            if(bookmarkinfo .isEmpty){
                con.tempaddress=""
            }else{
                con.tempaddress=bookmarkinfo[0]
                con.templogin=bookmarkinfo[1]
                con.temppasswd=bookmarkinfo[2]
                con.tempflag=bookmarkinfo[3]
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servername.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 再利用するCellを取得する.
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        
        // Cellに値を設定する.
        cell.textLabel!.text = servername[(indexPath as NSIndexPath).row]
        if(wiredflags[(indexPath as NSIndexPath).row]=="1"){
            cell.detailTextLabel?.text="Wired Server"
            cell.detailTextLabel?.textColor=UIColor.gray
        }else if(wiredflags[(indexPath as NSIndexPath).row]=="0"){
            cell.detailTextLabel?.text="Hotline Server"
            cell.detailTextLabel?.textColor=UIColor.gray
        }
        return cell
    }
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let editname:String;()
        if editingStyle == UITableViewCellEditingStyle.delete {
            editname=servername[(indexPath as NSIndexPath).row]
            #if DEBUG
                print("deleting ",editname)
                #endif
            servername.remove(at: (indexPath as NSIndexPath).row)
            loginnames.remove(at: (indexPath as NSIndexPath).row)
            passwords.remove(at: (indexPath as NSIndexPath).row)
            addresses.remove(at: (indexPath as NSIndexPath).row)
            deleteBookamark(editname)
            myTableView.reloadData()
        }
    }
    func deleteBookamark(_ name:String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        let entityDiscription = NSEntityDescription.entity(forEntityName: "Bookmarks", in: managedObjectContext)
        let fetchRequest=NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmarks")
        fetchRequest.entity = entityDiscription;
        let predicate = NSPredicate(format: "%K = %@","servername", name)
        fetchRequest.predicate = predicate
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            for managedObject in results {
                let table = managedObject
                managedObjectContext.delete(table as! NSManagedObject)
            }
        } catch {
            print("error in delete_data()")
        }
        appDelegate.saveContext()
        myTableView.reloadData()
    }
    @IBAction func saveBookmark(_ sender:UIBarButtonItem)
    {
        let appDelegate:AppDelegate=UIApplication.shared.delegate as! AppDelegate
        let managedContext:NSManagedObjectContext=appDelegate.managedObjectContext
        let entity=NSEntityDescription.entity(forEntityName: "Bookmarks", in: managedContext)
        let bookmarkobj=NSManagedObject(entity: entity!, insertInto: managedContext)
        
        if(serverinfoarray.isEmpty){
                let alertController = UIAlertController(title: "WiredLine Alert", message: "登録するには、サーバーにログインしてください。", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                present(alertController, animated: true, completion: nil)
        }else{
            print("serverinfoarray=\(serverinfoarray)")
            
            bookmarkobj.setValue(logininfo[0], forKey: "loginname")
            bookmarkobj.setValue(logininfo[1], forKey: "password")
            bookmarkobj.setValue(addressinfo, forKey: "address")
            bookmarkobj.setValue(serverinfoarray[2], forKey: "servername")
            bookmarkobj.setValue(String(wiredflag), forKey: "wiredflags")
            
            do{
                try managedContext.save()
            }catch{
                
            }
            servername=Array()
            fetchBookmarkData()
            myTableView.reloadData()
            
        }
        
        
    }
    
    

}
