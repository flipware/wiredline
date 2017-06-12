//
//  wiredIconCollection.swift
//  wiredline
//
//  Created by flidap on 2016/12/27.
//  Copyright © 2016 flidap. All rights reserved.
//

import UIKit

private let reuseIdentifier = "wiredicons"

class wiredIconCollection: UIViewController ,UICollectionViewDataSource, UICollectionViewDelegate {
    var list=Array<String>()
    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
        print("wiredicon")
        #endif
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        //let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        //let directoryName = "icons"  // 作成するディレクトリ名
        //let createPath = documentsPath + "/" + directoryName
        var icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.flipware.wiredline")
        icloudURL=icloudURL?.appendingPathComponent("Documents/icons")
        let manager = FileManager.default
        var cnt:Int
        var list1=Array<String>()
        do{
            //try list1 = manager.contentsOfDirectory(atPath: createPath)
            try list1 = manager.contentsOfDirectory(atPath: (icloudURL?.path)!)
        }catch{
            
        }
        cnt=list1.count
        for i in 0..<cnt{
            //print(documentsPath + "/" + directoryName+"/"+list1[i])
            //list[i]=String(documentsPath + "/" + directoryName+"/"+list1[i])
            //list.insert(documentsPath + "/" + directoryName+"/"+list1[i], at:i)
            if list1[i] != ".DS_Store"{
            list.insert((icloudURL?.path)! + "/"+list1[i], at:i)
            }
            }
        cnt=list.count
        
        
        return cnt
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let imageview=cell.contentView.viewWithTag(1) as! UIImageView
        let cellimage=UIImage(named: list[(indexPath as NSIndexPath).row])
        //print(list[(indexPath as NSIndexPath).row])
        imageview.image=cellimage
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    // Uncomment this method to specify if the specified item should be selected
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        //print("icon select")
        let str=list[(indexPath as NSIndexPath).row]
        let data:NSData = UIImagePNGRepresentation(UIImage(named:str)!)! as NSData
        //NSDataへの変換が成功していたら
        //print(data)
        let encodeString:String =
            data.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
        //print(encodeString)
        let ud=UserDefaults.standard
        var results:String!=ud.object(forKey: "wiredicon") as! String!
        if results==nil{
            results=WIDEFAULTICON
        }
        ud.removeObject(forKey: "wiredicon")
        ud.set(encodeString , forKey: "wiredicon")
        ud.synchronize()
        let wisend=WiredSend()
        wisend.sendIconCommand(encodeString)
        return true
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
