//
//  NewConnect.swift
//  wiredline
//
//  Created by HiraoKazumasa on 10/18/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import UIKit
var addressinfo:String=String()
protocol clearChatAndUsers{
    func clearUsercellAndChatText()
}
let buttontitle="BUTTONDISCONNECT"
class NewConnect: UIViewController {
    @IBOutlet weak var protoswithch:UISegmentedControl?
    @IBOutlet weak var address:UITextField!
    @IBOutlet weak var login:UITextField?
    @IBOutlet weak var passwd:UITextField?
    @IBOutlet weak var indicator:UIActivityIndicatorView?
    @IBOutlet weak var connectbutton:UIButton?
    @IBOutlet weak var cancelbutton:UIButton?
    var tempaddress:String?
    var templogin:String?
    var temppasswd:String?
    var tempflag:String?
    weak var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var delegate:clearChatAndUsers?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        address.text=tempaddress
        login!.text=templogin
        passwd!.text=temppasswd
        if(tempflag=="1"){
            protoswithch?.selectedSegmentIndex=0
        }else if(tempflag=="0"){
            protoswithch?.selectedSegmentIndex=1
        }
        //self.navigationItem.setHidesBackButton(true, animated: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        NotificationCenter.default.addObserver(self, selector: #selector(NewConnect.serverNotAliveAlert(_:)), name: NSNotification.Name(rawValue: servernotalive), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewConnect.indicatorstopnotif(_:)), name: NSNotification.Name(rawValue: loginsuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(NewConnect.buttontitle(_:)), name: NSNotification.Name(rawValue: "BUTTONDISCONNECT"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewConnect.loginfailnotif(_:)), name: NSNotification.Name(rawValue: loginfail), object: nil)
        #if NEWCONNECTIONDEBUG
        print("NewConnection")
        #endif
        #if NEWCONNECTIONDEBUG
            //address.text=self.tempaddress
            //print(tempaddress)
            //address.text="24cafe.aa0.netvolante.jp"
            //login!.text="flip"
            //passwd!.text="flip@oki"
        #endif
        navigationItem.title="Connect"
        protoswithch?.selectedSegmentIndex=0
        //protoswithch?.setBackgroundImage(, forState: .Normal, barMetrics: nil)
        indicator?.isHidden=true
        cancelbutton?.isEnabled=false
        cancelbutton?.setTitleColor(UIColor.gray, for:UIControlState.disabled )
        connectbutton?.layer.cornerRadius = 10.0
        cancelbutton?.layer.cornerRadius = 10.0
        
        self.delegate=WLChat()

