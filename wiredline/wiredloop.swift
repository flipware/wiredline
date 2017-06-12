//
//  wiredloop.swift
//  wiredline
//
//  Created by HiraoKazumasa on 10/21/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import UIKit

let WISERVERINFO="200"
let WILOGINSUCCESS="201"
let WIRECVPING="202"
let WIRECVCHAT="300"
let WIRECVOPTCHAT="301"
let WICLIENTJOIN="302"
let WICLIENTLEAVE="303"
let WISTATUSCHANGE="304"
let WIRECVPM="305"
let WICLIENTKICKED="306"
let WICLIENTBANNED="307"
let WICLIENTINFO="308"
let WIUSERLIST="310"
let WIUSERLISTDONE="311"
let WIRECVNEWS="320"
let WIREDNEWSDONE="321"
let WIREDNEWSPOSTED="322"
let WIIMAGECHANGE="340"
let WIDIRLIST="410"
let WIDIRLISTDONE="411"
let WILOGINFAIL="510"
let WINOPRIV="516"

var userlistflag:Bool=false
class wiredloop: UIResponder,UIApplicationDelegate {
    let wlnews=WLNewsViewController()
    
    /*override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }*/
    
    func wiredloop(_ data :Data){
        #if WIREDLOOPDEBUG
        print("wiredloop:ok")
        #endif
        let wiredrecv=WiredRecv()
        let wifilerecv=WiredFileRecv()
        let objm:objcmethod=objcmethod()
        let cdata=objm.cleanUTF8(data)
        let str=NSString(data: cdata!, encoding: String.Encoding.utf8.rawValue)
        var array:NSArray=NSArray()
        array=countterm(str! as String)
        let count=array.count
        var command:String=String()
        for i in 0..<count-1{
            command=(array[i] as AnyObject).substring(to: 3)
            let commandtup=(command,userlistflag)
            #if WIREDLOOPDEBUG
                print("------------------------------")
                print(command)
                print(count)
                //print(array[i])
                print("------------------------------")
            #endif
            switch(commandtup){
            case (WISERVERINFO,_):    //200
                wiredrecv.getServerInfo(array[i] as! String)
                break;
            case (WILOGINSUCCESS,_):   //201
                wiredrecv.loginSuccess(array[i] as! String)
                break;
            case (WIRECVPING,_):    //202
                wiredrecv.recvWiredPing()
                break;
            case (WIRECVCHAT,true):  //300
                wiredrecv.recvChat(array[i] as! String)
                break;
            case (WIRECVOPTCHAT,true):  //301
                wiredrecv.recvOptChat(array[i] as! String)
                break;
            case (WICLIENTJOIN,true):  //302
                wiredrecv.recvUserlist(array[i] as! String,command: command)
                break;
            case (WICLIENTLEAVE,true):   //303
                wiredrecv.recvClientLeave(array[i] as! String,command: command)
                break;
            case (WISTATUSCHANGE,true):   //304
                wiredrecv.statusChanged(array[i] as! String,command:command)
                break
            case (WIRECVPM,true):        //305
                wiredrecv.wiRecvPM(array[i] as! String)
                break
            case (WICLIENTKICKED,true):   //306
                wiredrecv.wiclientkicked(array[i] as! String)
                break
            case (WICLIENTBANNED,true):
                wiredrecv.wiclientBanned(array[i] as! String)
                break
            case (WICLIENTINFO,true):
                wiredrecv.wiRecvUserInfo(array[i] as! String)
                break
            case (WIUSERLIST,_):  //310
                wiredrecv.recvUserlist(array[i] as! String,command: command)
                break;
            case (WIUSERLISTDONE,_):
                userlistflag=true
                wiredrecv.recvUserlist(array[i] as! String,command: command)
                break
            case (WIRECVNEWS,true): //320
                wiredrecv.wiRecvNews(array[i] as! String)
                break
            case (WIREDNEWSDONE,_):
                wiredrecv.wiNewsDone()
                break
            case (WIREDNEWSPOSTED,true):
                newsarray.removeAll()
                //wiredrecv.wiRecvNews(array[i] as! String)
                wlnews.wiredAutoNewsReload()
                break
            case (WIIMAGECHANGE,true):
                wiredrecv.wiClientImageChange(array[i] as! String)
                break;
            case (WIDIRLIST,true):
                wifilerecv.recvDirList(str: array[i] as! String)
                break
            case (WIDIRLISTDONE,true):
                wifilerecv.recvDirListDone()
                break
            case (WILOGINFAIL,_): //501
                wiredrecv.sendLoinFailNotof()
                break;
            case (WINOPRIV,_):
                
                break;
            default:
                #if DEBUG
                    print("default",array[i])
                    #endif
                break;
            }

            
        }
        
        
    }
    func countterm(_ str:String)->NSArray
    {
        let fterm:CharacterSet=CharacterSet(charactersIn:String(term))
        let array=str.components(separatedBy: fterm)
        return(array as NSArray)
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
