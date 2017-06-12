//
//  HLIconList.swift
//  wiredline
//
//  Created by HiraoKazumasa on 12/22/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import UIKit

class HLIconList: UITableViewController {
    @IBOutlet var icontable:UITableView!
    var iconlistarray:NSArray=NSArray()
    
    var path=NSString(string: (Bundle.main.path(forResource: "hotwireAdditional", ofType: "bundle"))!).appendingPathComponent("Icons")

    override func viewDidLoad() {
        super.viewDidLoad()
        let manager=FileManager.default
        let nib=UINib(nibName: "iconlist", bundle: nil)
        icontable.register(nib, forCellReuseIdentifier: "icon")
        do{
            iconlistarray = try manager.contentsOfDirectory(atPath: path) as NSArray
        }catch _ as NSError{
            
        }
        
    }
    @IBAction func backToSettings(){
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return iconlistarray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var path=NSString(string: (Bundle.main.path(forResource: "hotwireAdditional", ofType: "bundle"))!).appendingPathComponent("Icons")
        let cell = icontable.dequeueReusableCell(withIdentifier: "icon") as? iconlist
        path=Bundle.path(forResource: iconlistarray[Int((indexPath as NSIndexPath).row)] as? String, ofType: nil, inDirectory: path)!
        cell?.iconimage.image=UIImage(contentsOfFile:path)

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var path=NSString(string: (Bundle.main.path(forResource: "hotwireAdditional", ofType: "bundle"))!).appendingPathComponent("Icons")
        path=Bundle.path(forResource: iconlistarray[Int((indexPath as NSIndexPath).row)] as? String, ofType: nil, inDirectory: path)!
        //print(contents[indexPath.row])
        var str:String
        str=NSString(string: path).lastPathComponent as String
        //str=
        //print(str)
        var array:NSArray=NSArray()
        let sep:String="."
        array=str.components(separatedBy: sep) as NSArray
        //print(array)
        let df=UserDefaults.standard
        df.removeObject(forKey: "iconno")
        df.set(array[0], forKey: "iconno")

    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
