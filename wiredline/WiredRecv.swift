//
//  WiredRecv.swift
//  wiredline
//
//  Created by HiraoKazumasa on 10/21/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import Foundation
import UIKit
protocol ChatDelegate:class{
    func addChatLine(attstr:NSAttributedString)->Void
    func WLListReload()->Void
    func chatWindowActive()
}
extension ChatDelegate{
    func addChatLine(attstr:NSAttributedString)->Void
    {
        print("test")
    }
    func WLListReload()->Void
    {
        print("userlisttest")
    }
    func chatWindowActive()
    {
        print("chatWindowActive")
    }
}
extension String {
    fileprivate func convertFullWidthToHalfWidth(_ reverse: Bool) -> String {
        let str = NSMutableString(string: self) as CFMutableString
        CFStringTransform(str, nil, kCFStringTransformFullwidthHalfwidth, reverse)
        return str as String
    }
    
    var hankaku: String {
        return convertFullWidthToHalfWidth(false)
    }
    
    var zenkaku: String {
        return convertFullWidthToHalfWidth(true)
    }
}


var serverinfoarray:[String]=Array()

var chat:[String]=Array()
var user:[String]=Array()
var idle:[String]=Array()
var admin:[String]=Array()
var icon:[String]=Array()
var nick:[String]=Array()
var login:[String]=Array()
var ip:[String]=Array()
var host:[String]=Array()
var status:[String]=Array()
var image:[String]=Array()
var myid:String=String()
var newsarray:[NSAttributedString]=Array()
var newsstrarray:[String]=Array()
let loginsuccess="LOGINSUCCESS"
let callchatwindow="CALLCHATWINDOW"
let callnewconnectionwindow="CALLNEWCONNECTIONWINDOW"
let addchat="ADDCHAT"
let listreload="USERLISTRELOAD"
let wipmrecv="WIPMRECV"
let addimage="ADDIMAGE"
let setuserinfo="SETUSERINFO"
let getnewsdone="GETNEWSDONE"
let reloadwatchuserlist="WATCHUSERLISTRELOAD"
let transfernotification="TRANSFERNOTIFICATION"
let transferreload="WITRANSFERRELOAD"
let cleartransferlist="WICLEARTRANSFERLIST"
var bankickflag=0
/*protocol WiredRecvMethod{
    func getServerInfo(_ str:String)
}*/
class WiredRecv:UIViewController {
    let wlstr:WLString=WLString()
    let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var window:UIWindow=UIWindow()
    //weak var delegate:ChatDelegate?
    func getServerInfo(_ str:String)
    {
        #if WIREDRECVDEBUG
            print("getserverinfo")
            #endif
        let string:String
        let wiredsend:WiredSend=WiredSend()
        string=(str as NSString).substring(from: 4)
        let ffs:CharacterSet=CharacterSet(charactersIn:String(fs))
        serverinfoarray=string.components(separatedBy: ffs)
        #if WIREDRECVDEBUG
        print(serverinfoarray)
        #endif
        self.clearUserlist()
        wiredsend.sendNickCommend(logininfo[2])
        wiredsend.sendIconCommand(logininfo[5])//settingを書いた後に変える
        wiredsend.sendStatusCommand(logininfo[3])
        wiredsend.sendClientCommand()
        wiredsend.sendUserCommand(logininfo[0])
        wiredsend.sendPasswordCommand(logininfo[1])
        
    }
    func clearUserlist(){
        chat.removeAll()
        user.removeAll()
        idle.removeAll()
        admin.removeAll()
        icon.removeAll()
        nick.removeAll()
        login.removeAll()
        ip.removeAll()
        host.removeAll()
        status.removeAll()
        image.removeAll()
        
    }
    func loginSuccess(_ str:String)
    {
        #if WIREDRECVDEBUG
            print("loginSuccess")
            #endif
        
        let wiredsend:WiredSend=WiredSend()
        let ffs:CharacterSet=CharacterSet(charactersIn:String(fs))
        let array=str.components(separatedBy: ffs)
        var nf:Notification=Notification(name: Notification.Name(rawValue: loginsuccess), object: self)
        //let delegate=WLChat()
        NotificationCenter.default.post(nf)
        nf=Notification(name: Notification.Name(rawValue: callchatwindow), object: self)
        NotificationCenter.default.post(nf)
        //delegate.chatWindowActive()
        myid=array[0]
        wiredsend.sendGetUserlist(pubchat)
        wiredsend.sendWiredPing()
    }
    func sendLoinFailNotof()
    {
        serverinfoarray=Array()
        let nf:Notification=Notification(name: Notification.Name(rawValue: loginfail), object: self)
        NotificationCenter.default.post(nf)
    }
    func wiclientkicked(_ str:String)
    {
        let string=(str as NSString).substring(from: 4)
        let ffs:CharacterSet=CharacterSet(charactersIn:String(fs))
        let array=string.components(separatedBy: ffs)
        bankickflag=1
        let message="<<< "+self.findNickFromID(array[0])+" "+"was kicked by"+" "+self.findNickFromID(array[1])+" >>>\n"
        let attmess=NSAttributedString(string: message, attributes: [NSAttributedStringKey.foregroundColor:UIColor.red])
        let nf=Notification(name: Notification.Name(rawValue: addchat), object: self,userInfo:["chat":attmess] )
        NotificationCenter.default.post(nf)
        self.removeUser(array[0])
        //print(WICLIENTLEAVE+String(sp)+"1"+String(fs)+array[0]+String(term))
        //self.recvClientLeave(WICLIENTLEAVE+String(sp)+"1"+String(fs)+array[0]+String(term), command: WICLIENTKICKED)
        
    }
    func wiclientBanned(_ str:String)
    {
        let string=(str as NSString).substring(from: 4)
        let ffs:CharacterSet=CharacterSet(charactersIn:String(fs))
        let array=string.components(separatedBy: ffs)
        let message="<<< "+self.findNickFromID(array[0])+" "+"was banned by"+" "+self.findNickFromID(array[1])+" >>>\n"
        let attmess=NSAttributedString(string: message, attributes: [NSAttributedStringKey.foregroundColor:UIColor.red])
        let nf=Notification(name: Notification.Name(rawValue: addchat), object: self,userInfo:["chat":attmess] )
        NotificationCenter.default.post(nf)
        self.removeUser(array[0])
        //print(WICLIENTLEAVE+String(sp)+"1"+String(fs)+array[0]+String(term))
        bankickflag=1
        //self.recvClientLeave(WICLIENTLEAVE+String(sp)+"1"+String(fs)+array[0]+String(term), command: WICLIENTKICKED)
        
    }
    func removeUser(_ str:String)
    {
        let nf:Notification=Notification(name: Notification.Name(rawValue: listreload), object: self)
        var i=0
        i=user.index(of: str)!
        chat.remove(at: i)
        user.remove(at: i)
        idle.remove(at: i)
        admin.remove(at: i)
        icon.remove(at: i)
        nick.remove(at: i)
        login.remove(at: i)
        ip.remove(at: i)
        host.remove(at: i)
        status.remove(at: i)
        image.remove(at: i)
        NotificationCenter.default.post(nf)
    }
    func recvOptChat(_ str:String)
    {
        let string=(str as NSString).substring(from: 4)
        let ffs:CharacterSet=CharacterSet(charactersIn:String(fs))
        let array=string.components(separatedBy: ffs)
        var nickname:String=findNickFromID(array[1])
        var opt="***"
        //var nf:NSNotification=NSNotification()
        nickname+=" "+array[2] as String + "\n"
        opt+=nickname//print(nickname)
        let attr=NSAttributedString(string: opt)
        let nf=Notification(name: Notification.Name(rawValue: addchat), object: self,userInfo:["chat":attr] )
        NotificationCenter.default.post(nf)
        
    }
    func recvWiredPing()
    {
        #if DEBUG
            print("recvWiredPing")
            #endif
        let wisend:WiredSend=WiredSend()
        wisend.sendWiredPing()
        
    }
    func recvUserlist(_ str:String,command:String)
    {
        #if DEBUG
            print("recvUserList")
            #endif
        let string:String
        string=(str as NSString).substring(from: 4)
        let ffs:CharacterSet=CharacterSet(charactersIn:String(fs))
        let array=string.components(separatedBy: ffs)
        let cnt=chat.count
        //var delegate:ChatDelegate?
        let nf:Notification=Notification(name: Notification.Name(rawValue: listreload), object: self)
        //var delegate:ChatDelegate?
        //delegate=WLChat()
        if command != WIUSERLISTDONE{
        chat.insert(array[0],at: cnt)
        user.insert(array[1],at: cnt)
        idle.insert(array[2],at: cnt)
        admin.insert(array[3],at: cnt)
        icon.insert(array[4], at: cnt)
        nick.insert(array[5], at: cnt)
        login.insert(array[6], at: cnt)
        ip.insert(array[7], at: cnt)
        host.insert(array[8], at: cnt)
        status.insert(array[9], at: cnt)
        image.insert(array[10], at: cnt)
        NotificationCenter.default.post(nf)
        //DispatchQueue.global(qos: .default).sync{
          //  DispatchQueue.main.async {
            //    delegate?.WLListReload()
            //}
        //}
        if(command==WICLIENTJOIN){
            var messe:String="<<< "
            let nick=findNickFromID(user[cnt])
            messe+=nick+" has joined>>>\n"
            let attmess=NSAttributedString(string: messe, attributes: [NSAttributedStringKey.foregroundColor:UIColor.red])
            let nf=Notification(name: Notification.Name(rawValue: addchat), object: self,userInfo:["chat":attmess] )
            NotificationCenter.default.post(nf)
        }
        }
        if command==WIUSERLISTDONE{
            //print("done userls")
            //DispatchQueue.global(qos: .default).sync{
              //  DispatchQueue.main.async {
                //    delegate?.WLListReload()
                  //  print(nick)
                //}
            //}
        }
        
        //print(nick)
    }
    
