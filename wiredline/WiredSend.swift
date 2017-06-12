//
//  WiredSend.swift
//  wiredline
//
//  Created by HiraoKazumasa on 10/20/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import UIKit
extension UIImage
{
    var highestQualityJPEGNSData: Data { return UIImageJPEGRepresentation(self, 1.0)! }
    var highQualityJPEGNSData: Data    { return UIImageJPEGRepresentation(self, 0.75)!}
    var mediumQualityJPEGNSData: Data  { return UIImageJPEGRepresentation(self, 0.5)! }
    var lowQualityJPEGNSData: Data     { return UIImageJPEGRepresentation(self, 0.25)!}
    var lowestQualityJPEGNSData: Data  { return UIImageJPEGRepresentation(self, 0.0)! }
    
}
public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "A4 iPhone 4"
        case "iPhone4,1":                               return "A5 iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "A6 iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "A6 iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "A7 iPhone 5s"
        case "iPhone7,2":                               return "A8 iPhone 6"
        case "iPhone7,1":                               return "A8 iPhone 6 Plus"
        case "iPhone8,1":                               return "A9 iPhone 6s"
        case "iPhone8,2":                               return "A9X iPhone 6s Plus"
        case "iPhone8,4":                               return "A9 iPhone SE"
        case "iPhone9,1":                               return "A10 iPhone7"
        case "iPhone9,3":                               return "A10 iPhone7"
        case "iPhone9,2":                               return "A10 iPhone7 Plus"
        case "iPhone9,4":                               return "A10 iPhone7 Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "A5 iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "A5X iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "A6X iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "A7 iPad Air"
        case "iPad5,1", "iPad5,3", "iPad5,4":           return "A8X iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "A5 iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "A7 iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "A7 iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "A8 iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "A9X iPad Pro"
        case "iPad6,3", "iPad6,4":                      return "A9X iPad Pro"
        case "i386", "x86_64":                          return "X86_64 Simulator"
        default:                                        return identifier
        }
    }
    
}


let WISENDHELLO:String="HELLO"
let WINICK:String="NICK"
let WIICON="ICON"
let WISTATUS="STATUS"
let WICLIENT="CLIENT"
let WILOGIN="USER"
let WIMSG="MSG"
let WIPASS="PASS"
let WIWHO="WHO"
let WIPING="PING"
let WICHAT="SAY"
let WIINFO="INFO"
let WINEWS="NEWS"
let WINEWSPOST="POST"
let WIKICK="KICK"
let WIBAN="BAN"
let WIOPT="ME"
//MARK:FILECOMMAND
let WILIST="LIST"
var pingtime=100

let pubchat="1"
let ssWiredsp=Character(UnicodeScalar(0x0e))
let term=Character(UnicodeScalar(04))
let fs=Character(UnicodeScalar(28))
let gs=Character(UnicodeScalar(29))
let rs=Character(UnicodeScalar(30))
let sp=Character(UnicodeScalar(32))
let APPVER="WiredLine/0.0.1-1 ("

let WIDEFAULTICON="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"

protocol wiredSendDelegate{
    func sendHelloCommand()
}

