//
//  watchBookmarksControllerInterfaceController.swift
//  wiredline
//
//  Created by HiraoKazumasa on 2016/09/27.
//  Copyright © 2016 flidap. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class watchBookmarksInterfaceController: WKInterfaceController {
    @IBOutlet var bookmarktable: WKInterfaceTable!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