    func recvChat(_ str:String)
    {
        let string=(str as NSString).substring(from: 4)
        let ffs:CharacterSet=CharacterSet(charactersIn:String(fs))
        let array=string.components(separatedBy: ffs)
        let attarray:[NSAttributedString]
        var nickname:String=findNickFromID(array[1])
        //print(str.dataUsingEncoding(NSUTF8StringEncoding))
        //var nf:NSNotification=NSNotification()
        nickname+=" : "+array[2] + "\n" as String
        let attmess=NSAttributedString(string: nickname, attributes: [NSAttributedStringKey.foregroundColor:UIColor.black])
        //self.delegate=delegate
        //var delegate:ChatDelegate?
        if(wlstr.ssWiredStringCheck(nickname)==false && nickname.lengthOfBytes(using: String.Encoding.utf8)<1000){
            let nf=Notification(name: Notification.Name(rawValue: addchat), object: self,userInfo:["chat":attmess] )
            NotificationCenter.default.post(nf)
            //delegate=WLChat() as ChatDelegate
            //OperationQueue.main.addOperation(){
              //  delegate?.addChatLine(attstr: attmess)
            //}
            
            
        }else{
            attarray=wlstr.ssWiredImageCheck(nickname)
            //for(var i=0;i<attarray.count;i++){
            let arraycount=attarray.count
            for i in 0..<arraycount {
                if(attarray[i].length>100){
                    let nf=Notification(name: Notification.Name(rawValue: addimage), object: self,userInfo:["image":attarray[i]] )
                    NotificationCenter.default.post(nf)
                }else{
                    if(attarray.count>1){
                    let nf=Notification(name: Notification.Name(rawValue: addchat), object: self,userInfo:["chat":attarray[i]] )
                    NotificationCenter.default.post(nf)
                    }
                }
                
            }
        }
        //self.delegate=WLChat()
        //self.delegate?.addChatLine(attstr: nickname)
        
    }
    func statusChanged(_ str:String,command:String)
    {
        let string=(str as NSString).substring(from: 4)
        let ffs:CharacterSet=CharacterSet(charactersIn:String(fs))
        let array=string.components(separatedBy: ffs)
        let id=array[0]
        let index=user.index(of: id)
        user[index!]=array[0]
        idle[index!]=array[1]
        admin[index!]=array[2]
        icon[index!]=array[3]
        nick[index!]=array[4]
        status[index!]=array[5]
        
        let nf:Notification=Notification(name: Notification.Name(rawValue: listreload), object: self)
        NotificationCenter.default.post(nf)
    }
    func recvClientLeave(_ str:String,command:String){
        let string=(str as NSString).substring(from: 4)
        var messe:String="<<< "
        var i:NSInteger
        //var cnt:Int
        //var id:String=String()
        let nickname:String
        let ffs:CharacterSet=CharacterSet(charactersIn:String(fs))
        let array=string.components(separatedBy: ffs)
        let nf:Notification=Notification(name: Notification.Name(rawValue: listreload), object: self)
        nickname=findNickFromID(array[1])
        i=user.index(of: array[1])!
        chat.remove(at: i)
        user.remove(at: i)
        idle.remove(at: i)
        admin.remove(at: i)
        icon.remove(at: i)
        nick.remove(at: i)
        login.remove(at: i)
        ip.remove(at: i)
        host.remove(at: i)
        status.remove(at: i)
        image.remove(at: i)
        
        if(command==WICLIENTLEAVE){
            
            messe+=nickname+" has left >>>\n"
            let attmess=NSAttributedString(string: messe, attributes: [NSAttributedStringKey.foregroundColor:UIColor.red])
            //NSAttributedString(string: nickname)
            let nof=Notification(name: Notification.Name(rawValue: addchat), object: self,userInfo:["chat":attmess] )
            NotificationCenter.default.post(nof)

        }
        NotificationCenter.default.post(nf)
        bankickflag=0
    }
    
