//
//  HLString.swift
//  wiredline
//
//  Created by HiraoKazumasa on 11/10/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import UIKit

class HLString: UIViewController {
    func HLStringEncript(_ flatstr:String)->Data
    {
        let encripteddata:Data=Data()
        var _:Character
        _=256
        for _ in flatstr.unicodeScalars{
            
        }
        
        
        return(encripteddata)
    }
    func iconbyteorder(_ iconno:UInt32)->Data
    {
        var iconrow:UInt32
        var data:Data
        iconrow=CFSwapInt32HostToBig(iconno)
        data=NSData() as Data
        data=NSData(bytes: &iconrow, length: 4) as Data
        
        
        //println(data)
        return(data)
    }
    func clientbyteorder(_ iconno:UInt32)->Data
    {
        var iconrow:UInt32
        var data:Data
        iconrow=CFSwapInt32HostToBig(iconno)
        data=Data()
        data=NSData(bytes: &iconrow, length: 4) as Data
        //println(data)
        return(data)
    }
    
    func uidbyteorder(_ iconno:UInt16)->Data
    {
        var iconrow:UInt16
        var data:Data
        iconrow=CFSwapInt16HostToBig(iconno)
        data=Data()
        data=NSData(bytes:&iconrow, length: 2) as Data
        //println(data)
        return(data)
    }
    
    

}
