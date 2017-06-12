//
//  watchUserlist.swift
//  wiredline
//
//  Created by flidap on 1/24/16.
//  Copyright © 2016 flidap. All rights reserved.
//

import WatchKit
import UIKit
import WatchConnectivity

class watchUserlist: WKInterfaceController,WCSessionDelegate{
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    
    
    @IBOutlet var userlisttable: WKInterfaceTable!
    var userlist=["test","test1"]
    var wiredcolor:[String] = []
    var session:WCSession!
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NotificationCenter.default.addObserver(self, selector: #selector(watchUserlist.watchuserlistreload(_:)), name: NSNotification.Name(rawValue: "WATCHUSERLISTRELOAD"), object: nil)
        if (WCSession.isSupported()) {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
        //icon[0]=UIImage(named: "News.png")!
        var applicationData = ["Userlist":"wirednick"]
        session.sendMessage(applicationData, replyHandler: {(_: [String : Any]) -> Void in
            }, errorHandler: {(error ) -> Void in
                // catch any errors here
        })
        applicationData = ["Userlist":"wiredcolor"]
        session.sendMessage(applicationData, replyHandler: {(_: [String : Any]) -> Void in
            }, errorHandler: {(error ) -> Void in
                // catch any errors here
        })
        //loadTableData()
    }
    @objc func watchuserlistreload(_ nf:Notification)
    {
        //print("watchuserlistreload:ok")
    }
    
    func loadTableData()
    {
        userlisttable.setNumberOfRows(userlist.count, withRowType: "watchUserlistController")
        for(index,username) in userlist.enumerated(){
            let row=userlisttable.rowController(at: index) as! watchUserlistController
                row.userlabel.setText(username)
            //row.iconimage.setImage(icon(index))
        }
        for(index,_) in userlist.enumerated(){
            let row=userlisttable.rowController(at: index) as! watchUserlistController
            if wiredcolor[index]=="red"{
            row.userlabel.setTextColor(UIColor.red)
            }else if wiredcolor[index]=="pink"{
                row.userlabel.setTextColor(UIColor(red: (255.0)/255.0, green: (192.0)/255.0, blue: (192.0)/255.0, alpha: 1.0))
            }else if wiredcolor[index]=="grey"{
                row.userlabel.setTextColor(UIColor.lightGray)
            }else if wiredcolor[index]=="black"{
                row.userlabel.setTextColor(UIColor.white)
            }
         }
    }
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        //#if DEBUG
        //print(message)
          //  #endif
        
        
        var keys:String=String()
        for (key, _) in message {
            keys=key
        if keys == "wirednick"{
            //print("wirednick")
            //let va=message["wirednick"]
            userlist.removeAll()
            //wiredcolor.removeAll()
            self.userlist=message["wirednick"] as! [String]
            
        }
        if keys=="wiredcolor"{
            //print("wiredcolor")
            //wiredcolor.removeAll()
            self.wiredcolor=message["wiredcolor"] as! [String]
            loadTableData()
        }
            if keys=="watch"{
                var applicationData = ["Userlist":"wirednick"]
                session.sendMessage(applicationData, replyHandler: {(_: [String : Any]) -> Void in
                    }, errorHandler: {(error ) -> Void in
                        // catch any errors here
                })
                applicationData = ["Userlist":"wiredcolor"]
                session.sendMessage(applicationData, replyHandler: {(_: [String : Any]) -> Void in
                    }, errorHandler: {(error ) -> Void in
                        // catch any errors here
                })
                
            }
            
        }
    }
    
}