    func findNickFromID(_ id:String)->String
    {
        #if DEBUG
            print("findNick")
            #endif
        var nickname:String=String()
        let index=user.index(of: id)
        nickname=nick[index!]
        return(nickname)
        
    }
    func wiRecvPM(_ str:String)
    {
        let string=(str as NSString).substring(from: 4)
        let ffs:CharacterSet=CharacterSet(charactersIn:String(fs))
        let array=string.components(separatedBy: ffs)
        
        let nick=findNickFromID(array[0])
        //nick+=" wrote: "
        //print(nick)
        let nf=Notification(name: Notification.Name(rawValue: wipmrecv), object: self,userInfo: ["msgs":nick])
        NotificationCenter.default.post(nf)
        let alert = UIAlertController(title: nick+" wrote:", message: array[1], preferredStyle: .alert)
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",
                                                       style: UIAlertActionStyle.cancel,
                                                       handler:{
                                                        (action:UIAlertAction!) -> Void in
                                                        #if DEBUG
                                                        print("Cancel")
                                                        #endif
        })
        let okAction:UIAlertAction = UIAlertAction(title: "Reply",
                                                       style: UIAlertActionStyle.destructive,
                                                       handler:{
                                                        (action:UIAlertAction!) -> Void in
                                                        #if DEBUG
                                                        print("Reply")
                                                        #endif
                                                        let alert:UIAlertController = UIAlertController(title:"Message to "+nick,
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
                                                                wiredsend.wiredSendPrivateMsg(textFields![0].text! as String, id: array[0] as String)
                                                                
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
        })

        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alertWindow.rootViewController = UIViewController()
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
    }
    func wiRecvUserInfo(_ str:String)
    {
        let string=(str as NSString).substring(from: 4)
        let ffs:CharacterSet=CharacterSet(charactersIn: String(fs))
        let array=string.components(separatedBy: ffs)
        let dic:NSDictionary=NSMutableDictionary()
        var nf=Notification(name: Notification.Name(rawValue: cleartransferlist), object: self, userInfo: dic as? [AnyHashable: Any])
        NotificationCenter.default.post(nf)
        dic.setValue(array[0], forKey: "id")
        dic.setValue(array[4], forKey: "nick")
        dic.setValue(array[5], forKey: "login")
        dic.setValue(array[6], forKey: "ip")
        dic.setValue(array[7], forKey: "host")
        dic.setValue(array[8], forKey: "version")
        dic.setValue(array[9]+array[10], forKey: "cipher")
        dic.setValue(array[11], forKey: "logintime")
        dic.setValue(array[12], forKey: "idletime")
        dic.setValue(array[13], forKey: "download")
        dic.setValue(array[14], forKey: "upload")
        dic.setValue(array[15], forKey: "status")
        dic.setValue(array[16], forKey: "image")
        nf=Notification(name: Notification.Name(rawValue: setuserinfo), object: self, userInfo: dic as? [AnyHashable: Any])
        NotificationCenter.default.post(nf)
        var ggs:CharacterSet=CharacterSet(charactersIn: String(gs))
        var garray=array[13].components(separatedBy: ggs)
        if array[13] != ""{
        for str in garray{
            #if DEBUG
                print(garray)
            #endif
            if dic["id"] as! String==userIndex{
            dic.setValue(str, forKey: "transfer")
            dic.setValue("Download",forKey:"transfertype")
            let nf=Notification(name: Notification.Name(rawValue: transfernotification), object: self, userInfo: dic as? [AnyHashable: Any])
            NotificationCenter.default.post(nf)
            }
        }
        }
        ggs=CharacterSet(charactersIn: String(gs))
        garray=array[14].components(separatedBy: ggs)
        #if DEBUG
            print(garray)
        #endif
        if array[14] != ""{
        for str in garray{
            if dic["id"] as! String==userIndex{
            dic.setValue(str, forKey: "transfer")
            dic.setValue("Upload",forKey:"transfertype")
            let nf=Notification(name: Notification.Name(rawValue: transfernotification), object: self, userInfo: dic as? [AnyHashable: Any])
            NotificationCenter.default.post(nf)
        }
            }
        }
        
        /*if(array[13] != ""){
            #if DEBUG
                print("extra info")
            #endif
            let ggs:CharacterSet=CharacterSet(charactersIn: String(gs))
            let garray=array[13].components(separatedBy: ggs)
            for str in garray{
                #if DEBUG
                    print(garray)
                    #endif
                dic.setValue(str, forKey: "transfer")
                dic.setValue("Download",forKey:"transfertype")
                let nf=Notification(name: Notification.Name(rawValue: transfernotification), object: self, userInfo: dic as? [AnyHashable: Any])
                NotificationCenter.default.post(nf)
            }
            
        }
        if(array[14] != ""){
            #if DEBUG
                print("extra info")
            #endif
            let ggs:CharacterSet=CharacterSet(charactersIn: String(gs))
            let garray=array[14].components(separatedBy: ggs)
            #if DEBUG
                print(garray)
            #endif
            for str in garray{
                dic.setValue(str, forKey: "transfer")
                dic.setValue("Upload",forKey:"transfertype")
                let nf=Notification(name: Notification.Name(rawValue: transfernotification), object: self, userInfo: dic as? [AnyHashable: Any])
                NotificationCenter.default.post(nf)
            }
            
        }*/
        nf=Notification(name: Notification.Name(rawValue: transferreload), object: self, userInfo: dic as? [AnyHashable: Any])
        NotificationCenter.default.post(nf)
        
        
    }
    //TODO:
    //ニュースの改行など。ssWiredCheckも。
    
