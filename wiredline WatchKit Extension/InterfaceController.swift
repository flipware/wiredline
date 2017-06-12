//
//  InterfaceController.swift
//  wiredline WatchKit Extension
//
//  Created by flidap on 10/12/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController,WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    @IBOutlet var disbutton:WKInterfaceButton?
    @IBOutlet var serverlabel:WKInterfaceLabel?
    var session:WCSession!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    @IBAction func pushDisConnect(_ sender:AnyObject)
    {
        #if DEBUG
        print("PushDisConnect:ok")
        #endif
        
        let applicationData = ["Disconnect":"Disconnect"]
        session.sendMessage(applicationData, replyHandler: {(_: [String : Any]) -> Void in
            // handle reply from iPhone app here
            }, errorHandler: {(error ) -> Void in
                // catch any errors here
        })
       
    }
    

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if (WCSession.isSupported()) {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
        let applicationData = ["Serverinfo":"Serverinfo"]
        session.sendMessage(applicationData, replyHandler: {(_: [String : Any]) -> Void in
            // handle reply from iPhone app here
            }, errorHandler: {(error ) -> Void in
                // catch any errors here
        })
        
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        for (key, _) in message {
            if (key=="servername"){
                serverlabel?.setText(message["servername"] as? String)
        }
        }
        
    }

}
