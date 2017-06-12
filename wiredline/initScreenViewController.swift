//
//  initScreenViewController.swift
//  wiredline
//
//  Created by HiraoKazumasa on 2/19/16.
//  Copyright © 2016 flidap. All rights reserved.
//

import UIKit

class initScreenViewController: UIViewController {
    @IBOutlet private weak var hlimage:UIImageView!=UIImageView()
    @IBOutlet private weak var wiredimage:UIImageView!=UIImageView()
    @IBOutlet private weak var versionlabel:UILabel!=UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        var app=Bundle.main.infoDictionary
        #if DEBUG
        print(app?["CFBundleVersion"] as Any)
        #endif
        versionlabel!.text=app!["CFBundleVersion"] as? String
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        sleep(1)
        weak var storyboard = UIStoryboard(name: "Main", bundle: nil)
        weak var targetView=storyboard?.instantiateViewController( withIdentifier: "target" )
        self.present( targetView! , animated: false, completion: nil)
        
        //self.dismiss(animated: true, completion: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
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