class WiredSend: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func sendWiChat(_ str:String)
    {
        let command=WICHAT+String(sp)+"1"+String(fs)+str+String(term)
        //print(command)
        self.writeToServer(command)
    }
    func sendWiMeChat( _ str:String)
    {
        let string=(str as NSString).substring(from: 3)
        let command=WIOPT+String(sp)+"1"+String(fs)+string+String(term)
        //print(command)
        self.writeToServer(command)
    }
    func sendWIInfo(_ str:String)
    {
        var infostring=WIINFO
        infostring+=String(sp)+str+String(term)
        self.writeToServer(infostring)
    }
    
    func sendHelloCommand()
    {
        let command=WISENDHELLO+String(term)
        #if DEBUG
        print("sendhellocommand:", command)
        #endif
        writeToServer(command)
        //sendNickCommend(logininfo[2])
        //sendIconCommand(WIDEFAULTICON)
        //sendStatusCommand("")
        //sendClientCommand()
        //sendUserCommand(logininfo[0])
        //sendPasswordCommand(logininfo[1])
        
        
    }
    func sendNickCommend(_ nick:String)
    {
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let command=WINICK+String(sp)+nick+String(term)
        writeToServer(command)
    }
    func sendIconCommand(_ icon:String)
    {
        let command=WIICON+String(sp)+"1"+String(fs)+icon+String(term)
        writeToServer(command)
    }
    func sendStatusCommand(_ status:String){
        let command=WISTATUS+String(sp)+status+String(term)
        /*"if (status==""){
            status=""
        }*/
        //command+String(sp)+"test"+String(term)
        #if DEBUG
        print(command)
        #endif
        writeToServer(command)
    }
    func sendClientCommand()
    {
        let modelName=UIDevice.current.modelName
        let osVersion=UIDevice.current.systemVersion
        _=NSString(format: "%0.3.f", osVersion)
        //let cpu=platform()
        //print(cpu)
        var command=WICLIENT+String(Character(UnicodeScalar(32)))+APPVER+"iOS;"+String(Character(UnicodeScalar(32)))
        command+=osVersion+";"+String(Character(UnicodeScalar(32)))+modelName+")"+String(Character(UnicodeScalar(04)))
        //var data:NSData=NSData()
        //data=command.dataUsingEncoding(NSUTF8StringEncoding)!
        //let obj:objcmethod=objcmethod()
        //data=obj.cleanUTF8(data)
        //command=String(NSString(data: data, encoding: NSUTF8StringEncoding))
        #if DEBUG
            print(command.data(using: String.Encoding.utf8)!)
            //print(data)
            #endif
        
        writeToServer(command)
    }
    
    func sendUserCommand(_ login:String)
    {
        let command=WILOGIN+String(sp)+login+String(term)
        writeToServer(command)
        
    }
    func sendPasswordCommand(_ passwd:String)
    {
        let objc:objcmethod=objcmethod()
        var enpass:String=String()
        if passwd.isEmpty{
            enpass=""
        }else{
            enpass=objc.sha1(passwd)
        }
        let command=WIPASS+String(sp)+enpass+String(term)
        
        writeToServer(command)
    }
    func platform() -> String {
        var sysinfo = utsname()
        
        uname(&sysinfo) // ignore return value
        var str:String
        var data:Data=Data()
        str=NSString(bytes: &sysinfo.machine, length: Int(_SYS_NAMELEN), encoding: String.Encoding.utf8.rawValue)! as String
        data=str.data(using: String.Encoding.utf8)!
        print(data)
        str=NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        return str
    }
    func sendWiredPing()
    {
        #if DEBUG
            print("sendWiredPing")
            #endif
        let command=WIPING+String(term)
        let queue=OperationQueue()
        queue.addOperation { () -> Void in
            if wiredflag==1{
                sleep(UInt32(pingtime))
                self.writeToServer(command)
            }
        }
        
    }
    func wiredSendPrivateMsg(_ str:String,id:String)
    {
        let command=WIMSG+String(sp)+id+String(fs)+str+String(term)
        //print(command)
        self.writeToServer(command)
    }
    func postWiredNews(_ str:String)
    {
        let command=WINEWSPOST+String(sp)+str+String(term)
        self.writeToServer(command)
    }
    
    func wiredClientKick(_ num:String,message:String)
    {
        let command=WIKICK+String(sp)+num+String(fs)+message+String(term)
        self.writeToServer(command)
    }
    
    func wiredClientBan(_ num:String,message:String)
    {
        let command=WIBAN+String(sp)+num+String(fs)+message+String(term)
        self.writeToServer(command)
    }
    func writeToServer(_ str:String)
    {
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let data:Data=str.data(using: String.Encoding.utf8)!
        var length:Int
        let _:Int
        length=data.count
        //outputHLStream?.write(UnsafePointer<UInt8>((data as NSData).bytes), maxLength: length)
        outputHLStream?.write(UnsafeRawPointer((data as NSData).bytes).assumingMemoryBound(to: UInt8.self),maxLength: length)
        /*let alert = UIAlertController(title: "Wired Line Alert", message: "ネットワークに接続されていません。", preferredStyle: .Alert)
         let alertWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
         let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
         style: UIAlertActionStyle.Cancel,
         handler:{
         (action:UIAlertAction!) -> Void in
         #if DEBUG
         print("Cancel")
         #endif
         })
         let okAction:UIAlertAction = UIAlertAction(title: "Reconnect",
         style: UIAlertActionStyle.Destructive,
         handler:{
         (action:UIAlertAction!) -> Void in
         #if DEBUG
         print("Reconnect")
         #endif
         let alert:UIAlertController = UIAlertController(title:"Message to "+nick,
         message: "Message:",
         preferredStyle: UIAlertControllerStyle.Alert)
         
         let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",
         style: UIAlertActionStyle.Cancel,
         handler:{
         (action:UIAlertAction!) -> Void in
         
         })
         let defaultAction:UIAlertAction = UIAlertAction(title: "OK",
         style: UIAlertActionStyle.Default,
         handler:{
         (action:UIAlertAction!) -> Void in
         let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
         if textFields != nil {
         for _:UITextField in textFields! {
         
         }
         }
         
         
         })
         alert.addAction(cancelAction)
         alert.addAction(defaultAction)
         
         //textfiledの追加
         alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
         })
         //実行した分textfiledを追加される。
         //alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
         //})
         let alertWindow=UIWindow(frame:UIScreen.mainScreen().bounds)
         alertWindow.rootViewController=UIViewController()
         alertWindow.makeKeyAndVisible()
         alertWindow.rootViewController?.presentViewController(alert, animated: true, completion: nil)
         })
         
         alert.addAction(cancelAction)
         alert.addAction(okAction)
         alertWindow.rootViewController = UIViewController()
         alertWindow.makeKeyAndVisible()
         alertWindow.rootViewController?.presentViewController(alert, animated: true, completion: nil)
         }*/

    }
    
    func sendGetUserlist(_ str:String)
    {
        let command=WIWHO+String(sp)+str+String(term)
        writeToServer(command)
        
    }
    func getNews()
    {
        let command=WINEWS+String(term)
        writeToServer(command)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func ssWiredSendImage(_ image:UIImage)
    {
        #if DEBUG
            print("ssWiredSendImage")
            #endif
        var command=String()
        let imageData = image.lowestQualityJPEGNSData
        let imageb=UIImage(data: imageData)
        let imagedata=imageb?.lowQualityJPEGNSData
        let objc=objcmethod()
        
        command="<img src=\"data:image/png;base64,"
        if let pngData=imagedata{
            let encodeString:String=pngData.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithLineFeed)
            command+=encodeString+"\">"+String(term)
            }
        let temp=objc.ssWiredChat(command)
        //print("command=",command)
        writeWiredDataToServer(temp!)
        
    }
//MARK:
    func getWiredFileList(str:String){
        #if DEBUG
            print("getWiredFileList:ok")
        #endif
        var pathstr=String()
        if str=="" {
            pathstr="/"
        }else{
            pathstr=str
        }
        let cmd=WILIST+String(sp)+pathstr+String(term)
        writeToServer(cmd)
    }
    
    func writeWiredDataToServer(_ bdata:Data)
    {
        let length=bdata.count
        outputHLStream?.write((bdata as NSData).bytes.bindMemory(to: UInt8.self, capacity: bdata.count), maxLength: length)
        
    }
    

}
