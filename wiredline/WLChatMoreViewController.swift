//
//  WLChatMoreViewController.swift
//  wiredline
//
//  Created by HiraoKazumasa on 1/11/16.
//  Copyright © 2016 flidap. All rights reserved.
//

import UIKit
import CloudKit
var userIndex=String()
var userrow=Int()

class WLChatMoreViewController: WLChat{
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var wiredsend=WiredSend()
        override func viewDidLoad() {
        super.viewDidLoad()
        print("chatmoreView")
        NotificationCenter.default.addObserver(self, selector: #selector(self.userinfoset(_:)), name: NSNotification.Name(rawValue: setuserinfo), object: nil)
        //newsText?.resignFirstResponder()
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "showwirednews:", name: getnewsdone, object:nil)

        // Do any additional setup after loading the view.
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 50
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?=UITableViewCell()
        cell=UITableViewCell(style: .subtitle, reuseIdentifier: "tranferlist")
        cell?.textLabel?.text="test"
        return cell!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //newsText?.isFirstResponder()
    }
    @IBAction func pushedstealIconButton(sender:UIButton)
    {
        #if DEBUG
        print("steal IconButton")
        #endif
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let directoryName = "icons"  // 作成するディレクトリ名
        let createPath = documentsPath + "/" + directoryName
        let manager = FileManager.default
        var list=Array<String>()
        var cnt:Int
        cnt=0
        do{
        try list = manager.contentsOfDirectory(atPath: createPath)
        }catch{
            
        }
        cnt=list.count
        var data=Data(base64Encoded: image[userrow] as String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
        let iimage=UIImage(data: data)!
        data=UIImagePNGRepresentation(iimage)!
        let fullpath=createPath+"/"+"icons"+String(cnt)+".png"
        manager.createFile(atPath: fullpath as String, contents: data, attributes: nil)
        let manager1 = FileManager()
        //var icloudURL:URL
        if var icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.flipware.wiredline"){
            #if DEBUG
            print("iCloud is available. \(icloudURL)")
                #endif
            icloudURL=icloudURL.appendingPathComponent("Documents/icons/")
            #if DEBUG
                
                print(icloudURL)
                #endif
            //do{
                //try manager1.copyItem(atPath: fullpath, toPath: icloudURL.path + String(cnt)+".png")
                manager1.createFile(atPath: icloudURL.path+"/"+"icons"+String(cnt)+".png" as String, contents: data, attributes: nil)
            //}catch{
                #if DEBUG
                //print("icon error")
                #endif
                
            //}

        }
        
    }
    
    func showwirednews(_ nf:Notification)
    {
        #if DEBUG
        print("showwirednews")
            print(newsarray)
        #endif
        //let reversearray=newsarray.reverse()
        var attr:NSAttributedString=NSAttributedString()
        for i in 0..<newsarray.count{
            attr=newsarray[i] as NSAttributedString
            //print(attr)
            self.newsText?.textStorage.addAttribute(NSAttributedStringKey.link, value: attr, range: (self.newsText?.selectedRange)!)
        self.newsText?.textStorage.append(attr)
        self.newsText?.scrollRangeToVisible(NSMakeRange(self.newsText!.textStorage.length,2))
        }
        
    }
    
    @IBAction func userlistReload()
    {
        #if DEBUG
        print("userlistReload")
            /*var transferfile=Array<String>()
            var transfertype=Array<String>()
            var speed=Array<String>()
            var filesize=Array<String>()
            var transfered=Array<String>()*/
        #endif
        
        //var nf=Notification(name: Notification.Name(rawValue: "WITRANSFERRELOAD" ), object: self,userInfo:nil)
        //NotificationCenter.default.post(nf)
        //var nf=Notification(name: Notification.Name(rawValue: cleartransferlist), object: self,userInfo:nil)
        //NotificationCenter.default.post(nf)
        wiredsend.sendWIInfo(userIndex)
        let nf=Notification(name: Notification.Name(rawValue: "WITRANSFERRELOAD" ), object: self,userInfo:nil)
        NotificationCenter.default.post(nf)
    }
    public func byteCal(size:String,transferd:String,speed:String)->String{
        var str=String()
        let array=[size,transferd,speed]
        str=transferString(array: array)
        return str
    }
    func transferString(array:Array<String>)->String{
        var str = String()
        var stringarray:Array<String>=Array()
        var doublearray:Array<Double>=Array()
        doublearray.insert(atof(array[0]),at:0)
        doublearray.insert(atof(array[1]),at:1)
        doublearray.insert(atof(array[2]),at:2)
        var roundedValue1=NSString()
        for dbl in doublearray{
            //var ans:Double=Double()
            let kilo:Double=1024
            let mega:Double=1048575
            let giga:Double=1073741823
            let tera:Double=1099511627775
            
            if Double(dbl)>=Double(kilo) && Double(dbl)<=Double(mega) {
                #if DEBUG
                print("K")
                    #endif
                roundedValue1 = NSString(format: "%.1f", dbl/kilo)
                str=String(roundedValue1)+" KB"
            }else if dbl>=mega && dbl<=giga {
                #if DEBUG
                print("mega")
                    #endif
                roundedValue1 = NSString(format: "%.1f", dbl/mega)
                str=String(roundedValue1)+" MB"
            }else if dbl>=giga && dbl<=tera{
                #if DEBUG
                print("giga")
                    #endif
                roundedValue1 = NSString(format: "%.1f", dbl/giga)
                str=String(roundedValue1)+" GB"
            }else if (dbl<kilo){
                
            }
            stringarray.insert(str, at: stringarray.count)
            //print(stringarray)
            
            
        }
        str=stringarray[1]+"/"+stringarray[0]+"   "+stringarray[2]+"/sec "
        
        
        return(str)
    }
    
    /*@IBAction func pushDisconnect(sender:UIButton)
    {
        var nf=NSNotification(name: settittle, object:self)
        #if DEBUG
        print("pushDisconnect:ok")
        #endif
        appDelegate.closeStream()
        nf=NSNotification(name: settittle, object:self, userInfo:["servername":"Disconnected"])
        NSNotificationCenter.defaultCenter().postNotification(nf)
        serverinfoarray.removeAll()
    }*/

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }

}