    /*func wiRecvNews(str:String)
    {
        var attr=NSAttributedString()
        #if DEBUG
        print("wiRecvNews:ok")
            //print("str")
        #endif
        var newstemp=[String]()
        var string="From "+(str as NSString).substringFromIndex(4)
        let ffs:NSCharacterSet=NSCharacterSet(charactersInString: String(fs))
        newstemp=string.componentsSeparatedByCharactersInSet(ffs)
        string=String()
        let newscount=newstemp.count
        #if DEBUG
            print("newscount=",newscount)
            #endif
        for i in 0..<newscount{
            if i == 1 {
                string+=newstemp[i] as String+"\n\n"
            }else if i == 2{
                string+=newstemp[i] as String
            }else if i == 0 {
                string+=newstemp[i] as String+"    "
            }
            
        }
        string+="\n\n\n"
        attr=NSAttributedString(string: string)
        newsarray.insert(attr, atIndex: newsarray.count)
        newsstrarray.insert(string, atIndex: newsstrarray.count)
    }*/
    func wiRecvNews(_ str:String)
    {
        var string="From "+(str as NSString).substring(from: 4)
        let ffs:CharacterSet=CharacterSet(charactersIn: String(fs))
        var newstemp=string.components(separatedBy: ffs)
        string=String()
        string=newstemp[0]
        newsstrarray.insert(string, at: newsstrarray.count)
        string="        "+newstemp[1]+"\n\n"+"  "
        newsstrarray.insert(string, at: newsstrarray.count)
        string=newstemp[2]+"\n\n"
        string=string.replacingOccurrences(of: "<div>", with: "")
        //string=string.convertFullWidthToHalfWidth(false)
        newsstrarray.insert(string,at:newsstrarray.count)
    }
    func wiNewsDone(){
        #if DEBUG
        print("wirednewsdone:ok")
        #endif
        let nf=Notification(name: Notification.Name(rawValue: getnewsdone), object: self, userInfo: nil)
        NotificationCenter.default.post(nf)
        
    }
    func wiClientImageChange(_ str:String)
    {
        #if DEBUG
        print("wiClientImageChange")
        #endif
        let nf=Notification(name:Notification.Name(rawValue: listreload), object:self,userInfo:nil)
        let string=(str as NSString).substring(from: 4)
        let ffs:CharacterSet=CharacterSet(charactersIn: String(fs))
        let iconarray=string.components(separatedBy: ffs)
        let index=user.index(of: iconarray[0] as String)
        print(iconarray)
        image[index!]=iconarray[1]
        NotificationCenter.default.post(nf)
    }
    
    
}
