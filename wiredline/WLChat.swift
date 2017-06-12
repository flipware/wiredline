//
//  WKChat.swift
//  wiredline
//
//  Created by HiraoKazumasa on 10/24/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import UIKit
import Photos
import WatchConnectivity
import UserNotifications
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


enum UIUserInterfaceIdiom : Int {
    case unspecified
    
    case phone // iPhone and iPod
    case pad // iPad
}
extension UIImage{
    func scaledToSize(_ size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

class WLChat: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,clearChatAndUsers,WCSessionDelegate,UIImagePickerControllerDelegate ,UINavigationControllerDelegate,ChatDelegate{
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

    @IBOutlet weak var chat:UITextView?
    @IBOutlet weak var pchatbutton:UIBarButtonItem?
    @IBOutlet weak var input:UITextView?
    @IBOutlet var userlist:UITableView!
    @IBOutlet weak var pview:UIView?
    @IBOutlet weak var keyresign:UIBarButtonItem?
    @IBOutlet weak var userinfoview:UIView?
    @IBOutlet weak var closeButton:UIButton?
    @IBOutlet weak var infonick:UILabel?
    @IBOutlet weak var infoLogin:UILabel?
    @IBOutlet weak var infostatus:UILabel?
    @IBOutlet weak var infoIcon:UIImageView?
    @IBOutlet weak var infoIP:UILabel?
    @IBOutlet weak var infoVersion:UILabel?
    @IBOutlet weak var infoHost:UILabel?
    @IBOutlet weak var infoCipher:UILabel?
    @IBOutlet weak var infoLogintime:UILabel?
    @IBOutlet weak var infoIdletime:UILabel?
    @IBOutlet weak var infoID:UILabel?
    @IBOutlet weak var infoindicator:UIActivityIndicatorView?
    @IBOutlet weak var hluserinfoview:UIView?
    @IBOutlet weak var hlinfoclose:UIButton?
    @IBOutlet weak var hlinfotext:UITextView?
    @IBOutlet weak var morebutton:UIButton?
    @IBOutlet weak var moreview:UIView?
    @IBOutlet weak var moreclose:UIButton?
    @IBOutlet weak var newsview:UIView?
    @IBOutlet weak var newsText:UITextView?
    @IBOutlet weak var addbkmrk:UIBarButtonItem?
    @IBOutlet weak var userlistReloadButton:UIButton?
    @IBOutlet weak var transferlist:UITableView!
    @IBOutlet weak var iconsteal:UIButton?
    
    var wiredcolorwatch=[String]()
    var reloadflag=true
    var hlinfotapped=0
    var background=false
    let red=UIColor.red
    let black=UIColor.black
    let grey=UIColor.gray
    let pink=UIColor(red: 240.0/255.0, green: 129.0/255.0, blue: 163.0/255.0, alpha: 1.0)
    let blue=UIColor.blue
    var path=NSString(string: (Bundle.main.path(forResource: "hotwireAdditional", ofType: "bundle"))!).appendingPathComponent("Icons")
    var contents:NSArray=NSArray()
    var photoAssets = [PHAsset]()
    var isObserving:Bool=true
    let hlsend:HLSend=HLSend()
    let hlrecv:HLRecv=HLRecv()
    var wisend:WiredSend=WiredSend()
    var wirecv:WiredRecv=WiredRecv()
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var notifswitch=false
    weak var session:WCSession!
    var transferfile=Array<String>()
    var transfertype=Array<String>()
    var speed=Array<String>()
    var filesize=Array<String>()
    var transfered=Array<String>()
    
    var queue=OperationQueue()
    var opcancel=Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //newsview!.hidden=true
        if addressinfo .isEmpty{
        navigationItem.title="Not Connected"
        }else{
            navigationItem.title=addressinfo
        }
        let ud=UserDefaults()
        let results=ud.value(forKey: "notificationstatus")
        if results != nil{
        if results as! String == "true" {
            notifswitch=true
        } else{
            notifswitch=false
            }
        }
        
        #if DEBUG
        print("WLChat")
        #endif
        chat?.layer.cornerRadius = 10.0
        input?.layer.cornerRadius=10.0
        initNotification()
        input?.delegate=self
        
        NotificationCenter.default.addObserver(self, selector: #selector(WLChat.setTittle(_:)), name: NSNotification.Name(rawValue: settittle), object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WLChat.addImageToChat(_:)), name: NSNotification.Name(rawValue: addimage), object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WLChat.addAttChat(_:)), name: NSNotification.Name(rawValue: addchat), object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WLChat.userlistreload(_:)), name: NSNotification.Name(rawValue: listreload) , object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WLChat.addPMBadge(_:)), name: NSNotification.Name(rawValue: wipmrecv) , object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WLChat.userinfoset(_:)), name: NSNotification.Name(rawValue: setuserinfo), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WLChat.hluserinfoset(_:)), name: NSNotification.Name(rawValue: sethluserinfo), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WLChat.backgroundOnNotif(_:)), name: NSNotification.Name(rawValue: "applicationDidEnterBackground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WLChat.backgroundOffNotif(_:)), name: NSNotification.Name(rawValue: "applicationWillEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WLChat.watchNotification(_:)), name:NSNotification.Name(rawValue: chatnotification) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WLChat.transferlist(_:)), name:NSNotification.Name(rawValue: transfernotification) , object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(WLChat.transferlistReload(_:)), name: NSNotification.Name(rawValue: "WITRANSFERRELOAD"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WLChat.clearTransferList(_:)), name: NSNotification.Name(rawValue: cleartransferlist), object: nil)
        chat?.dataDetectorTypes = .link
        /*if(wiredflag==0){
            let nib  = UINib(nibName: "hluserlist", bundle:nil)
            userlist.registerNib(nib, forCellReuseIdentifier:"userlist")
            let manager = NSFileManager.defaultManager()
            do {
                
                contents = try manager.contentsOfDirectoryAtPath(path)
                
            }
            catch  _ as NSError {
                
            }
        }*/
        if (WCSession.isSupported()) {
            session = WCSession.default
            session.delegate = self;
            session.activate()
        }
        

        // Do any additional setup after loading the view.
    }
    @objc func transferlist(_ nf:Notification){
        #if DEBUG
            print("transferlist")
        #endif
        let str=(nf as NSNotification).userInfo!["transfer"] as! String
        let array=str.components(separatedBy: String(rs))
        let type=(nf as NSNotification).userInfo!["transfertype"] as! String
        let cnt=filearray.count
        
        if type != ""{
            transfertype.insert(type, at: cnt)
            transferfile.insert(array[0], at:cnt)
            transfered.insert(array[1], at: cnt)
            filesize.insert(array[2],at:cnt)
            speed.insert(array[3], at: cnt)
            transferlist.reloadData()
        }
        #if DEBUG
            print(array)
            print(cnt)
            print(type)
            print(transfertype)
            print(transferfile)
            print(transfered)
            #endif
        self.transferlist.reloadData()
        self.transferlist.setNeedsDisplay()
    }
    @objc func watchNotification(_ notif:Notification)
    {
        #if DEBUG
        print("watchNotification")
        #endif
        let status=(notif as NSNotification).userInfo!["switchstatus"] as! String
        if status=="on" {
            notifswitch=true
            print("notiftrue")
        }else{
            notifswitch=false
        }
            
    }
    @IBAction func pushNewsButton(_ sender:UIButton)
    {
        #if DEBUG
            print("pushNewsButton")
        #endif
        input?.resignFirstResponder()
        chat?.resignFirstResponder()
        moreview?.removeFromSuperview()
        view?.addSubview(newsview!)
        //self.view.addSubview(newsview!)
        //self.input!.resignFirstResponder()
        wisend.getNews()
    }
    @IBAction func pushDisconnect(_ sender:UIButton)
    {
        var nf=Notification(name: Notification.Name(rawValue: settittle), object:self)
        #if DEBUG
            print("pushDisconnect:ok")
        #endif
        appDel.closeStream()
        nf=Notification(name: Notification.Name(rawValue: settittle), object:self, userInfo:["servername":"Disconnected"])
        NotificationCenter.default.post(nf)
        serverinfoarray.removeAll()
    }

    @objc func backgroundOnNotif(_ nf:Notification)
    {
        #if DEBUG
            
            print("backgorund")
            #endif
        background=true
    }
    @objc func backgroundOffNotif(_ nf:Notification)
    {
        #if DEBUG
        print("forground")
        #endif
        background=false
    }
    func clearUsercellAndChatText()
    {
        #if DEBUG
        print("delegate")
            #endif
        wirecv.clearUserlist()
        hlrecv.clearUserlist()
        
        
    }
    @objc func hluserinfoset(_ nf:Notification)
    {
        #if DEBUG
            print("hluserinfoset:ok")
            #endif
        if(hlinfotapped==1){
             let userInfo=(nf as NSNotification).userInfo
             self.hluserinfoview?.center=self.view.center
             self.view.addSubview(hluserinfoview!)
             self.hluserinfoview?.layer.cornerRadius=10.0
             self.hlinfotext?.text=userInfo!["userinfo"] as! String
        }
        hlinfotapped = 0
        
    }
    
    @objc func userinfoset(_ nf:Notification)
    {
        #if DEBUG
        print("setUserInfoView")
        #endif
        //self.userlist.isUserInteractionEnabled=false
        let userInfo=(nf as NSNotification).userInfo
        if opcancel==false && userIndex == userInfo!["id"] as? String{
        if userinfoview?.isHidden==false{
        let userInfo=(nf as NSNotification).userInfo
        self.userinfoview?.center=self.view.center
        self.view.addSubview(userinfoview!)
        self.userinfoview?.layer.cornerRadius=15.0
        self.infoIcon?.layer.cornerRadius=15.0
        self.infoIcon?.layer.masksToBounds=true
        let data=Data(base64Encoded: userInfo!["image"] as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        let iimage=UIImage(data: data!)
        if iimage != nil{
        infoIcon?.image=iimage
        }
        infonick!.text=userInfo!["nick"] as? String
        infostatus!.text=userInfo!["status"] as? String
        infoLogin!.text=userInfo!["login"] as? String
        infoIP!.text=userInfo!["ip"] as? String
        infoVersion?.text=userInfo!["version"] as? String
        infoCipher?.text=userInfo!["cipher"] as? String
        infoHost?.text=userInfo!["host"] as? String
        infoHost?.sizeToFit()
        infoID?.text=userInfo!["id"] as? String
        infoLogintime?.text=userInfo!["logintime"] as? String
        infoIdletime?.text=userInfo!["idletime"] as? String
        infoindicator?.stopAnimating()
        infoindicator?.isHidden=true
        //filesize.removeAll()
        //transfered.removeAll()
        //transfertype.removeAll()
        //speed.removeAll()
        //transferfile.removeAll()
        queue.addOperation {
            sleep(3)
            self.clearTransferListNONotification()
            self.wisend.sendWIInfo(userInfo?["id"] as! String)
        }
        }
        }
        //transferlist.reloadData()
        if opcancel != false && userIndex != userInfo!["id"] as? String{
            queue.cancelAllOperations()
            self.wisend.sendWIInfo(userIndex)
            //transferlist.reloadData()
        }
        transferlist.setNeedsDisplay()
        
        
        
    }
    @objc func clearTransferList(_ nf:Notification)
    {
        #if DEBUG
            print("clearTransferList")
            #endif
        clearTransferListNONotification()
        self.transferlist.reloadData()
    }
    func clearTransferListNONotification()
    {
        #if DEBUG
            print("clearTransferListNoNotif")
        #endif
        
        filesize.removeAll()
        transfered.removeAll()
        transfertype.removeAll()
        speed.removeAll()
        transferfile.removeAll()
        //self.transferlist.reloadData()
        //self.transferlist.beginUpdates()
        //self.transferlist.endUpdates()
        //transferlist.beginUpdates()
        //transferlist.setNeedsDisplay()
        //self.wisend.sendWIInfo(userIndex)
        
    }
    @IBAction func hlinfoClose(_ sender:UIButton)
    {
        self.hluserinfoview!.removeFromSuperview()
    }
    @IBAction func moreWindowClose(_ sender:UIButton)
    {
        moreview!.isHidden=true
    }
    @objc func setTittle(_ nf:Notification)
    {
        #if DEBUG
        print("settittle")
        #endif
        let userInfo=(nf as NSNotification).userInfo
        navigationItem.title?=(userInfo!["servername"] as? String)!
        //serverinfoarray[2]=(userInfo!["servername"] as? String)!
        #if DEBUG
        print(serverinfoarray)
        #endif
    }
    @IBAction func infowindowclose(_ sender:UIButton)
    {
        #if DEBUG
            print("infowindowclose")
            #endif
        opcancel=true
        self.userinfoview!.removeFromSuperview()
        //userinfoview=nil
        filesize.removeAll()
        transfered.removeAll()
        transfertype.removeAll()
        speed.removeAll()
        transferfile.removeAll()
        queue.cancelAllOperations()
        userIndex = "false"
    }
    @objc func addPMBadge(_ nf:Notification)
    {
        //print("addbadge")
        //((((tabBarController?.tabBar.items![1])! as UITabBarItem))).badgeValue="!"
        /*var string:String=String()
        if let userInfo=(nf as NSNotification).userInfo{
            string=userInfo["msgs"] as! String
            //string=userInfo["chat"] as! NSAttributedString
        }
        let notification = UILocalNotification()
        notification.fireDate = Date()	// すぐに通知したいので現在時刻を取得
        notification.timeZone = TimeZone.current
        notification.alertBody = string
        notification.alertAction = "OK"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.presentLocalNotificationNow(notification)*/
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text=="\n"){
            input!.resignFirstResponder()
            return false
        }
        return true
    }

    func textViewDidEndEditing(_ textView:UITextView)
    {
        #if DEBUG
            print("textViewDidEndEditin")
            #endif
        let opt="/me"
        var str:String=String()
        let len:Range?=textView.text.range(of: opt)
        //print("len=",len)
        if(outputHLStream != nil && textView.text != ""){
            //if(textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 2){
                //print("chatlen=",textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
              //  str=(textView.text as NSString).substringToIndex(3)
            //}
        input?.endEditing(false)

            switch(wiredflag){
                        case 0:
                if(len == nil && (textView.text as NSString).lengthOfBytes(using: encoding.rawValue) > 0){
                  hlsend.sendChat(input!.text)
                }else{
                    str=(textView.text as NSString).substring(from: 3)
                    hlsend.sendOptChat(str)
                }
                break
            case 1:
                if(len == nil && (textView.text as NSString).lengthOfBytes(using: String.Encoding.utf8.rawValue) > 0 ){
                    wisend.sendWiChat(input!.text)
                }else{
                    wisend.sendWiMeChat(input!.text)
                }
                break
            default:
                break
            }
        input!.text=""
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        var message:Dictionary?=["servername":String()]
        if(serverinfoarray.count==0){
            navigationItem.title="Not Connected"
        }else{
            if(serverinfoarray[2].isEmpty){
            navigationItem.title=serverinfoarray[1]
            }else{
                navigationItem.title=serverinfoarray[2]
            }
            if UIDevice.current.userInterfaceIdiom == .phone{
                if WCSession.default.isReachable==true{
                     message!["servername"]=navigationItem.title
                    session=WCSession.default
                    session.delegate=self
                    session.activate()
                    self.session.sendMessage(message!, replyHandler: { replyDict in }, errorHandler: { error in })
                    message=nil
            }
            }

        }
        if(wiredflag==0){
            let nib  = UINib(nibName: "hluserlist", bundle:nil)
            userlist.register(nib, forCellReuseIdentifier:"userlist")
            let manager = FileManager.default
            do {
                
                contents = try manager.contentsOfDirectory(atPath: path) as NSArray
                
            }
            catch  _ as NSError {
                
            }
        }
        let nib  = UINib(nibName: "wiredTransferlistTableViewCell", bundle:nil)
        self.transferlist.register(nib, forCellReuseIdentifier:"transferlist")
        input?.becomeFirstResponder()
    }
    
    @IBAction func keyresign(_ sender:UIBarButtonItem)
    {
        #if DEBUG
            print("keyresign")
            #endif
        
        //UIApplication.sharedApplication().sendAction("resignFirstResponder", to:nil, from:nil, forEvent:nil)
        //sender.endEditing(true)
        self.input!.resignFirstResponder()
    }
    @IBAction func pushplus(_ sender:UIBarButtonItem)
    {
        var actionSheet=UIAlertController(title: "選択してください", message: nil, preferredStyle: .actionSheet)
        func handler(_ act:UIAlertAction!){
            var sourceType:UIImagePickerControllerSourceType?
            switch(act.title){
                case "Camera"?:
                sourceType=UIImagePickerControllerSourceType.camera
                break
            case "Photo Album"?:
                sourceType=UIImagePickerControllerSourceType.photoLibrary
                break
            case "Saved Photos"?:
                sourceType=UIImagePickerControllerSourceType.savedPhotosAlbum
                break
            default:
                break
            }
            let picker:UIImagePickerController=UIImagePickerController()
            picker.sourceType=sourceType!
            picker.allowsEditing=true
            picker.delegate=self
            self.present(picker,animated:true,completion: nil)
            //self.popoverPresentationController(picker)
        }
        actionSheet.addAction(UIAlertAction(title: "Camera",style: .default,handler: handler))
        actionSheet.addAction(UIAlertAction(title: "Photo Album",style: .default,handler: handler))
        actionSheet.addAction(UIAlertAction(title: "Saved Photos",style: .default,handler: handler))
        actionSheet.addAction(UIAlertAction(title: "Cancel",style: .default,handler: nil))
        self.present(actionSheet,animated: true,completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController)
    {
        #if DEBUG
            print("Cancel")
        #endif
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        #if DEBUG
        print("choosed photo")
        #endif
        if let image:UIImage=info[UIImagePickerControllerOriginalImage]as?UIImage{
            var width=image.size.width
            var height=image.size.height
            #if DEBUG
                print("width=",width)
                print("height=",height)
                #endif
            if width>128 && height>128 {
            width=width/15
            height=height/15
            }
            let newSize = CGSize(width: width, height: height)
            UIGraphicsBeginImageContextWithOptions(newSize, false,0)
            image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let imageResized = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            //imageResized=image
            wisend.ssWiredSendImage(imageResized!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pushmore(_ sender:AnyObject)
    {
        input!.resignFirstResponder()
        chat?.resignFirstResponder()
        self.moreview?.center=self.view.center
        moreview!.isHidden=false
    }
    func tableView(_ tableview :UITableView, titleForHeaderInSection section:Int)->String?
    {
        var string=String()
        var countnick:Int=0
        if(wiredflag==1 && tableview.tag==1){
            countnick=nick.count
            string="Current Users"+" ("+String(countnick)+")"
        }else if(hlflag==1 && tableview.tag==1){
            countnick=hlnicknamearray.count
            string="Current Users"+" ("+String(countnick)+")"
        }else if tableview.tag==0 {
            string="Transfer"
        }
        return string
    }
    //TODO
    //nicknameの更新問題
    func WLListReload()->Void
    {
        #if DEBUG
            print("WLListReload")
            #endif
        OperationQueue.main.addOperation(){
            if Thread.isMainThread{
                print("main thread")
            }else{
                print("sub thread")
            }
        if self.userlist != nil {
            //self.userlist=
            print("no")
            self.userlist.reloadData()
        }else{
            print("yes")
            
            //self.userlist.delegate=self
            self.userlist.reloadData()
        }
        }
        
    }
    func chatWindowActive() {
        if Thread.isMainThread{
            print("Main")
            self.tabBarController!.selectedIndex = 1;
        }else{
            print("not Main")
            OperationQueue.main.addOperation(){
                self.tabBarController!.selectedIndex = 1;
            }
        }
    }
    @objc func userlistreload(_ notification:Notification)
    {
        #if DEBUG
            print("reload")
            #endif
        let sendmessage=["watch":"userlist"]
        //wiredcolorwatch.removeAll()
        //var sendmessage=["wirednick":nick]
        //sleep(1)
        self.userlist.reloadData()
        if(WCSession.default.isReachable==true){
                self.session.sendMessage(sendmessage, replyHandler: { replyDict in }, errorHandler: { error in })
        }
        NotificationCenter.default.removeObserver(listreload)
        
        
    }
    func transferlistReload(_ nf:Notification)
    {
        
        #if DEBUG
            print("transferReload:ok")
        print(transferfile)
        #endif
        
    }
    
    @objc func addImageToChat(_ notification:Notification){
        var string:NSAttributedString=NSAttributedString()
        var astr:String=String()
        var breakline:NSAttributedString=NSAttributedString()
        var decodedimage=UIImage()
        let _:Int
        //let len:Int
        let adjustline=NSAttributedString(string: "              ")
        breakline=NSAttributedString(string: "\n")
        //let string=(str as NSString).substringFromIndex(4)
        if let userInfo=(notification as NSNotification).userInfo{
            string=userInfo["image"] as! NSAttributedString
            astr=string.string
            _=astr.lengthOfBytes(using: String.Encoding.utf8)
            let endpoint=astr.characters.count
            astr=astr.substring(to: astr.characters.index(astr.startIndex, offsetBy: endpoint))
            let imagedata=Data(base64Encoded: astr, options:NSData.Base64DecodingOptions(rawValue: 0) )
            if(imagedata==nil){
                #if DEBUG
                print("null")
                #endif
                //var myURL=NSURL(string: "http://media1.giphy.com/media/XfZLuLvKvy0Yo/giphy.gif")
            }else{
            decodedimage=UIImage(data: imagedata!)!
            let attachment = NSTextAttachment()
            attachment.image = decodedimage
            //put your NSTextAttachment into and attributedString
            let attString = NSAttributedString(attachment: attachment)
            //add this attributed string to the current position.
            //chat!.textStorage.insertAttributedString(attString, atIndex: chat!.selectedRange.location+1)
            self.chat!.textStorage.append(adjustline)
            self.chat!.textStorage.append(attString)
            self.chat!.textStorage.append(breakline)
                if background==true{
                /*let notification = UNNotification()
                notification.fireDate = Date()	// すぐに通知したいので現在時刻を取得
                notification.timeZone = TimeZone.current
                notification.alertBody = string.string
                notification.alertAction = "OK"
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.shared.presentLocalNotificationNow(notification)*/
                    let content = UNMutableNotificationContent()
                    content.title = NSString.localizedUserNotificationString(forKey: "WiredLine Chat", arguments: nil)
                    content.body = NSString.localizedUserNotificationString(forKey: "Recived Image", arguments: nil)
                    content.sound = UNNotificationSound.default()
                    
                    // Deliver the notification in five seconds.
                    let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
                    let request = UNNotificationRequest.init(identifier: "chat", content: content, trigger: trigger)
                    
                    // Schedule the notification.
                    let center = UNUserNotificationCenter.current()
                    center.add(request)
                }
        }
            
        }
        NotificationCenter.default.removeObserver(addimage)
        
    }
    func addChatLine(attstr: NSAttributedString) {
        print("delegateChat")
        var string:NSAttributedString=NSAttributedString()
        let _:Int
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let str = formatter.string(from: now)
        var timestr="["
        timestr+=str+"] "
        string=attstr
        OperationQueue.main.addOperation(){

            let timeredstr=NSMutableAttributedString(string: timestr, attributes: [NSAttributedStringKey.foregroundColor:UIColor.red])
        timeredstr.append(string)
        #if DEBUG
            print("addchat")
            print(string)
            print("notifswitch=\(self.notifswitch)")
            print("background=\(self.background)")
        #endif
        //_=(self.tabBarController?.selectedIndex)!
        if self.notifswitch==true{
            if(self.background==true){
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: "WiredLine Chat", arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: string.string, arguments: nil)
                content.sound = UNNotificationSound.default()
                
                // Deliver the notification in five seconds.
                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest.init(identifier: "chat", content: content, trigger: trigger)
                
                // Schedule the notification.
                let center = UNUserNotificationCenter.current()
                center.add(request)
            }
        }
         //}
            if self.chat==nil{
                self.chat=UITextView()
            }
            self.chat!.textStorage.addAttribute(NSAttributedStringKey.link, value: timeredstr, range: self.chat!.selectedRange)
        self.chat!.textStorage.append(timeredstr)
        self.chat!.scrollRangeToVisible(NSMakeRange(self.chat!.textStorage.length,2))
        //self.chat?.attributedText=timeredstr
        }
    }

    @objc func addAttChat(_ notifcation:Notification)
    {
        var string:NSAttributedString=NSAttributedString()
        let _:Int
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let str = formatter.string(from: now)
        var timestr="["
        timestr+=str+"] "
        let timeredstr=NSMutableAttributedString(string: timestr, attributes: [NSAttributedStringKey.foregroundColor:UIColor.red])
        if let userInfo=(notifcation as NSNotification).userInfo{
            string=userInfo["chat"] as! NSAttributedString
        }
        timeredstr.append(string)
        #if DEBUG
            print("addchat")
            print(string)
            #endif
        
        _=(self.tabBarController?.selectedIndex)!
        //dispatch_async(dispatch_get_main_queue(), {
        #if DEBUG
            print("notifswitch=\(notifswitch)")
            print("background=\(background)")
            #endif
        if notifswitch==true{
            if(background==true){
                /*let notification = UNNotification()
                notification.fireDate = Date()	// すぐに通知したいので現在時刻を取得
                notification.timeZone = TimeZone.current
                notification.alertBody = string.string
                notification.alertAction = "OK"
                notification.soundName = UILocalNotificationDefaultSoundName
                //UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                UIApplication.shared.scheduleLocalNotification(notification)*/
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: "WiredLine Chat", arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: string.string, arguments: nil)
                content.sound = UNNotificationSound.default()
                
                // Deliver the notification in five seconds.
                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest.init(identifier: "chat", content: content, trigger: trigger)
                
                // Schedule the notification.
                let center = UNUserNotificationCenter.current()
                center.add(request)
        }
        }
           // }
            //dispatch_async(dispatch_get_main_queue(), {
        self.chat!.textStorage.addAttribute(NSAttributedStringKey.link, value: timeredstr, range: self.chat!.selectedRange)
            self.chat!.textStorage.append(timeredstr)
            self.chat!.scrollRangeToVisible(NSMakeRange(self.chat!.textStorage.length,2))
        //})
        NotificationCenter.default.removeObserver(addchat)
        //self.chatwindow.textStorage.appendAttributedString(string)
        //[chatwindow scrollRangeToVisible:NSMakeRange([[chatwindow textStorage] length],2)];
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userlist.deselectRow(at: indexPath, animated: true)
        
        /*self.userinfoview?.center=self.view.center
        self.view.addSubview(userinfoview!)
        userinfoview?.layer.cornerRadius=10.0*/
        
        
        
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if(wiredflag == 1 && inputHLStream != nil){
            opcancel=false
            clearTransferListNONotification()
            transferlist.reloadData()
            queue.cancelAllOperations()
            //self.clearTransferListNONotification()
            wisend.sendWIInfo(user[(indexPath as NSIndexPath).row])
            userIndex=user[(indexPath as NSIndexPath).row]
            userrow=(indexPath as NSIndexPath).row
            //transferlist.reloadData()
        }else if(wiredflag == 0 && inputHLStream != nil){
            newsinfo="userinfo"
            hlsend.sendHLUserInfo(hluidarray[(indexPath as NSIndexPath).row] as AnyObject)
            hlinfotapped=1
        }
    }
    
    
    /*
    Cellの総数を返すデータソースメソッド.
    (実装必須)
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int=0
        if(wiredflag==1 && tableView.tag==1){
            count=user.count
        }else if(wiredflag==0){
            count=hlnicknamearray.count
        }else if(tableView.tag==0){
            count=filesize.count
        }
        return count
    }
    
    /*
    Cellに値を設定するデータソースメソッド.
    (実装必須)
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        #if DEBUG
            print("tabaleview tag=\(tableView.tag)")
            #endif
        let data:Data
        // 再利用するCellを取得する
        //var cell = userlist!.dequeueReusableCellWithIdentifier("Userlist", forIndexPath: indexPath)
        var cell:UITableViewCell?=UITableViewCell()
        var iimage=UIImage()
        var imagb:UIImage=UIImage()
        let width:CGFloat=35
        let height:CGFloat=35
        //_;:objcmethod=objcmethod()
        if(wiredflag==1 && tableView.tag==1){
        data=Data(base64Encoded: image[(indexPath as NSIndexPath).row], options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
            if data.count>0{
        iimage=UIImage(data: data)!
            }
        cell=UITableViewCell(style: .subtitle, reuseIdentifier: "Userlist")
        cell!.imageView?.contentMode=UIViewContentMode.scaleAspectFill
        cell!.imageView?.layer.masksToBounds=true
        cell!.textLabel?.textAlignment=NSTextAlignment.left
        cell!.textLabel!.text=nick[(indexPath as NSIndexPath).row]
        cell!.detailTextLabel?.text=status[(indexPath as NSIndexPath).row]
            cell?.accessoryType=UITableViewCellAccessoryType.detailButton
        if(admin[(indexPath as NSIndexPath).row] == "1"){
            cell!.textLabel?.textColor=UIColor.red
            cell!.detailTextLabel?.textColor=UIColor.black
            //wiredcolorwatch.insert("red", atIndex: indexPath.row)
        }else{
            cell!.textLabel?.textColor=UIColor.black
            //wiredcolorwatch.insert("black", atIndex: indexPath.row)
        }
        if(idle[(indexPath as NSIndexPath).row]=="1" && admin[(indexPath as NSIndexPath).row]=="1"){
            cell!.textLabel?.textColor=UIColor(red: (255.0)/255.0, green: (192.0)/255.0, blue: (192.0)/255.0, alpha: 1.0)
            cell!.detailTextLabel?.textColor=UIColor.gray
            let color=UIColor.white
            if data.count>0{
            iimage=monocolor(iimage, color: color)
            }
        }
        if(idle[(indexPath as NSIndexPath).row]=="1" && admin[(indexPath as NSIndexPath).row]=="0"){
            cell!.textLabel?.textColor=UIColor(red: (128.0)/255.0, green: (128.0)/255.0, blue: (128.0)/255, alpha: 1.0)
            cell!.detailTextLabel?.textColor=UIColor.gray
            let color=UIColor.white
            if data.count>0{
            iimage=monocolor(iimage, color: color)
            }
        }
            
        UIGraphicsBeginImageContext(CGSize(width: width,height: height))
        iimage.draw(in: CGRect(x: 0,y: 0,width: width,height: height))
        imagb=UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        cell!.imageView?.layer.cornerRadius=5
        cell!.imageView!.image=imagb
        }else if wiredflag==0 && tableView.tag==1{
            //cell=hluserlistcellTableViewCell()
            var path:NSString?
            //var error:NSError
            enum iconerror:Error{
                case error1
                case error2
            }
            
            do{
                    path = NSString(string: (Bundle.main.path(forResource: "hotwireAdditional", ofType: "bundle"))!).appendingPathComponent("Icons") as NSString?
                    path = Bundle.path(forResource: (hliconarray[(indexPath as NSIndexPath).row] as? String), ofType: "png", inDirectory: ((path as String?))!) as NSString?
                if(path == nil){
                    throw iconerror.error1
                }
            }catch _{
                path=""
            }
            weak var hcell = userlist?.dequeueReusableCell(withIdentifier: "userlist") as? hluserlistcellTableViewCell
            hcell!.accessoryType=UITableViewCellAccessoryType.detailButton
            hcell!.usernamelabel.text=String(describing: hlnicknamearray[(indexPath as NSIndexPath).row])
            hcell!.usernamelabel.textColor=self.usercolor(hlcolorarray[(indexPath as NSIndexPath).row] as! String)
            //hcell.textLabel!.text=hlnicknamearray[indexPath.row] as? String
            
            if(path != nil ){
                hcell!.iconview.image=UIImage(contentsOfFile:path! as String)
                let width = UIImage(contentsOfFile:path! as String)?.size.width
                let height = UIImage(contentsOfFile:path! as String)?.size.height
                #if DEBUG
                    print("width=\(String(describing: width)) height=\(String(describing: height))")
                #endif
                if(width<40){
                    hcell!.iconview.contentMode=UIViewContentMode.left
                }else{
                    hcell!.iconview.contentMode=UIViewContentMode.scaleToFill
                }
            }
            cell=hcell
            hcell=nil
        }
        #if DEBUG
        print("transferreload=\(transferreload)")
            #endif
        if (tableView.tag==0){
            #if DEBUG
            print("transferreload")
                #endif
            let nib  = UINib(nibName: "wiredTransferlistTableViewCell", bundle:nil)
            self.transferlist.register(nib, forCellReuseIdentifier:"transferlist")
            cell=UITableViewCell(style: .subtitle , reuseIdentifier: "transferlist")
            weak var transfercell=transferlist.dequeueReusableCell(withIdentifier: "transferlist") as? wiredTransferlistTableViewCell
            transfercell?.transfertype.text=String(transfertype[(indexPath as NSIndexPath).row])
            transfercell?.filename.text=String(transferfile[(indexPath as NSIndexPath).row])
        
            let cmv=WLChatMoreViewController()
            let str=cmv.byteCal(size: filesize[(indexPath as NSIndexPath).row], transferd: transfered[(indexPath as NSIndexPath).row], speed: speed[(indexPath as NSIndexPath).row])
            let tra=Float(transfered[(indexPath as NSIndexPath).row])
            let si=Float(filesize[(indexPath as NSIndexPath).row])
            let ans=tra!/si!
            //print(ans)
            transfercell?.progress.progress=ans
            transfercell?.progress.setProgress(ans, animated: true)
            //transfercell=nil
            transfercell?.speedsize.text=str
            //transferreload=true
            cell=transfercell
            //self.transferlist.beginUpdates()
            //self.transferlist.endUpdates()
            transfercell=nil
        }
        return cell!
    }
    @objc func keyboardWillShow(_ notification:NSNotification)
    {
        //print("keyboard")
        //print(notification)
        let rect = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration:TimeInterval = (notification as NSNotification).userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration, animations: {
            let transform = CGAffineTransform(translationX: 0, y: -rect.size.height+215)
            self.pview!.transform = transform
            },completion:nil)
        //NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillShow)
    }
    @objc func keyboardWillHide(_ notification: Notification?) {
        //print(notification)
        _ = ((notification! as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (notification as NSNotification?)?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration, animations:{
            //let transform = CGAffineTransformMakeTranslation(0, 0)
            self.pview?.transform = CGAffineTransform.identity
            //self.pview!.transform = transform
            },
            completion:nil)
        //NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillHide)
        
    }
    func initNotification()
    {
        if(isObserving){
            #if DEBUG
                print("KeyboardNotificationSet")
            #endif
            let notification = NotificationCenter.default
            notification.addObserver(self, selector: #selector(WLChat.keyboardWillShow(_:))
                , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            notification.addObserver(self, selector: #selector(WLChat.keyboardWillHide(_:))
                , name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            isObserving = true
        }
    }
    func monocolor(_ image:UIImage,color:UIColor)->UIImage
    {
        #if DEBUG
            print("monocolor()")
            //print(CFGetRetainCount(self))
            #endif
        let ciImage:CIImage? = CIImage(image:image)!
        let ciFilter:CIFilter? = CIFilter(name: "CIColorControls")!
        var image2:UIImage?=UIImage()
        ciFilter!.setValue(ciImage, forKey: kCIInputImageKey)
        //ciFilter!.setValue(0.8, forKey: "inputIntensity")
        ciFilter!.setValue(0.9, forKey: "inputSaturation")
        ciFilter!.setValue(0.5, forKey: "inputBrightness")
        ciFilter!.setValue(0.9, forKey: "inputContrast")
        let ciContext:CIContext = CIContext(options: nil)
        //let cgimg = ciContext.createCGImage(ciFilter!.outputImage!, fromRect:ciFilter!.outputImage!.extent)
        let cgimg:CGImage?
        cgimg=ciContext.createCGImage(ciFilter!.outputImage!, from:ciFilter!.outputImage!.extent)
        image2 = UIImage(cgImage: cgimg!, scale: 1.0, orientation:UIImageOrientation.up)
        //print(CFGetRetainCount(self))
        return(image2)!
    }
    

    fileprivate func getAllPhotosInfo() {
        photoAssets = []
        // 画像をすべて取得
        let assets:PHFetchResult=PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        //assets.enumerateObjects{ (asset, index, stop) -> Void in
        // self.photoAssets.append(asset )
        //}
        assets.enumerateObjects({ object, index, stop in
            self.photoAssets.append(object)
        })
        //print(photoAssets)
    }
    // MARK: WORKING
    func wiredColor()
    {
        //wiredcolorwatch.removeAll()
        //var colorarray:[String]=Array()
        let count=admin.count
        for i in 0..<count{
            if admin[i]=="1" && idle[i]=="1"{
                wiredcolorwatch.insert("pink", at: i)
            }else if admin[i]=="0" && idle[i]=="1"{
                wiredcolorwatch.insert("grey",at: i)
            }else if admin[i]=="1" && idle[i]=="0"{
                wiredcolorwatch.insert("red",at: i)
            }else{
                wiredcolorwatch.insert("black",at: i)
            }
        }
    }
    func hlwatchcolor(_ str:String)->String
    {
        var string:String=String()
        switch(str){
        case "0":
            string="black"
            break
        case "1":
            string="grey"
            break
        case "2":
            string="red"
            break
        case "3","23","17","19":
            string="pink"
            break
        case "4","22","18":
            string="red"
            break
        default:
            string="black"
            break
        }
        
        return(string)
        
    }
    func usercolor(_ str:String)->UIColor
    {
        
        var color:UIColor=UIColor()
        switch(str){
        case "0":
            color=black
            break
        case "1":
            color=grey
            break
        case "2":
            color=red
            break
        case "3","23","17","19":
            color=pink
            break
        case "4","22","18":
            color=red
            break
        default:
            color=blue
            break
        }
        return(color)
    }
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool
    {
        if tableView.tag==1{
        return true
        }else{
            return false
        }
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let kick = UITableViewRowAction(style: .normal, title: "Kick") { action, index in
            #if DEBUG
            print("kick button tapped")
            #endif
            if(wiredflag==1){
                  self.wisend.wiredClientKick(user[(indexPath as NSIndexPath).row], message: "")
            }else if(hlflag==1){
                self.hlsend.hotlineuserkick(hluidarray[(indexPath as NSIndexPath).row] as! String)
            }
        }
        kick.backgroundColor = UIColor.orange
        
        let ban = UITableViewRowAction(style: .normal, title: "Ban") { action, index in
            #if DEBUG
            print("ban button tapped")
            #endif
            if(wiredflag==1){
            self.wisend.wiredClientBan(user[(indexPath as NSIndexPath).row], message: "")
            }else if (hlflag==1){
                self.hlsend.hotlineuserban(hluidarray[(indexPath as NSIndexPath).row] as! String)
            }
        }
        ban.backgroundColor = UIColor.red
        let pm=UITableViewRowAction(style: .normal, title: "Msg") { action, index in
            #if DEBUG
                print("Msg Tapped")
            #endif
            if(wiredflag==1){
                let alert:UIAlertController = UIAlertController(title:"Message to "+nick[(indexPath as NSIndexPath).row],
                                                                message: "Message:",
                                                                preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",
                                                               style: UIAlertActionStyle.cancel,
                                                               handler:{
                                                                (action:UIAlertAction!) -> Void in
                                                                
                })
                let defaultAction:UIAlertAction = UIAlertAction(title: "OK",
                                                                style: UIAlertActionStyle.default,
                                                                handler:{
                                                                    (action:UIAlertAction!) -> Void in
                                                                    let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                                                                    if textFields != nil {
                                                                        for _:UITextField in textFields! {
                                                                            
                                                                        }
                                                                    }
                                                                    let wiredsend:WiredSend=WiredSend()
                                                                    wiredsend.wiredSendPrivateMsg(textFields![0].text! as String, id: user[(indexPath as NSIndexPath).row] as String)
                                                                    
                })
                alert.addAction(cancelAction)
                alert.addAction(defaultAction)
                
                //textfiledの追加
                alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
                })
                //実行した分textfiledを追加される。
                //alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
                //})
                let alertWindow=UIWindow(frame:UIScreen.main.bounds)
                alertWindow.rootViewController=UIViewController()
                alertWindow.makeKeyAndVisible()
                alertWindow.rootViewController?.present(alert, animated: true, completion: nil)

            }else if (hlflag==1){
                let alert:UIAlertController = UIAlertController(title:"Message to "+(hlnicknamearray[(indexPath as NSIndexPath).row] as! String),
                                                                message: "Message:",
                                                                preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",
                                                               style: UIAlertActionStyle.cancel,
                                                               handler:{
                                                                (action:UIAlertAction!) -> Void in
                                                                
                })
                let defaultAction:UIAlertAction = UIAlertAction(title: "OK",
                                                                style: UIAlertActionStyle.default,
                                                                handler:{
                                                                    (action:UIAlertAction!) -> Void in
                                                                    let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                                                                    if textFields != nil {
                                                                        for _:UITextField in textFields! {
                                                                            
                                                                        }
                                                                    }
                                                                    let hlsend=HLSend()
                                                                    let hlstr=HLString()
                                                                    var data:Data=Data()
                                                                    data=hlstr.uidbyteorder(UInt16(hluidarray[(indexPath as NSIndexPath).row] as! String)!)
                                                                    hlsend.HLSendPrivateMSG(textFields![0].text! as String, idata:data)
                                                                    
                })
                alert.addAction(cancelAction)
                alert.addAction(defaultAction)
                
                //textfiledの追加
                alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
                })
                //実行した分textfiledを追加される。
                //alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
                //})
                let alertWindow=UIWindow(frame:UIScreen.main.bounds)
                alertWindow.rootViewController=UIViewController()
                alertWindow.makeKeyAndVisible()
                alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
                //self.hlsend.hotlineuserban(hluidarray[indexPath.row] as! String)
            }
        }
        pm.backgroundColor=UIColor.blue
        
        return [pm,kick, ban]
    }
   
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        //wiredcolorwatch.removeAll()
        //_ = message["wirednick"] as? String
        #if DEBUG
            print("userlistrequest")
            print(message)
            #endif
        var sendmessage=[String:AnyObject]()
        //message=["wirednick":nick]
        if(wiredflag==1){
        for(_,value) in message{
            if(value as! String=="wirednick"){
                #if DEBUG
                    print("wirednick")
                    print(message)
                    #endif
                sendmessage = ["wirednick": nick as AnyObject]
                //sendmessage["wiredicon"]=image
                //sendmessage["wiredicon"]=image
                
            }else if(value as! String=="wiredcolor"){
                wiredcolorwatch.removeAll()
                #if DEBUG
                    print("color req")
                    #endif
                self.wiredColor()
                //print(wiredcolorwatch)
                sendmessage["wiredcolor"]=wiredcolorwatch as AnyObject?
            }else if(value as! String=="Serverinfo"){
                sendmessage["servername"]=navigationItem.title as AnyObject?
            }else if(value as! String=="Disconnect"){
                sendmessage["servername"]="Not Connected" as AnyObject?
                appDel.closeStream()
            }
        }
        }else if(hlflag==1){
            for(_,value) in message{
                if(value as! String=="wirednick"){
                    #if DEBUG
                        print("hlnick")
                        print(message)
                    #endif
                    sendmessage = ["wirednick": hlnicknamearray]
                    //sendmessage["wiredicon"]=image
                    //sendmessage["wiredicon"]=image
                    
                }else if(value as! String=="wiredcolor"){
                    wiredcolorwatch.removeAll()
                    #if DEBUG
                        print("color req")
                    #endif
                    for i in 0..<hlcolorarray.count{
                        wiredcolorwatch.insert(hlwatchcolor(hlcolorarray[i] as! String), at: i)
                        //hlwatchcolor(hlcolorarray[i] as! String)
                    }
                    //print(wiredcolorwatch)
                    sendmessage["wiredcolor"]=wiredcolorwatch as AnyObject?
                }else if(value as! String=="Serverinfo"){
                    sendmessage["servername"]=navigationItem.title as AnyObject?
                }else if(value as! String=="Disconnect"){
                    appDel.closeStream()
                    navigationItem.title="Disconnected"
                    sendmessage["servername"]="Not Connected" as AnyObject?
                }
            }
            
        }
        #if DEBUG
            print(message)
            #endif
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        DispatchQueue.main.async {
            session.sendMessage(sendmessage, replyHandler: { replyDict in }, errorHandler: { error in })
        }
        //wiredcolorwatch.removeAll()
    }
    
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }

}
