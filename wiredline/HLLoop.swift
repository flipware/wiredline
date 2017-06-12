//
//  HLLoop.swift
//  wiredline
//
//  Created by flidap on 11/6/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import UIKit

var encoding:String.Encoding=String.Encoding.utf8
class HLLoop: UIViewController {
    let hlsend:HLSend=HLSend()
    let hlrecv:HLRecv=HLRecv()
    let hlcm:HLCMethod=HLCMethod()
    let objc:objcmethod=objcmethod()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var bigflag:Bool=false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func hlloopinit(_ data:Data)
    {
        #if HLRECVDEBUG
            print("hloopinit:ok")
        #endif
        var str=NSString(data: data, encoding: String.Encoding.ascii.rawValue)!
        str=str.substring(to: 4) as NSString
        //print(str)
        if(str=="TRTP"){
            //print("TRTP RECV")
            hlsend.HLLoginSequence()
            hlrecv.recvHLPing()
        }
        
    }
    func hlloop(_ data:Data)
    {
        #if HLRECVDEBUG
            print("hloop:ok")
        #endif
        var results:(hlhdrtype:NSMutableArray,hldataarray:NSMutableArray)
        //var i:Int=0
        var type:UInt32
        //var notif:NSNotification
        var tempdata:Data=Data()
        hlloopdata.append(data)
        //print(hlloopdata)
        tempdata=NSData(data: hlloopdata as Data) as Data
        //tempdata=hlloopdata
        self.packetLength(tempdata)
        
        if(bigflag==false){
            results=self.HLdataSepareter(hlloopdata as Data)
            hlloopdata=NSMutableData()
            bigflag=false
            //for(i=0;i<results.hlhdrtype.count;i++){
            let hdrcount=results.hlhdrtype.count
            for i in 0..<hdrcount{
                type=UInt32(results.hlhdrtype[i] as! String)!
                switch(type){
                case HL_HDR_SERVERINFO:
                    #if DEBUG
                        print("HL_HDR_SERVERINFO")
                        #endif
                    hlrecv.serverReply(results.hldataarray[i] as! Data)
                    break
                case HL_HDR_RECVCHAT:
                    #if DEBUG
                        print("HL_HDR_RECVCHAT")
                        #endif
                    hlrecv.HLChatRecv(results.hldataarray[i] as! Data)
                    break
                case HL_HDR_USERCHANGE:
                    #if DEBUG
                        print("HL_HDR_USERCHANGE")
                        print(results.hldataarray[i] )
                        print("serverAck=\(serverAck)")
                        #endif
                    
                    if serverAck==true{
                        hlrecv.userchange(results.hldataarray[i] as! Data as NSData)
                    }
                    serverAck=true
                    break
                case HL_HDR_USERLEFT:
                    #if DEBUG
                        print("HL_HDR_USERLEFT")
                        #endif
                    hlrecv.userleftloop(results.hldataarray[i] as! Data as NSData)
                    break
                case HL_HDR_RECVAGREEMENT:
                    #if DEBUG
                        print("HL_HDR_RECVAGREEMENT")
                    #endif
                    hlsend.sendOver151()
                    break
                case HL_HDR_RECVSERVERMSG:
                    #if DEBUG
                        print("HL_HDR_RECVSERVERMSG")
                    #endif
                    hlrecv.HLPrivateMSGRecv(results.hldataarray[i] as! Data as NSData)
                    break
                case HL_HDR_USER_ACCESS:
                    #if DEBUG
                        print("HL_HDR_USER_ACCESS")
                    #endif
                    let hlsend=HLSend()
                    hlrecv.clearUserlist()
                    if hlversion=="123" {
                        hlsend.sendOldLogin()
                    }else{
                        hlsend.sendOldLogin()
                    }
                    userlistreq=true
                    //hlsend.HLGetUerlist()
                    //serverAck=true
                    //hlrecv.setServerInfo(ddata)
                    //hlrecv.serverReply(results.hldataarray[i] as! Data)
                    break
                case HL_HDR_RECVSERVERNAME:
                    #if DEBUG
                        print("HL_HDR_RECVSERVERNAME")
                        #endif
                    break
                default:
                    #if DEBUG
                        print("HL_UNKNOWN HEADER")
                        print("type=\(type)")
                        #endif
                    break
                }
            }

        }
    }
    
