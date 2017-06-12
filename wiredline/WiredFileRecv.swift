//
//  WiredFileRecv.swift
//  wiredline
//
//  Created by HiraoKazumasa on 2016/10/09.
//  Copyright © 2016 flidap. All rights reserved.
//

import UIKit
var filearray:[String]=Array()
var typearray:[String]=Array()

let recvDirNotif="RECVDIRLIST"

class WiredFileRecv: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func recvDirList(str:String)
    {
        let string=(str as NSString).substring(from: 4)    //通常はform:4
        var array:[String]=Array()
        var pathstr=String()
        #if DEBUG
        print("recvDirList:ok")
            print(string)
        #endif
        let ffs:CharacterSet=CharacterSet(charactersIn:String(fs))
        let cnt=filearray.count
        array=string.components(separatedBy: ffs)
        filearray.insert(array[0],at: cnt)
        typearray.insert(array[1], at: cnt)
        #if DEBUG
        print(filearray)
        print(typearray)
        #endif
        pathstr=filearray[cnt]
        let pathen=pathstr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let pathurl=NSURL(string:pathen!)
        
        filearray[cnt]=(pathurl?.lastPathComponent!)!
        
    }
    func recvDirListDone()
    {
        let notif=Notification(name: Notification.Name(rawValue: recvDirNotif))
        NotificationCenter.default.post(notif)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
