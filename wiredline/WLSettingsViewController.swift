//
//  WLSettingsViewController.swift
//  wiredline
//
//  Created by HiraoKazumasa on 10/31/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import UIKit

let chatnotification="NOTIFICATIONSEND"

class WLSettingsViewController: UITableViewController,UIPickerViewDelegate{
    @IBOutlet var picker:UIPickerView!
    @IBOutlet var tableview:UITableView!
    @IBOutlet var nickbox:UITextField!
    @IBOutlet var savebutton:UIButton!
    @IBOutlet var statusbox:UITextField!
    @IBOutlet var nav:UINavigationBar!
    @IBOutlet var hliconview:UIButton!
    @IBOutlet weak var notifswitch:UISwitch!
    @IBOutlet weak var wirediconbutton:UIButton!
    
    
    internal var watchstatus=false
    fileprivate let enc:NSArray=["UTF-8","SHIFT-JIS"] // add encoding here
    var Items=["Nick","Status"]
    var ud:UserDefaults=UserDefaults()
    var oldnick:String=String()
    var oldstatus:String=String()
    var oldiconno:NSString?=String() as NSString?
    var iconstr:String=String()
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("viewdid")
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //print("viewwill")
        self.initbox()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initbox()
    {
        ud=UserDefaults.standard
        let bundle=Bundle.main.path(forResource: "hotwireAdditional", ofType: "bundle")
        var path:String
        path=bundle!
        var results:String!=ud.object(forKey: "nick") as! String!
        if(results==nil){
            nickbox.text="No Name"
        }else{
            nickbox.text=results
        }
        results=(ud.object(forKey: "status") as AnyObject!) as! String!
        if(results==nil){
            statusbox.text=""
        }else{
            statusbox.text=results
        }
        results=(ud.object(forKey: "iconno") as AnyObject!) as! String!
        if(results==nil){
            path=NSString(string: (Bundle.main.path(forResource: "hotwireAdditional", ofType: "bundle"))!).appendingPathComponent("Icons")
            path=Bundle.path(forResource: "11", ofType: "png", inDirectory: path)!
            iconstr="11"
        }else{
            path=NSString(string: (Bundle.main.path(forResource: "hotwireAdditional", ofType: "bundle"))!).appendingPathComponent("Icons")
            path=Bundle.path(forResource: results as String?, ofType: "png", inDirectory: path)!
            iconstr=results
        }

        
        results=ud.object(forKey: "notificationstatus") as! String!
        if results==nil {
            notifswitch.setOn(true, animated: true)
            //notifswitch.setOn(true, animated: true)
            ud.set("true", forKey: "notificationstatus")
            ud.synchronize()
        }
        results=(ud.object(forKey: "notificationstatus") as AnyObject!) as! String!
        if results == "true"{
            notifswitch.setOn(true, animated: true)
            ud.set("true", forKey: "notificationstatus")
            ud.synchronize()
        }else{
            notifswitch.setOn(false, animated: true)
            ud.set("false", forKey: "notificationstatus")
            ud.synchronize()
        }
        results=(ud.object(forKey: "wiredicon") as AnyObject!) as! String!
        if results==nil{
            let data=Data(base64Encoded: WIDEFAULTICON, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            let iimage=UIImage(data: data!)
            //wirediconbutton.imageView?.image=iimage
            wirediconbutton.setBackgroundImage(iimage, for: .normal)
        }else{
            let data=Data(base64Encoded: results, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            let iimage=UIImage(data: data!)
            //wirediconbutton.imageView?.image=iimage
            wirediconbutton.setBackgroundImage(iimage, for: .normal)
        }
        let myImage=UIImage(named: path)
        hliconview.imageView?.image=myImage
        oldnick=nickbox.text!
        oldstatus=statusbox.text!
        hliconview.imageView?.contentMode=UIViewContentMode.scaleToFill
        let buttonImage:UIImage = UIImage(named: path)!;
        hliconview.setImage(buttonImage, for: UIControlState());
        //notifswitch.setOn(results as! Bool, animated: true)
        
        
        
    }
    @IBAction func notificationSwitchOnOff(_ sender:UISwitch)
    {
        var status:String
        if notifswitch.isOn{
            #if DEBUG
                print("notificationOn")
                #endif
            status="true"
            let nf=Notification(name: Notification.Name(rawValue: chatnotification), object: self, userInfo: ["switchstatus":"on"])
            NotificationCenter.default.post(nf)
        }else {
            status="false"
            #if DEBUG
                print("notificationOFF")
            #endif
            let nf=Notification(name: Notification.Name(rawValue: chatnotification), object: self, userInfo: ["switchstatus":"off"])
            NotificationCenter.default.post(nf)
        }
        let ud=UserDefaults.standard
        let results=ud.object(forKey: "notificationstatus")
        if results==nil{
            //ud.removeObjectForKey("notificaionstatus")
            ud.set(status, forKey: "notificationstatus")
            ud.synchronize()
        }else{
            ud.removeObject(forKey: "notificaionstatus")
            ud.set(status, forKey: "notificationstatus")
            ud.synchronize()
            
        }
        
    }
    @IBAction func pushSaveButton(_ sender:UIButton)
    {
        var iconno:String=String()
        
        if(wiredflag==1 && outputHLStream != nil && inputHLStream != nil){
            let wisend:WiredSend=WiredSend()
            if(oldnick==""){
                oldnick="Jon Smith :)"
            }
            if(oldnick != nickbox.text){
                wisend.sendNickCommend(nickbox.text!)
            }
            if(oldstatus != statusbox.text){
                wisend.sendStatusCommand(statusbox.text!)
            }
        }
        if(wiredflag==0 && outputHLStream != nil && inputHLStream != nil){
                if(oldnick != nickbox.text){
                    let hlsend:HLSend=HLSend()
                    ud=UserDefaults.standard
                    let results=ud.object(forKey: "iconno")
                    if results != nil{
                    iconno=results as! String
                    }else{
                        iconno="11"
                    }
                    hlsend.sendNickIcon(nickbox.text!, icon: results as! String)
                }
            }
        
        ud=UserDefaults.standard
        var results=ud.object(forKey: "iconno")
        if(oldiconno==nil){
            oldiconno="11"
        }
        if results==nil {
            oldiconno="11"
            results="11"
        }
        //results=oldiconno
        if(oldiconno! as String != results as! String){
            ud.removeObject(forKey: "iconno")
            ud.set(iconno , forKey: "iconno")
        }
        iconno=results as! String
        #if DEBUG
            print("iconno=",results as! String)
            #endif
        ud.removeObject(forKey: "nick")
        ud.removeObject(forKey: "status")
        //ud.removeObject(forKey: "wiredicon")
        ud.set(nickbox.text, forKey: "nick")
        ud.set(statusbox.text, forKey: "status")
        ud.removeObject(forKey: "iconno")
        ud.set(iconno , forKey: "iconno")
        ud.synchronize()
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - PickerView
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return enc.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return enc[row] as? String
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //print("row: \(row)")
        //print("value: \(enc[row])")
        let hlsend=HLSend()
        switch(row){
        case 0:
            encoding=String.Encoding.utf8
            break
        case 1:
            encoding=String.Encoding.shiftJIS
            break;
        case 2:
            encoding=String.Encoding.ascii
            break
        case 3:
            encoding=String.Encoding.japaneseEUC
            break
        default:
            encoding=String.Encoding.utf8
            break
        }
        hluidarray.removeAllObjects()
        hlnicknamearray.removeAllObjects()
        hliconarray.removeAllObjects()
        //let sendstr=nickbox.text?.data(using: encoding, allowLossyConversion: true)
        //hlsend.sendNickIcon(NSString(data:sendstr!,encoding:String.Encoding.utf8.rawValue)!as String , icon: iconstr)
        hlsend.HLGetUerlist()
        let sendstr=nickbox.text?.data(using: encoding, allowLossyConversion: true)
        hlsend.sendNickIcon(NSString(data:sendstr!,encoding:encoding.rawValue)!as String , icon: iconstr)
    }
    
}