    func packetLength(_ data:Data)
    {
        #if DEBUG
            print("packetLength:ok")
            #endif
        var len:Int=0
        var hdr:HL_HDR=HL_HDR()
        var newdata:Data
        len=data.count
        newdata=data
        repeat{
            (newdata as NSData).getBytes(&hdr,length:SIZEOF_HL_HDR )
        /*#if DEBUG
            print("packetLength")
            print("type=\(Int(CFSwapInt32HostToBig(hdr.type)))")
            print("flag=\(Int(CFSwapInt32HostToBig(hdr.flag)))")
            print("len=\(Int(CFSwapInt32HostToBig(hdr.len)))")
            print("len2=\(Int(CFSwapInt32HostToBig(hdr.len2)))")
            print("hc=\(Int(CFSwapInt16HostToBig(hdr.hc)))")
            print("len=",len)
            //print(newdata)
            print("packetLength")
        #endif*/
        len-=(Int(CFSwapInt32HostToBig(hdr.len2))+SIZEOF_HL_HDR-2)
            //newdata=hlcm.pointerIncrement(newdata, length: SIZEOF_HL_HDR+Int(CFSwapInt32HostToBig(hdr.len))-2)
        if(len>0){
            newdata=hlcm.pointerIncrement(newdata, length: SIZEOF_HL_HDR+Int(CFSwapInt32HostToBig(hdr.len))-2)
            bigflag=false
        }else{
            
        if(len<0){
            len=0
            //print("big packet")
            bigflag=true
            }
            }
            
        }while(len > 0)
        }
    
    func HLdataSepareter(_ data:Data)->(NSMutableArray,NSMutableArray)
    {
        var results:(hlhdrtype:NSMutableArray,hldataarray:NSMutableArray)
        //var len:Int
        var datalength:Int
        //var type:UInt32
        var newdata:Data=Data()
        var hldata:NSMutableData=NSMutableData()
        var hdr:HL_HDR=HL_HDR()
        let objcm:HLCMethod=HLCMethod()
        //total=0
        datalength=0
        #if DEBUG
            print("datasep:ok")
            print(data)
        #endif
        //total=data.length
        //newdata=data
        newdata=NSData(data:data) as Data
        results.hlhdrtype=NSMutableArray()
        results.hldataarray=NSMutableArray()
        //for(i=0;i<data.length;){
        var lengthdata=0
        (newdata as NSData).getBytes(&hdr, length: SIZEOF_HL_HDR)
        lengthdata=Int(CFSwapInt32HostToBig(hdr.len))
        for var i in 0..<lengthdata{
            hldata=NSMutableData()
            (newdata as NSData).getBytes(&hdr, length: SIZEOF_HL_HDR)
            
            if(Int(CFSwapInt32HostToBig(UInt32(hdr.type)))>0 && Int(CFSwapInt32HostToBig(UInt32(hdr.type)))<65537 && Int(CFSwapInt32HostToBig(hdr.len)) < 65536){
                #if DEBUG
                    print("type=\(Int(CFSwapInt32HostToBig(UInt32(hdr.type))))")
                    print("flag=\(Int(CFSwapInt32HostToBig(hdr.flag)))")
                    print("len=\(Int(CFSwapInt32HostToBig(hdr.len)))")
                    print("len2=\(Int(CFSwapInt32HostToBig(hdr.len2)))")
                    print("hc=\(Int(CFSwapInt16HostToBig(hdr.hc)))")
                #endif
                results.hlhdrtype.add(String(CFSwapInt32HostToBig(UInt32(hdr.type))))
                datalength=SIZEOF_HL_HDR+Int(CFSwapInt32HostToBig(hdr.len))
                hldata.append((newdata as NSData).bytes, length:SIZEOF_HL_HDR+Int(CFSwapInt32HostToBig(hdr.len)))
            }
            //hldata.subdataWithRange(NSMakeRange(0, datalength))
            #if DEBUG
                //print("hldata=\(hldata)")
            #endif
            results.hldataarray.add(hldata)
            if(Int(CFSwapInt32HostToBig(hdr.len))<65537 && Int(CFSwapInt32HostToBig(hdr.len))>0){
                newdata=objcm.pointerIncrement(newdata, length: datalength-2)
                
            }else {
                i+=datalength
                break
            }
        }
        #if DEBUG
            print("-----------------")
            print("result=",results.hldataarray)
        #endif
        return results
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
