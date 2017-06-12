//
//  WLNewsViewController+cmd.swift
//  wiredline
//
//  Created by HiraoKazumasa on 2/12/16.
//  Copyright © 2016 flidap. All rights reserved.
//

import Foundation

extension WLNewsViewController
{
    func activaterstart()
    {
        newsind!.isHidden=false
        newsind?.startAnimating()
    }
    func activaterstop()
    {
        newsind?.stopAnimating()
        newsind!.isHidden=true
    }
    @IBAction func postWLNews(_ sender:UIButton)
    {
        #if DEBUG
        print("postWLNews:ok")
        print("wiredflag=",wiredflag)
        print("hlflag=",hlflag)
        #endif
        var len=Int()
        let target=CharacterSet.whitespaces
        len=newsaddtext!.text.lengthOfBytes(using: String.Encoding.utf8)
        if(len == 0 || newsaddtext!.text!.trimmingCharacters(in: target).lengthOfBytes(using: String.Encoding.utf8) == 0){
            let alert:UIAlertController
            alert=UIAlertController(title: "WiredLine alert", message: "Not Connected ", preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction:UIAlertAction = UIAlertAction(title: "OK",style: UIAlertActionStyle.default,handler:nil)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }else if(len != 0 && newsaddtext!.text!.trimmingCharacters(in: target).lengthOfBytes(using: String.Encoding.utf8) != 0 && wiredflag==1){
            #if DEBUG
            print("wirednewspost:ok")
            #endif
            wiredsend.postWiredNews((newsaddtext?.text)!)
            self.newsaddview?.isHidden=true
        }else if(len != 0 && newsaddtext!.text.trimmingCharacters(in: target).lengthOfBytes(using: encoding) != 0 && hlflag==1){
            #if DEBUG
                print("HLPostNews:ok")
                #endif
            hlsend.postNews((newsaddtext?.text)!)
            self.newsaddview?.isHidden=true
        }
        newsaddtext!.text=""
    }
    func wiredAutoNewsReload()
    {
        newsarray.removeAll()
        newsstrarray.removeAll()
        self.activaterstart()
        
        newstext?.text=nil
        wiredsend.getNews()
    }
    @IBAction func reloadWLNews(_ sender:UIBarButtonItem)
    {
        
        if(wiredflag==1 ){
            newsarray.removeAll()
            newsstrarray.removeAll()
            self.activaterstart()
            newstext?.text=""
            wiredsend.getNews()
        }else if(hlflag==1){
            newsarray.removeAll()
            newsstrarray.removeAll()
            newsinfo="news"
            self.newsaddtext!.text=""
            self.activaterstart()
            newstext?.text=""
            hlsend.getNews()
        }
    }
    
    
}
