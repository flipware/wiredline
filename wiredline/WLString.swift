//
//  WLString.swift
//  wiredline
//
//  Created by HiraoKazumasa on 10/18/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class WLString: UIViewController {
    func addressport(_ str:String,proto:String)->[String]
    {
        #if WLString
            print("addressport:ok")
        #endif
        var sep:String
        var addr:[String]
        addr=Array()
        sep=String()
        sep=":"
        addr=str.components(separatedBy: sep)
        
        if addr.count==1{
            if(proto=="wired"){
            addr.append("2000")
        }else if(proto=="hotline"){
            addr.append("5500")
        }
    }
        return addr
        
    }
    func ssWiredStringCheck(_ str:String)->Bool
    {
        var flag=false
        var range:NSRange
        let data=str.data(using: String.Encoding.utf8)! as NSData
        
        let datatofind=String(ssWiredsp).data(using: String.Encoding.utf8)!
        range=data.range(of: datatofind, options: NSData.SearchOptions.backwards , in: NSMakeRange(0, data.length))
        if(range.location<data.length){
            flag=true
            #if DEBUG
            print("sswiredin")
            print(range.location)
            #endif
        }else{
            #if DEBUG
            print("sswired not in")
            #endif
            flag=false
        }
        return(flag)
    }
    func ssWiredImageCheck(_ str:String)->[NSAttributedString]
    {
        #if DEBUG
            print("sswiredImageCheck")
            #endif
        var array:[String]=Array()
        //var chstr:String=String()
        var attarray:[NSAttributedString]=Array()
        if var _=str.range(of: "<img src=\"data:image/png;base64,"){
            #if DEBUG
                print("sswired string")
                #endif
            var sstr=str.replacingOccurrences(of: "<img src=\"data:image/png;base64,", with: "||||||")
            sstr=sstr.replacingOccurrences(of: "\">", with: "||||||")
            array=sstr.components(separatedBy: "||||||")
            //for (var i=0;i<array.count;i++){
            for i in 0..<array.count{
                let attmess=NSAttributedString(string: array[i], attributes: [NSAttributedStringKey.foregroundColor:UIColor.black])
                attarray.insert(attmess, at: i)
            }
        }else if var _=str.range(of: "<img src="){
            #if DEBUG
                print("sswired string")
            #endif
            var sstr=str.replacingOccurrences(of: "<img src=", with: "||||||")
            sstr=sstr.replacingOccurrences(of: "\">", with: "||||||")
            array=sstr.components(separatedBy: "||||||")
            //for (var i=0;i<array.count;i++){
            for i in 0..<array.count{
                let attmess=NSAttributedString(string: array[i], attributes: [NSAttributedStringKey.foregroundColor:UIColor.black])
                attarray.insert(attmess, at: i)
            }
        }else{
            autoreleasepool(invoking: {
                let attmess=NSAttributedString(string: str, attributes: [NSAttributedStringKey.foregroundColor:UIColor.black])
            attarray.insert(attmess, at: 0)
        })
        
        }
        return(attarray)
    }
    func ssWiredNewsCheck(_ str:String)->Bool
    {
        var chkflag:Bool=true
        chkflag=self.ssWiredStringCheck(str)
        return(chkflag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