        // Do any additional setup after loading the view.
    }
    func buttontitle(_ nf:Notification)
    {
        self.connectbutton?.setTitle("Connect", for: UIControlState())
        self.connectbutton?.backgroundColor?=UIColor.cyan
        self.indicator?.stopAnimating()
        self.indicator?.isHidden=true
    }
    @objc func serverNotAliveAlert(_ nf:Notification)
    {
        #if DEBUG
        print("servernotalive")
        #endif
        let alert = UIAlertController(title: "WiredLine Alert", message:"Server is not responding", preferredStyle: .alert)
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
                                                       style: UIAlertActionStyle.cancel,
                                                       handler:{
                                                        (action:UIAlertAction!) -> Void in
                                                        #if DEBUG
                                                            print("OK")
                                                        #endif
        })
        
        alert.addAction(cancelAction)
        alertWindow.rootViewController = UIViewController()
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        NotificationCenter.default.removeObserver(servernotalive)
        
        if (audioPlayer != nil) {
            audioPlayer.stop()
        }
        
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tapGesture(_ sender: UITapGestureRecognizer){
        for v in self.view.subviews {
            if(v is UITextField) {
                let txt = v as! UITextField
                if(txt.isFirstResponder) {
                    txt.resignFirstResponder()
                    return
                }
            }
        }
    }
    @IBAction func tapScreen(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    
    @IBAction func pushConnect(_ sender:UIButton)
    {
        #if NEWCONNECTIONDEBUG
            print("pushConnect:ok")
        #endif
        
        let qu:OperationQueue=OperationQueue()
        let target=CharacterSet.whitespaces
        var len:Int
        var addrflag:Int
        let wlstring:WLString=WLString()
        wiredflag=0
        hlflag=0
        hlversion="123"
        joinchat=false   // グローバル変数 from hlrecv
        loginflag=false
        userlistflag=false
        serverAck=false
        newsarray.removeAll()
        newsstrarray.removeAll()
        serverinfoarray.removeAll()
        
        hluidarray.removeAllObjects()
        hlnicknamearray.removeAllObjects()
        hlcolorarray.removeAllObjects()
        hliconarray.removeAllObjects()
        
        logininfo.removeAll()
        addressinfo=address.text!
        logininfo.insert((login?.text)!, at: 0)
        logininfo.insert((passwd?.text)!, at: 1)
        let ud=UserDefaults.standard
        var results=ud.object(forKey: "nick")
        //logininfo=[String]()
        self.delegate?.clearUsercellAndChatText()
        
        if(results==nil){
            logininfo.insert(("No Name"), at: 2)
        }else{
            logininfo.insert(results as! String, at: 2)
        }
        results=ud.object(forKey: "status")
        if(results==nil){
            logininfo.insert("", at: 3)
        }else{
            logininfo.insert(results as! String, at: 3)
        }
        results=ud.object(forKey: "iconno")
        if(results==nil){
            logininfo.insert("11", at: 4)
        }else{
            logininfo.insert(results as! String, at: 4)
        }
        results=ud.object(forKey:"wiredicon")
        if results==nil{
            logininfo.insert(WIDEFAULTICON, at: 5)
        }else{
            logininfo.insert(results as! String, at:5)
        }
        #if DEBUG
            //print(logininfo)
        #endif
        //logininfo.insert("FLiP", atIndex: 2)
        //let WLDelegate = UIApplication.sharedApplication().delegate as! WKHLAppdelegate
        var addr:[String]=Array()
        let result:Int=0
        addrflag=0
        len=(address!.text?.lengthOfBytes(using: String.Encoding.utf8))!
        if(len != 0 || address!.text!.trimmingCharacters(in: target).lengthOfBytes(using: String.Encoding.utf8) != 0){
            addrflag=1
            OperationQueue.main.addOperation { () -> Void in
                self.indicatorstart(qu)
                self.cancelbutton?.isEnabled=true
                self.buttonstatuschange(qu)
                
            }
        }else{
            var alert:UIAlertController
            alert=UIAlertController(title: "WiredLine alert", message: "アドレスを入力してください。", preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction:UIAlertAction = UIAlertAction(title: "OK",style: UIAlertActionStyle.default,handler:nil)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }
        if(addrflag==1){
            if(protoswithch?.selectedSegmentIndex==0 && connectbutton?.titleLabel!.text=="Connect"){
                #if NEWCONNECTIONDEBUG
                    print("wired")
                #endif
                addr=wlstring.addressport((address?.text)!, proto: "wired")
                fileaddress=addr
                let queue=OperationQueue()
                queue.addOperation({
                    self.appDelegate!.wireOpenStream(addr)
                    self.appDelegate?.openSession(addr: "24cafe.dip.jp:2000")
                })
                //appDelegate!.wireOpenStream(addr)
                if(result==0){
                    #if NEWCONNECTIONDEBUG
                        //print("result=0")
                    #endif
                }else{
                    #if NEWCONNECTIONDEBUG
                        //print("result=1")
                    #endif
                }
            }else if(protoswithch?.selectedSegmentIndex==1 && connectbutton?.titleLabel!.text=="Connect"){
                #if NEWCONNECTIONDEBUG
                    print("hotline")
                #endif
                addr=wlstring.addressport((address?.text)!, proto: "hotline")
                //self.appDelegate!.HLOpenStream(addr)
                let queue=OperationQueue()
                queue.addOperation({
                    self.appDelegate?.HLOpenStream(addr)
                    self.appDelegate?.openSession(addr: "24cafe.dip.jp:5500")
                })
                //appDelegate!.performSelector(Selector("HLOpenStream:"), withObject: addr)
                //NSThread.detachNewThreadSelector(Selector("HLOpenStream:"), toTarget: appDelegate!, withObject: addr)
                /*if(result==0){
                 #if NEWCONNECTIONDEBUG
                 print("result=0")
                 #endif
                 }else{
                 #if NEWCONNECTIONDEBUG
                 print("result=1")
                 #endif
                 }*/
                
            }
        } else {
            #if DEBUG
                print("インターネット接続なし")
            #endif
            var alert:UIAlertController
            alert=UIAlertController(title: "WiredLine alert", message: "インターネットに繋がっていません。", preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction:UIAlertAction = UIAlertAction(title: "OK",style: UIAlertActionStyle.default,handler:nil)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            appDelegate?.closeStream()
        }

    }
    
    
    @IBAction func pushCancel(_ sender:UIButton)
    {
        let qu:OperationQueue=OperationQueue()
        OperationQueue.main.addOperation { () -> Void in
            self.indicatorstop(qu)
            self.cancelbutton?.isEnabled=false
            self.connectbutton?.isEnabled=true
        }
    }
    func buttonstatuschange(_ sender:AnyObject)
    {
        if(connectbutton?.titleLabel!.text=="Connect"){
            self.connectbutton?.setTitle("Cancel", for: UIControlState())
            self.connectbutton?.backgroundColor?=UIColor.red
            
            
        }else if(connectbutton?.titleLabel!.text=="Cancel"){
            self.connectbutton?.setTitle("Connect", for: UIControlState())
            self.connectbutton?.backgroundColor?=UIColor.cyan
            self.indicatorstop(sender)
        }else if(connectbutton?.titleLabel!.text=="Disconnect"){
            self.connectbutton?.setTitle("Connect", for: UIControlState())
            self.connectbutton?.backgroundColor?=UIColor.cyan
            self.indicatorstop(sender)
            appDelegate!.closeStream()
            
            
        }
        loginflag=false
    }
    
    func indicatorstart(_ sender:AnyObject)
    {
        indicator!.isHidden=false
        indicator?.color=UIColor.black
        indicator!.startAnimating()
        
    }
    
    func indicatorstop(_ sender:AnyObject)
    {
        indicator!.isHidden=true
        indicator!.stopAnimating()
    }
    func indicatorstopnotif(_ notificaion:Notification)
    {
        indicator!.isHidden=true
        indicator!.stopAnimating()
        self.connectbutton?.setTitle("Disconnect", for: UIControlState())
    }
    func loginfailnotif(_ notification:Notification)
    {
        let alertController = UIAlertController(title: "WiredLineAlert", message: "ログイン名かパスワードが違います。", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
        NotificationCenter.default.removeObserver(loginfail)
        indicatorstop(notification as AnyObject)
    }
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
