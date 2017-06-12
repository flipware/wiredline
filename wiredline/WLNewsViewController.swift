//
//  WLNewsViewController.swift
//  wiredline
//
//  Created by HiraoKazumasa on 2/11/16.
//  Copyright © 2016 flidap. All rights reserved.
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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class WLNewsViewController: UIViewController,UITextViewDelegate {
    var wiredsend:WiredSend=WiredSend()
    var hlsend:HLSend=HLSend()
    @IBOutlet var newstext:UITextView?=UITextView()
    @IBOutlet var addbtn:UIBarButtonItem?=UIBarButtonItem()
    @IBOutlet var reloadbtn:UIBarButtonItem?=UIBarButtonItem()
    @IBOutlet var newsind:UIActivityIndicatorView?=UIActivityIndicatorView()
    @IBOutlet var newsaddview:UIView?=UIView()
    @IBOutlet var newsaddclose:UIButton?=UIButton()
    @IBOutlet var newspostbutton:UIButton?=UIButton()
    @IBOutlet var newsaddtext:UITextView?=UITextView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsaddtext?.delegate=self
        newsaddclose?.layer.cornerRadius = 10.0
        newspostbutton?.layer.cornerRadius = 10.0
        newsaddtext!.layer.cornerRadius=10.0
        //self.contentView.autoresizingMask = autoresizingMask;
        NotificationCenter.default.addObserver(self, selector: #selector(WLNewsViewController.showwirednews(_:)), name: NSNotification.Name(rawValue: getnewsdone), object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WLNewsViewController.showwirednews(_:)), name: NSNotification.Name(rawValue: hlnewsrecv), object:nil)
        
        if wiredflag==1 && inputHLStream != nil && newsstrarray.isEmpty{
            wiredsend.getNews()
            
        }else if hlflag==1 && inputHLStream != nil && newsarray.isEmpty{
            activaterstart()
            newsinfo="news"
            hlsend.getNews()
        }
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        #if DEBUG
            print("viewWIllAppler")
            #endif
        let nf=Notification(name: Notification.Name(rawValue: getnewsdone), object:self)
        NotificationCenter.default.post(nf)
        /*if(wiredflag==1 && inputHLStream != nil && newsarray.isEmpty){
            wiredsend.getNews()
            self.activaterstart()
        }else if hlflag==1 && inputHLStream != nil && newsarray.isEmpty{
            newsinfo="news"
            activaterstart()
            hlsend.getNews()
        }*/
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //newsstrarray.removeAll()
        //newstext?.text=nil
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(true)
        //newsstrarray.removeAll()
        //newsarray.removeAll()
        //newstext!.text=""
    }
    
    @IBAction func closeNewsAddView(_ sender:UIButton)
    {
        newsaddview?.isHidden=true
    }
    @IBAction func showaddview(_ sender:UIBarButtonItem)
    {
        #if DEBUG
            print("showaddview")
            #endif
        if(inputHLStream==nil){
            let alert:UIAlertController
            alert=UIAlertController(title: "WiredLine alert", message: "No ", preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction:UIAlertAction = UIAlertAction(title: "OK",style: UIAlertActionStyle.default,handler:nil)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }else{
            newsaddview?.isHidden=false
        }
    }
    func showhlnews(_ nf:Notification)
    {
        //var attr:NSAttributedString=NSAttributedString()
        for i in 0..<newsarray.count{
            //WLNews.ssWiredNewsImageCheck(newsarray[i] as String)
            self.newstext?.textStorage.addAttribute(NSAttributedStringKey.link, value: newsarray[i] as NSAttributedString, range: (self.newstext?.selectedRange)!)
            self.newstext?.textStorage.append(newsarray[i] as NSAttributedString)
        }
        self.activaterstop()
        
    }
    /*func showwirednews(nf:NSNotification)
    {
        #if DEBUG
        print("showwirednews:ok")
        #endif
        if wiredflag==1{
            #if DEBUG
                print("news wired")
                #endif
        var attr:NSAttributedString=NSAttributedString()
        for i in 0..<newsarray.count{
            //WLNews.ssWiredNewsImageCheck(newsarray[i] as String)
            let wlstr=WLString()
            let str=newsarray[i].string
            let tuple=wlstr.ssWiredNewsCheck(str)
            print("-----------------------------")
            print(str)
            print("-----------------------------")
            if tuple == true{
                var test=wlstr.ssWiredNewsImageCheck(newsstrarray[i])
                for var j in 0..<test.count{
                attr=test[j] as NSAttributedString
                self.newstext?.textStorage.addAttribute(NSLinkAttributeName, value: attr, range: (self.newstext?.selectedRange)!)
                self.newstext?.textStorage.appendAttributedString(attr)
                }
            }else{
                attr=newsarray[i] as NSAttributedString
                //self.newstext?.textStorage.addAttribute(NSLinkAttributeName, value: attr, range: (self.newstext?.selectedRange)!)
                //self.newstext?.textStorage.appendAttributedString(attr)
                print("true flag")
            }
            }
        }else if hlflag==1{
            #if DEBUG
                print("news hl")
                print(newsarray)
            #endif
            for i in 0..<newsarray.count{
                //WLNews.ssWiredNewsImageCheck(newsarray[i] as String)
                self.newstext?.textStorage.addAttribute(NSLinkAttributeName, value: newsarray[i] as NSAttributedString, range: (self.newstext?.selectedRange)!)
                self.newstext?.textStorage.appendAttributedString(newsarray[i] as NSAttributedString)
            }
            
        }
        self.activaterstop()
        
    }*/
    func reloadWiredNews()
    {
        self.wiredAutoNewsReload()
    }
    @objc func showwirednews(_ nf:Notification)
    {
        #if DEBUG
            print("showwirednews:ok")
        #endif
        var attr=[NSAttributedString]()
        var decodedimage=UIImage()
        if wiredflag==1{
            self.activaterstart()
            let wlstr:WLString=WLString()
            //var i=0
            for i in 0..<newsstrarray.count{
                attr=wlstr.ssWiredImageCheck(newsstrarray[i])
                //print("ssnews=",attr)
                for j in 0..<attr.count{
                    let attrs=attr[j] as NSAttributedString
                    var str=attrs.string
                    let endpoint=str.characters.count
                    str=str.substring(to: str.characters.index(str.startIndex, offsetBy: endpoint))
                    let imagedata=Data(base64Encoded: str, options:NSData.Base64DecodingOptions(rawValue: 0) )
                    if imagedata==nil{
                        self.newstext?.textStorage.addAttribute(NSAttributedStringKey.link, value: attrs, range: (self.newstext?.selectedRange)!)
                           self.newstext?.textStorage.append(attrs)
                    }else if imagedata?.count>0{
                        decodedimage=UIImage(data: imagedata!)!
                        let attachment = NSTextAttachment()
                        attachment.image = decodedimage
                        //put your NSTextAttachment into and attributedString
                        let attString = NSAttributedString(attachment: attachment)
                        self.newstext!.textStorage.append(attString)
                    }
                }
                
            }
            
        }else if hlflag==1{
            
            for i in 0..<newsarray.count{
                //WLNews.ssWiredNewsImageCheck(newsarray[i] as String)
                self.newstext?.textStorage.addAttribute(NSAttributedStringKey.link, value: newsarray[i] as NSAttributedString, range: (self.newstext?.selectedRange)!)
                self.newstext?.textStorage.append(newsarray[i] as NSAttributedString)
            }
        }
        NotificationCenter.default.removeObserver(getnewsdone)
        self.activaterstop()

    }
    
    func tapGesture(_ sender: UITapGestureRecognizer){
        for v in self.view.subviews {
            if(v is UITextField) {
                let txt = v as! UITextField
                if(txt.isFirstResponder) {
                    txt.resignFirstResponder()
                    return
                }
            }
        }
    }
    func addImageToNews(_ attr:NSAttributedString)
    {
        

    }
    @IBAction func tapScreen(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
