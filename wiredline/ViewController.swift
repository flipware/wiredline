//
//  ViewController.swift
//  wiredline
//
//  Created by flidap on 10/12/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var versionlabel:UILabel=UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        var app=Bundle.main.infoDictionary
        #if DEBUG
            print(app?["CFBundleVersion"]! as Any)
        #endif
        versionlabel.text=app!["CFBundleVersion"] as? String
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

