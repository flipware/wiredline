//
//  HLRecv.swift
//  wiredline
//
//  Created by flidap on 10/20/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import Foundation
//HDR
let HL_HDR_SERVERINFO:UInt32=65536 //0x00010000
let HL_HDR_RECVSERVERMSG:UInt32=104 //0x00000068
let HL_HDR_RECVCHAT:UInt32=106//0x0000006A
let HL_HDR_RECVAGREEMENT:UInt32=109
let HL_HDR_USER_JOIN_CHAT:UInt32=115  //73
let HL_HDR_USERCHANGE:UInt32=301 //0x0000012D
let HL_HDR_USERLEFT:UInt32=302  //0x0000012E
let HL_HDR_USER_ACCESS:UInt32=354
let HL_HDR_RECVSERVERNAME:UInt32=162

//Data
let HL_DATA_ERROR:UInt16=100  //0x0064
let HL_DATA_NEWS:UInt16=101   //0x0065
let HL_DATA_RECV_NICK:UInt16=102    //0x0066
let HL_DATA_OLDPOSTNEWS:UInt16=103 //0x0067
let HL_DATA_SERVERMSG:UInt16=104   //0x0068
let HL_DATA_DISCONNECT_USER:UInt16=110 //0x6e
let HL_DATA_USER_INVITE_CHAT:UInt16=112
let HL_DATA_USER_JOIN_CHAT:UInt16=115 //0x0073

let HL_DATA_SERVERVERSION:UInt16=160
let HL_DATA_BANNER:UInt16=161
let HL_DATA_SERVERNAME:UInt16=162
let HL_DATA_RECVDIRLIST:UInt16=200
let HL_DATA_USERINFO:UInt16=300



let settittle="SetTittleNav"
let sethluserinfo="SetHLUserInfo"
let hlnewsrecv="HLNEWSRECV"
var existuidflag=false
var idrow:Int=0
var serverAck=false
var joinchat=false
var hlversion="123"
var userlistreq=false
struct HL_USER_DATA{
    var uid:UInt16
    var icon:UInt16
    var color:UInt16
    var namelen:UInt16
    init(){
        uid=0
        icon=0
        color=0
        namelen=0
    }
}
struct HL_UID{
    var uid:UInt16
    init(){
        uid=0
    }
}
struct HL_File_Data{
    var type:UInt32
    var creater:UInt32
    var size:UInt32
    var resv:UInt32
    var namescript:UInt16
    var namesize:UInt16
    init(){
        type=0
        creater=0
        size=0
        resv=0
        namescript=0
        namesize=0
    }
}
struct HL_My_Info{
    var getMyID:Bool
    var myID:String
}

var hlnamescriptarray:[String]=Array()
var hluidarray:NSMutableArray=NSMutableArray()
var hliconarray:NSMutableArray=NSMutableArray()
var hlcolorarray:NSMutableArray=NSMutableArray()
var hlnicknamearray:NSMutableArray=NSMutableArray()
var newsinfo=""
let hlsend=HLSend()
//MARK:SERVERREPLY
class HLRecv: NSObject {
    let hlcm:HLCMethod=HLCMethod()
    let objcm:objcmethod=objcmethod()
    
    
    func clearUserlist()
    {
        hluidarray.removeAllObjects()
        hliconarray.removeAllObjects()
        hlcolorarray.removeAllObjects()
        hlnicknamearray.removeAllObjects()
    }
    func serverReply(_ reply:Data)
    {
        #if DEBUG
        print("serverReply")
        #endif
        var count:Int
        var hdr:HL_HDR=HL_HDR()
        var dhdr:HL_DATA=HL_DATA()
        //var uhdr:HL_USER_DATA
        var ddata:Data=Data()
        var type:UInt16
        (reply as NSData).getBytes(&hdr, length: SIZEOF_HL_HDR)
        var tempdata=hlcm.pointerIncrement(reply, length: SIZEOF_HL_HDR) as NSData
        count=Int(CFSwapInt16HostToBig(hdr.hc))
        if(count==0){
            if hlversion=="191" || hlversion=="185"{
            #if DEBUG
                print("HLPing")
                #endif
                recvHLPing()
            }else{
                hlsend.getUserList()
            }
            if serverAck != true{
                //serverAck=true
            }
            //recvHLPing()
            //serverAck=true
            
        }
        //for(i=0;i<count;i++){
        for _ in 0..<count {
            //tempdata.copyBytes(to: &dhdr, count: SIZEOF_DATA_HDR)
            tempdata.getBytes(&dhdr, length: SIZEOF_DATA_HDR)
            type=UInt16(Int(CFSwapInt16HostToBig(dhdr.type)))
            //totaltype=Int(CFSwapInt16BigToHost(dhdr.type))
            #if DEBUG
            print("type=\(Int(CFSwapInt16HostToBig(dhdr.type)))")
            print("len=\(Int(CFSwapInt16HostToBig(dhdr.len)))")
                #endif
            tempdata=hlcm.pointerIncrement(tempdata as Data!, length: SIZEOF_DATA_HDR) as NSData
            ddata=Data(bytes:tempdata.bytes , count: Int(CFSwapInt16HostToBig(dhdr.len)))
            //ddata=tempdata.bytes.bindMemory(to: UInt8.self, capacity: Int(CFSwapInt16HostToBig(dhdr.len)))
            //ddata=UnSafeRawPointer(tempdata.bytes.assumingMemoryBound(to: UInt8.self))
            //ddata=UnsafeRawPointer(tempdata.bytes.assumingMemoryBound(to: UInt8.self))
            tempdata=hlcm.pointerIncrement(tempdata as Data!, length:Int(CFSwapInt16HostToBig(dhdr.len))) as NSData
            #if DEBUG
            
            print("newsinfo=",newsinfo)
            #endif
        
            switch(type){
            case HL_DATA_ERROR:
                #if DEBUG
                    print("HL_DATA_ERROR")
                    #endif
                break
            case HL_DATA_SERVERVERSION:
                #if DEBUG
                    print("HL_DATA_SERVERVERSION")
                    #endif
                setServerVerison(ddata)
                //hlsend.HLVersionLogin(ddata)
                break
            case HL_DATA_OLDPOSTNEWS:
                #if DEBUG
                    print("HL_DATA_OLDPOSTNEWS")
                    #endif
                //recvOldPostNews()
                //hlsend.HLVersionLogin(ddata)
                //userJoinChat()
                break
            case HL_DATA_NEWS:
                #if DEBUG
                    print("HL_DATA_NEWS")
                    #endif
                self.recvNews(ddata)
                break
            case HL_DATA_BANNER:
                #if DEBUG
                    print("HL_DATA_BANNER")
                #endif
                break
            case HL_DATA_SERVERNAME:
                #if DEBUG
                    print("HL_DATA_SERVERNAME")
                    #endif
                self.setServerInfo(ddata)
                break
            case HL_DATA_USERINFO:
                #if DEBUG
                    print("HL_DATA_USERINFO")
                    #endif
                    //setServerVerison(ddata)
                    setUserList(ddata as NSData)
                break
            case HL_DATA_RECVDIRLIST:
                #if DEBUG
                    print("HL_DATA_RECVDIRLIST")
                #endif
                setFileList(ddata)
                break
            case HL_DATA_DISCONNECT_USER:
                #if DEBUG
                    print("HL_DATA_DISCONNECT_USER")
                    #endif
                //hlsend.sendOldLogin()
                break
            case HL_DATA_USER_JOIN_CHAT:
                #if DEBUG
                    print("HL_DATA_USER_JOIN_CHAT")
                #endif
                self.userJoinChat()
                //self.setServerInfo(ddata)
                //hlsend.sendOldLogin()
                break
            default:
                #if DEBUG
                    print("ServevrReply UNKNOWN")
                    print("type=\(Int(CFSwapInt16HostToBig(dhdr.type)))")
                    print("len=\(Int(CFSwapInt16HostToBig(dhdr.len)))")
                #endif
                break
            }
        }
    }
    func setFileList(_ ddata:Data)
    {
        #if DEBUG
            print("setFileList:ok")
            print("data=",ddata as NSData)
        #endif
        var data=Data()
        var fhdr=HL_File_Data()
        //(reply as NSData).getBytes(&hdr, length: SIZEOF_HL_HDR)
        (ddata as NSData).getBytes(&fhdr, length: SIZEOF_FILE_DATA)
        let str = NSString(bytes: &fhdr.type, length: 4, encoding: encoding.rawValue)
        typearray.append(str! as String)
        data=hlcm.pointerIncrement(ddata, length: SIZEOF_FILE_DATA)
        //print("data=",data as NSData)
        #if DEBUG
            print(typearray)
            print(data as NSData)
            print("fhdr.creater=",CFSwapInt32BigToHost(fhdr.creater))
            print("fhdr.namesize=",CFSwapInt16BigToHost(fhdr.namesize))
            print("fhdr.namescript=",CFSwapInt16BigToHost(fhdr.namescript))
        #endif
        //data=objcm.cleanUTF8(data)
        //var script=NSString(bytes: &fhdr.namescript, length: 2, encoding: encoding.rawValue) as! String
        //print("script=",script)
        var filename=NSString(data: data, encoding: encoding.rawValue) as String?
        if filename==nil{
            filename=NSString(data: data, encoding: String.Encoding.shiftJIS.rawValue) as String?
            filename=nil
        }
        if filename != nil{
            filearray.append(filename!)
        }
        let notif=Notification(name: Notification.Name(rawValue: recvDirNotif))
        NotificationCenter.default.post(notif)
        //print(filearray)
    }
    
    func setServerInfo(_ ddata:Data)
    {
        var str:NSString=NSString()
        str=NSString(data: ddata, encoding: String.Encoding.utf8.rawValue)!
        #if DEBUG
        print("ddata=",ddata)
        print("setServerinfo=",str)
            #endif
        serverinfoarray.insert("HL", at: 0)
        serverinfoarray.insert(String(addressinfo), at: 1)
        serverinfoarray.insert(str as String, at: 2)
        #if DEBUG
            print(serverinfoarray)
            #endif
        let nf=Notification(name: Notification.Name(rawValue: callchatwindow), object: self)
        NotificationCenter.default.post(nf)
        
    }
    
    // MARK:保留
    func setServerVerison(_ ddata:Data)
    {
        #if DEBUG
            print("setserverversion")
            print(ddata as NSData)
            #endif
        //let nf=Notification(name: Notification.Name(rawValue: callchatwindow), object: self)
        //NotificationCenter.default.post(nf)
        hlversion="191"
        //hlversion=String(data: ddata, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!as String
        //print("hlversion=\(hlversion)")
        if hlversion == "191" || hlversion == "185" {
            hlsend.sendOver151()
        }else {
            hlsend.sendOldLogin()
        }
        loginflag=true
        //joinchat = true
        
        //保留
        
    }
    func recvOldPostNews()
    {
        let nf=Notification(name: Notification.Name(rawValue: callchatwindow), object: self)
        //print("addressInfo",addressinfo)
        NotificationCenter.default.post(nf)
    }
    func setUserList(_ ddata:NSData)
    {
        var udata:HL_USER_DATA=HL_USER_DATA()
        let count=hluidarray.count
        ddata.getBytes(&udata, length: MemoryLayout<HL_USER_DATA>.size)
        let  dddata=hlcm.pointerIncrement(ddata as Data!, length: MemoryLayout<HL_USER_DATA>.size)
        idrow=hluidarray.index(of: String(CFSwapInt16HostToBig(udata.uid)))
        //if joinchat==true{
        //print("idrow=\(idrow)")
        //print("idrow=\(CFSwapInt16HostToBig(udata.uid))")
        if idrow > 999{
            //print("idrow mini")
        hluidarray[count]=String(CFSwapInt16HostToBig(udata.uid))
        hliconarray[count]=String(CFSwapInt16HostToBig(udata.icon))
        hlcolorarray[count]=String(CFSwapInt16HostToBig(udata.color))
        /*if encoding==String.Encoding.utf8{
            data=objcm.cleanUTF8(dddata)
        }else{
            data=dddata!
            #if DEBUG
            print("not utf")
            #endif
            data=hlcm.cleanSJIS(dddata)
        }*/
        var nicknamestr=String(data: dddata!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        if nicknamestr==nil{
            nicknamestr=String(data: dddata!, encoding: String.Encoding(rawValue: String.Encoding.shiftJIS.rawValue))
        }
        hlnicknamearray[count]=NSString(string: nicknamestr!)
        let nf=Notification(name: Notification.Name(rawValue: listreload), object:self)
        NotificationCenter.default.post(nf)
        let nof:Notification=Notification(name: Notification.Name(rawValue: loginsuccess), object: self)
        NotificationCenter.default.post(nof)
        }
    //}
    }
    
    func recvNews(_ ddata:Data)
    {
        
        #if DEBUG
            print("recvNews:ok")
            #endif
        var attr=NSAttributedString()
        var nf=Notification(name: Notification.Name(rawValue: settittle), object:self)
        //var newsstring=NSString(data: objcm.cleanUTF8(ddata) , encoding: encoding.rawValue)
        var newsstring=NSString(data:objcm.cleanUTF8(ddata),encoding:encoding.rawValue)
        if(newsstring==nil){
            newsstring=NSString(data: ddata, encoding: String.Encoding.shiftJIS.rawValue)
        }
        if(serverinfoarray.count==0){
            nf=Notification(name: Notification.Name(rawValue: settittle), object:self, userInfo:["servername":addressinfo])
        }else{
            nf=Notification(name: Notification.Name(rawValue: settittle), object:self, userInfo:["servername":serverinfoarray[2]])
        }
        if(newsinfo=="userinfo"){
            NotificationCenter.default.post(nf)
            nf=Notification(name: Notification.Name(rawValue: sethluserinfo), object: self,userInfo: ["userinfo":newsstring!])
            NotificationCenter.default.post(nf)
        }
        if(newsinfo=="news"){
            nf=Notification(name: Notification.Name(rawValue: hlnewsrecv), object: self,userInfo: nil)
            attr=NSAttributedString(string: (newsstring)! as String)
            newsarray.insert(attr, at: 0)
            NotificationCenter.default.post(nf)
        }
        
    }
    //MARK:CHAT
    func HLChatRecv(_ ddata:Data)
    {
        var atts:NSMutableAttributedString=NSMutableAttributedString()
        var atline:NSAttributedString=NSAttributedString()
        let line:NSString="\n"
        var Buffer = [UInt8](repeating: 0, count: ddata.count)
        ddata.copyBytes(to: &Buffer, count: ddata.count)
        var ptr:UnsafePointer<UInt8>=UnsafePointer<UInt8>(Buffer)!
        var dhdr=HL_DATA()
        var chatdata=NSMutableData()
        ptr=ptr.advanced(by: Int(SIZEOF_HL_HDR))
        memcpy(&dhdr, ptr, SIZEOF_DATA_HDR)
        ptr=ptr.advanced(by: Int(SIZEOF_DATA_HDR)+1)
        #if DEBUG
            print("hdr=\(Int(CFSwapInt16HostToBig(dhdr.type)))")
            print("len=\(Int(CFSwapInt16HostToBig(dhdr.len)))")
            //print(chatdata)
        #endif
        chatdata=NSMutableData(bytes:ptr, length:Int(CFSwapInt16HostToBig(dhdr.len)))
        //chatdata=NSMutableData(bytes: ptr, length: Int(strlen(unsafeBitCast(ptr,to: UnsafePointer<Int8>.self ))))
        //print(chatdata as NSData)
        
        
        var string=String(data: chatdata as Data, encoding: String.Encoding(rawValue: encoding.rawValue))
        if string==nil && encoding==String.Encoding.utf8{
            #if DEBUG
                print("UTF")
                #endif
            string=String(data: chatdata as Data, encoding: String.Encoding(rawValue: String.Encoding.shiftJIS.rawValue))
        }
        #if DEBUG
            print("HLChatRecv:ok")
            print("string=\(String(describing: string))")
            #endif
        atts=NSMutableAttributedString(string: string! as String, attributes: [NSAttributedStringKey.foregroundColor:UIColor.black])
        atline=NSAttributedString(string: line as String, attributes: [NSAttributedStringKey.foregroundColor:UIColor.black])
        atts.append(atline)
        let nof=Notification(name: Notification.Name(rawValue: addchat), object: self,userInfo: ["chat":atts])
        NotificationCenter.default.post(nof)
        
    }
    /*func HLChatRecv(_ ddata:Data)
    {
        var atts:NSMutableAttributedString=NSMutableAttributedString()
        var atline:NSAttributedString=NSAttributedString()
        //var str:NSString=NSString()
        let mdata:NSMutableData?=NSMutableData()
        let line:NSString="\n"
        var dhdr:HL_DATA=HL_DATA()
        var dddata:NSData?=NSData()
        var ptr:UnsafeMutablePointer<UInt8>=UnsafeMutablePointer.allocate(capacity: ddata.count)
        ddata.copyBytes(to: ptr, count: ddata.count)
        ptr=ptr.advanced(by: Int(SIZEOF_HL_HDR))
        var testdata=Data()
        //(testdata as NSData).getBytes(&ptr, length: SIZEOF_HL_HDR)
        testdata=NSData(bytes: ptr, length: ddata.count-SIZEOF_HL_HDR) as Data
        print(testdata as NSData)
        //print(ptr.description)
        dddata=hlcm.pointerIncrement(ddata as Data, length: SIZEOF_HL_HDR) as NSData
        dddata?.getBytes(&dhdr, length: SIZEOF_DATA_HDR)
        #if DEBUG
            print("hdr=\(Int(CFSwapInt16HostToBig(dhdr.type)))")
            print("len=\(Int(CFSwapInt16HostToBig(dhdr.len)))")
            print(ddata as NSData)
        #endif
        dddata=hlcm.pointerIncrement(dddata as Data!, length: 1) as NSData
        dddata=hlcm.pointerIncrement(dddata as Data!, length: SIZEOF_DATA_HDR) as NSData
        mdata?.append((dddata?.bytes)!, length: Int(CFSwapInt16HostToBig(dhdr.len)))
        
        //if(encoding==String.Encoding.utf8){
        //print(dddata)
        if encoding==String.Encoding.utf8{
                 dddata=hlcm.cleanUTF8(mdata as Data!) as NSData
        }else if encoding==String.Encoding.shiftJIS{
                 dddata=hlcm.cleanSJIS(mdata as Data!) as NSData
        }
        //if dddata.length==0{
        //    dddata=NSData(data: mdata as Data)
        //}
        let str=NSString(data:dddata!as Data, encoding:encoding.rawValue)
        //print("str=\(str)")
        /*if str==nil{
            //print("SJISEncoding")
            str=NSString(data:dddata as Data, encoding:String.Encoding.shiftJIS.rawValue)
        }*/
        atts=NSMutableAttributedString(string: str! as String, attributes: [NSForegroundColorAttributeName:UIColor.black])
        atline=NSAttributedString(string: line as String, attributes: [NSForegroundColorAttributeName:UIColor.black])
        atts.append(atline)
        let nof=Notification(name: Notification.Name(rawValue: addchat), object: self,userInfo: ["chat":atts])
        NotificationCenter.default.post(nof)
    }*/
    
    //MARK:USERLISTCHANGE
    func userchange(_ reply:NSData)
    {
        #if DEBUG
            print("userchange")
        #endif
        var count:Int
        var hdr:HL_HDR=HL_HDR()
        var dhdr:HL_DATA=HL_DATA()
        var ddata:Data=Data()
        var type:UInt16
        (reply as NSData).getBytes(&hdr, length: SIZEOF_HL_HDR)
        var rreply=hlcm.pointerIncrement(reply as Data!, length: SIZEOF_HL_HDR) as NSData
        count=Int(CFSwapInt16HostToBig(hdr.hc))
        //for(i=0;i<count;i++){
        //if joinchat==true{
        for _ in 0..<count{
            rreply.getBytes(&dhdr, length: SIZEOF_DATA_HDR)
            type=UInt16(Int(CFSwapInt16HostToBig(dhdr.type)))
            #if DEBUG
                print("type=\(Int(CFSwapInt16HostToBig(dhdr.type)))")
                print("len=\(Int(CFSwapInt16HostToBig(dhdr.len)))")
            #endif
            rreply=hlcm.pointerIncrement(rreply as Data!, length: SIZEOF_DATA_HDR) as NSData
            //ddata=Data(bytes: UnsafePointer<UInt8>(rreply.bytes), count: Int(CFSwapInt16HostToBig(dhdr.len)))
            ddata=Data(bytes: UnsafeRawPointer(rreply.bytes).assumingMemoryBound(to:UInt8.self),count: Int(CFSwapInt16HostToBig(dhdr.len)))
            rreply=hlcm.pointerIncrement(rreply as Data, length: Int(CFSwapInt16HostToBig(dhdr.len))) as NSData
            //rreply=hlcm.pointerIncrement(rreply as Data!, length:Int(CFSwapInt16HostToBig(dhdr.len))) as NSData
            #if DEBUG
                print(ddata)
            #endif
            
            switch(type){
            case HL_DATA_OLDPOSTNEWS:
                #if DEBUG
                    print("HL_DATA_OLD_POST_NEWS_UID")
                #endif
                self.getuid(ddata)
                break
            case HL_DATA_SERVERMSG:
                #if DEBUG
                    print("HL_DATA_SERVERMSG")
                #endif
                self.geticon(ddata)
                break
            case HL_DATA_USER_JOIN_CHAT:
                #if DEBUG
                    print("HL_DATA_USER_JOIN_CHAT")
                #endif
                getcolor(ddata)
                break
            case HL_DATA_RECV_NICK:
                #if DEBUG
                    print("HL_DATA_RECV_NICK")
                #endif
                getnick(ddata)
                break
            case HL_DATA_USER_INVITE_CHAT:
                //self.getnick(ddata)
                #if DEBUG
                    print("HL_DATA_USER_INVITE_CHAT")
                    #endif
                getcolor(ddata)
                //print(ddata as! NSMutableData)
                break
            default:
                #if DEBUG
                    print("HL_UNKNOWN HEADER userchange=\(type)")
                    #endif
                break
            }
        }
    }
    func userJoinChat()
    {
        #if DEBUG
            print("userJoinChat:ok")
            #endif
        
        if(serverinfoarray.count==0){
            serverinfoarray.insert("HL", at: 0)
            serverinfoarray.insert("test", at: 1)
            serverinfoarray.insert(addressinfo, at: 2)
        }
        let nf=Notification(name: Notification.Name(rawValue: callchatwindow), object: self)
        NotificationCenter.default.post(nf)
        //self.clearUserlist()
        //hluidarray.removeAllObjects()
        //hlnicknamearray.removeAllObjects()
        //hliconarray.removeAllObjects()
        //nf=Notification(name:Notification.Name(rawValue: listreload),object: self)
        //NotificationCenter.default.post(nf)
        //hlsend.sendOldLogin()
        
    }
    func checkexistuid(_ ddata:Data)
    {
        #if DEBUG
        print("checkexistuid")
        #endif
        var uidhdr:HL_UID=HL_UID()
        var str:String=String()
        var arraycount=0
        //var count=0
        //let checkstr:String=String()
        (ddata as NSData).getBytes(&uidhdr, length: MemoryLayout<HL_UID>.size)
        str=String(CFSwapInt16HostToBig(uidhdr.uid))
        idrow=hluidarray.index(of: str)
        #if DEBUG
            print(uidhdr)
            print("uid=\(str)")
            print("hluid=\(hluidarray)")
            print("idrow=\(idrow)")
            #endif
        //count=hluidarray.index(of: str)
        //print(count)
        //for(i=0;i<hluidarray.count;i++)
        /*for _ in 0..<hluidarray.count{
            arraycount=hluidarray.count
        }*/
        arraycount=hluidarray.count
        if idrow >= arraycount {
            existuidflag=false
        }else{
            existuidflag=true
        }
        //arraycount=hluidarray.count
        
        /*if idrow>0{
            existuidflag=false
        }else{
            existuidflag=true
        }*/
        /*for i in 0..<arraycount {
            if(str==hluidarray[i] as! String){
                existuidflag=true
                #if DEBUG
                print("num=",i)
                print("UID=",String(CFSwapInt16HostToBig(uidhdr.uid)))
                print("id matched")
                #endif
                //i=hluserarray.count
            }else{
                #if DEBUG
                    print("num=",i)
                    print("UID=",String(CFSwapInt16HostToBig(uidhdr.uid)))
                print("ID not matched")
                #endif
            }
        }*/
        
        //idrow=count
    }
    func recvHLPing(){
        //var timer=NSTimer()
        let queue=OperationQueue()
        let hlsend:HLSend=HLSend()
        #if DEBUG
            print("recvHLPing:ok")
            #endif
        //repeat{
        queue.addOperation { () -> Void in
            repeat{
            sleep(UInt32(pingtime))
                #if DEBUG
                    print("hlversion=\(hlversion)")
                #endif

            //NSThread.sleepForTimeInterval(150)
               if(hlflag==1 && hlversion=="191" || hlversion=="185"){
                #if DEBUG
                    print("HL_PING vers over 1.5.1")
                #endif
               hlsend.sendhlping()
            }else{
                #if DEBUG
                print("HL_PING vers 1.2.3")
                #endif
                
            }
        }while(outputHLStream != nil)
        }
        //}while(outputHLStream != nil)
        //timer.invalidate()
        //timer=NSTimer.scheduledTimerWithTimeInterval(150, target: hlsend, selector: Selector("sendhlping:"), userInfo: nil, repeats: false)
        //NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    func getuid(_ ddata:Data)
    {
        #if DEBUG
            print("getuid")
            #endif
        checkexistuid(ddata)
           var uidhdr:HL_UID=HL_UID()
           (ddata as NSData).getBytes(&uidhdr, length: MemoryLayout<HL_UID>.size)
        if(existuidflag==false){
           hluidarray.add(String(CFSwapInt16HostToBig(uidhdr.uid)))
        }
        //}
    }
    func geticon(_ ddata:Data)
    {
        #if DEBUG
            print("geticon")
        #endif
        //if(existuidflag==false){
        var uidhdr:HL_UID=HL_UID()
        (ddata as NSData).getBytes(&uidhdr, length: MemoryLayout<HL_UID>.size)
        if(existuidflag==false){
            hliconarray.add(String(CFSwapInt16HostToBig(uidhdr.uid)))
        }else{
            hliconarray[idrow]=String(CFSwapInt16HostToBig(uidhdr.uid))
        }
        #if DEBUG
            print("ICON",hliconarray)
        #endif
    }
    func getcolor(_ ddata:Data)
    {
        #if DEBUG
            print("getcolor")
        #endif
        var uidhdr:HL_UID=HL_UID()
        (ddata as NSData).getBytes(&uidhdr, length: MemoryLayout<HL_UID>.size)
        if(existuidflag==false){
            hlcolorarray.add(String(CFSwapInt16HostToBig(uidhdr.uid)))
        }else{
            hlcolorarray[idrow]=String(CFSwapInt16HostToBig(uidhdr.uid))
        }
        #if DEBUG
            print("COLOR",hlcolorarray)
        #endif

    }
    func getnick(_ ddata:Data)
    {
        #if DEBUG
            print("getnick:ok")
            print("existuidflag=\(existuidflag)")
            #endif
        //if(existuidflag==false){
       //var messe:String?="<<<<< "
        //let nickstr:NSString?=NSString(data: ddata, encoding: encoding.rawValue)
        let nickcount=hlnicknamearray.count
       // messe!+=hlnicknamearray[nickcount] as! String
        //messe!+=" "
        //messe!+="has joined >>>>>\n"
        if(existuidflag==false && nickcount>=1){
            var messe:String?="<<<<< "
            var nickstr:NSString?=NSString(data: ddata, encoding: encoding.rawValue)
            if nickstr==nil{
                nickstr=NSString(data: ddata, encoding: String.Encoding.shiftJIS.rawValue)
            }
            hlnicknamearray.add(nickstr!)
            messe!+=hlnicknamearray[nickcount] as! String
            messe!+=" "
            messe!+="has joined >>>>>\n"
            let attmess=NSAttributedString(string: messe!, attributes: [NSAttributedStringKey.foregroundColor:UIColor.red])
        var nf=Notification(name: Notification.Name(rawValue: listreload), object:self)
        NotificationCenter.default.post(nf)
        nf=Notification(name: Notification.Name(rawValue: addchat), object: self,userInfo: ["chat":attmess])
        NotificationCenter.default.post(nf)
        }else if existuidflag==false && nickcount == 0{
            idrow=0
            var nickstr:NSString?=NSString(data: ddata, encoding: encoding.rawValue)
            if nickstr==nil{
                nickstr=NSString(data: ddata, encoding: String.Encoding.shiftJIS.rawValue)
            }
            hlnicknamearray.add(nickstr!)
            hlnicknamearray[idrow]=nickstr!
            var nf=Notification(name: Notification.Name(rawValue: listreload), object:self)
            NotificationCenter.default.post(nf)
            nf=Notification(name: Notification.Name(rawValue: listreload), object: self)
            NotificationCenter.default.post(nf)
        }else{
            var nickstr:NSString?=NSString(data: ddata, encoding: encoding.rawValue)
            if nickstr==nil{
                nickstr=NSString(data: ddata, encoding: String.Encoding.shiftJIS.rawValue)
            }
            //hlnicknamearray.add(nickstr!)
            hlnicknamearray[idrow]=nickstr!
            var nf=Notification(name: Notification.Name(rawValue: listreload), object:self)
            NotificationCenter.default.post(nf)
            nf=Notification(name: Notification.Name(rawValue: listreload), object: self)
            NotificationCenter.default.post(nf)
            
        }
        //}
        #if DEBUG
        print("nicknamearray=",hlnicknamearray)
            #endif
        let nf=Notification(name: Notification.Name(rawValue: listreload), object:self)
        NotificationCenter.default.post(nf)
        existuidflag=false
        joinchat=true
    }
    //MARK:USERLEFT
    func userleftloop(_ reply:NSData)
    {
        #if DEBUG
            print("userleftloop")
        #endif
        var count:Int
        var hdr:HL_HDR=HL_HDR()
        var dhdr:HL_DATA=HL_DATA()
        var ddata:Data=Data()
        var type:UInt16
        (reply as NSData).getBytes(&hdr, length: SIZEOF_HL_HDR)
        var rreply=hlcm.pointerIncrement(reply as Data!, length: SIZEOF_HL_HDR) as NSData
        count=Int(CFSwapInt16HostToBig(hdr.hc))
        //for(i=0;i<count;i++){
        for _ in 0..<count {
            rreply.getBytes(&dhdr, length: SIZEOF_DATA_HDR)
            type=UInt16(Int(CFSwapInt16HostToBig(dhdr.type)))
            #if DEBUG
                print("type=\(Int(CFSwapInt16HostToBig(dhdr.type)))")
                print("len=\(Int(CFSwapInt16HostToBig(dhdr.len)))")
            #endif
            rreply=hlcm.pointerIncrement(rreply as Data!, length: SIZEOF_DATA_HDR) as NSData
            //ddata=Data(bytes: UnsafePointer<UInt8>(rreply.bytes), count: Int(CFSwapInt16HostToBig(dhdr.len)))
            ddata=Data(bytes: UnsafeRawPointer(rreply.bytes).assumingMemoryBound(to: UInt8.self), count: Int(CFSwapInt16HostToBig(dhdr.len)))
            rreply=hlcm.pointerIncrement(rreply as Data!, length:Int(CFSwapInt16HostToBig(dhdr.len))) as NSData
            #if DEBUG
                print(ddata)
            #endif
            switch(type){
            case HL_DATA_OLDPOSTNEWS:
                #if DEBUG
                    print("HL_DATA_OLD_POST_NEWS")
                #endif
                self.deleteuser(ddata)
                break
            default:
                #if DEBUG
                    print("Header not Defined")
                #endif
                break
            }
        }
        
        
    }
    func deleteuser(_ ddata:Data)
    {
        var nick="<<<<< "
        var delnick:String=String()
        checkexistuid(ddata)
        delnick=hlnicknamearray[idrow] as! String
        nick=nick+delnick+" has left >>>>>\n"
        hlnicknamearray.removeObject(at: idrow)
        hliconarray.removeObject(at: idrow)
        hluidarray.removeObject(at: idrow)
        hlcolorarray.removeObject(at: idrow)
        let attmess=NSAttributedString(string: nick, attributes: [NSAttributedStringKey.foregroundColor:UIColor.red])
        var nf=Notification(name: Notification.Name(rawValue: listreload), object:self)
        NotificationCenter.default.post(nf)
        nf=Notification(name: Notification.Name(rawValue: addchat), object: self,userInfo: ["chat":attmess])
        NotificationCenter.default.post(nf)
        //print(hluidarray)
        existuidflag=false
    }
    func HLdataHeaderSeparator(_ ddata:inout NSData,counter:Int)->[AnyObject]
    {
        let dataarray=NSMutableArray()
        var newdata=Data()
        _=Data()
        var dhdr=HL_DATA()
        for i in 0..<counter
        {
            (ddata as NSData).getBytes(&dhdr, length: SIZEOF_DATA_HDR)
            //newdata=Data(bytes: UnsafeRawPointer(ddata.bytes).assumingMemoryBound(to: UInt8.self), count: Int(CFSwapInt16HostToBig(dhdr.len)))
            newdata=hlcm.pointerCopy(ddata as Data!, length: Int(CFSwapInt16HostToBig(dhdr.len)))
            dataarray.insert(newdata, at: i)
            ddata=hlcm.pointerIncrement(ddata as Data!, length:Int(CFSwapInt16HostToBig(dhdr.len))+SIZEOF_DATA_HDR ) as NSData
        }
        
        return(dataarray) as [AnyObject]
    }
    func HLPrivateMSGRecv(_ ddata:NSData)
    {
        #if DEBUG
            print("HLPrivateMSGRecv")
        #endif
        var newdata=NSData()
        var tmpdata=NSData()
        var hdr=HL_HDR()
        var dhdr=HL_DATA()
        //var uhdr=HL_UID()
        var message:String!=String()
        var nick:String=String()
        (ddata as NSData).getBytes(&hdr, length: SIZEOF_HL_HDR)
        //print("newdata=",newdata)
        newdata=hlcm.pointerIncrement(ddata as Data!, length: SIZEOF_HL_HDR) as NSData
        //newdata=hlcm.pointerCopy(newdata as Data!, length: ddata.length-Int(SIZEOF_HL_HDR)) as NSData
        //print(newdata)
        //var dataarray=HLdataHeaderSeparator(newdata as Data as Data, counter: Int(CFSwapInt16HostToBig(hdr.hc)))
        //newdata=hlcm.pointerIncrement(newdata as Data!, length: SIZEOF_HL_HDR) as NSData
        var dataarray=HLdataHeaderSeparator(&newdata, counter: Int(CFSwapInt16HostToBig(hdr.hc)))
        
        //newdata=hlcm.pointerIncrement(ddata as Data!, length: SIZEOF_HL_HDR) as NSData
        for i in 0..<Int(CFSwapInt16HostToBig(hdr.hc)){
            //newdata=hlcm.pointerIncrement(dataarray[i] as! Data, length: SIZEOF_HL_HDR) as NSData
            newdata=dataarray[i] as! NSData
            //newdata=hlcm.pointerCopy(dataarray[i] as! Data, length: Int(CFSwapInt16(dhdr.len))) as NSData
            newdata.getBytes(&dhdr, length: SIZEOF_DATA_HDR)
            #if DEBUG
                print("dhdr=\(Int(CFSwapInt16HostToBig(dhdr.type)))")
                print("dlen=\(Int(CFSwapInt16HostToBig(dhdr.len)))")
                print(newdata)
            #endif
            switch(CFSwapInt16HostToBig(dhdr.type)){
            case HL_DATA_UID:
                #if DEBUG
                    print("MSG UID")
                    print(dataarray[i])
                #endif
                newdata=hlcm.pointerIncrement(newdata as Data!, length: SIZEOF_DATA_HDR) as NSData
                #if DEBUG
                    print("mid",newdata)
                    #endif
                //newdata=Data(bytes: UnsafePointer<UInt8>(newdata.bytes), count: Int(CFSwapInt16HostToBig(dhdr.len)))
                newdata=Data(bytes: UnsafeRawPointer(newdata.bytes).assumingMemoryBound(to: UInt8.self), count: Int(CFSwapInt16HostToBig(dhdr.len))) as NSData
                tmpdata=newdata
                //print("checkid data=",newdata)
                self.checkexistuid(tmpdata as Data)
                nick=hlnicknamearray[idrow] as! String
                newdata=hlcm.pointerIncrement(newdata as Data, length: SIZEOF_DATA_HDR+Int(CFSwapInt16HostToBig(dhdr.len))) as NSData
                //print("msgdata=",newdata)
                break
                
            case HL_DATA_NEWS:
                #if DEBUG
                    print("MSG NEWS")
                #endif
                //newdata=hlcm.pointerIncrement(dataarray[i] as! Data, length: SIZEOF_DATA_HDR) as NSData
                newdata=hlcm.pointerIncrement(newdata as Data!, length: SIZEOF_DATA_HDR) as NSData
                //newdata=Data(bytes: UnsafePointer<UInt8>(newdata.bytes), count: Int(CFSwapInt16HostToBig(dhdr.len)))
                newdata=Data(bytes: UnsafeRawPointer(newdata.bytes).assumingMemoryBound(to: UInt8.self), count: Int(CFSwapInt16HostToBig(dhdr.len))) as NSData
                message=String(data:newdata as Data, encoding:encoding)
                 newdata=hlcm.pointerIncrement(newdata as Data, length: SIZEOF_DATA_HDR) as NSData
                break
            default:
                break
            }
        }

        
        /*
        newdata=hlcm.pointerIncrement(ddata, length: SIZEOF_HL_HDR)
        newdata.getBytes(&dhdr, length: 4)
        newdata=hlcm.pointerIncrement(newdata, length: SIZEOF_DATA_HDR)
        tmpdata=NSData(bytes: newdata.bytes, length:Int(CFSwapInt16HostToBig(dhdr.len)))
        newdata.getBytes(&uhdr, length: Int(CFSwapInt16HostToBig(dhdr.len)))
        self.checkexistuid(tmpdata)
        newdata=hlcm.pointerIncrement(newdata, length: Int(CFSwapInt16HostToBig(dhdr.len)))
        nick=hlnicknamearray[idrow] as! String
        newdata.getBytes(&dhdr, length: SIZEOF_DATA_HDR)
        newdata=hlcm.pointerIncrement(newdata, length: SIZEOF_DATA_HDR)
        newdata=NSData(bytes: newdata.bytes, length: Int(CFSwapInt16HostToBig(dhdr.len)))
        print(newdata)
        message=String(data: newdata, encoding: encoding)
        #if DEBUG
            print(nick)
            print(message)
        #endif
 */
        let alert = UIAlertController(title: nick+" wrote:", message: message , preferredStyle: .alert)
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",
                                                       style: UIAlertActionStyle.cancel,
                                                       handler:{
                                                        (action:UIAlertAction!) -> Void in
                                                        #if DEBUG
                                                            print("Cancel")
                                                        #endif
        })
        let okAction:UIAlertAction = UIAlertAction(title: "Reply",
                                                   style: UIAlertActionStyle.destructive,
                                                   handler:{
                                                    (action:UIAlertAction!) -> Void in
                                                    #if DEBUG
                                                        print("Reply")
                                                    #endif
                                                    let alert:UIAlertController = UIAlertController(title:"Message to "+nick,
                                                        message: "Message:",
                                                        preferredStyle: UIAlertControllerStyle.alert)
                                                    
                                                    let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",
                                                        style: UIAlertActionStyle.cancel,
                                                        handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                            
                                                    })
                                                    let defaultAction:UIAlertAction = UIAlertAction(title: "OK",
                                                        style: UIAlertActionStyle.default,
                                                        handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                            let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                                                            if textFields != nil {
                                                                for _:UITextField in textFields! {
                                                                    
                                                                }
                                                            }
                                                            let hlsend:HLSend=HLSend()
                                                            hlsend.HLSendPrivateMSG(textFields![0].text! as String,idata: tmpdata as Data)
                                                    })
                                                    alert.addAction(cancelAction)
                                                    alert.addAction(defaultAction)
                                                    
                                                    //textfiledの追加
                                                    alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
                                                    })
                                                    //実行した分textfiledを追加される。
                                                    //alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
                                                    //})
                                                    let alertWindow=UIWindow(frame:UIScreen.main.bounds)
                                                    alertWindow.rootViewController=UIViewController()
                                                    alertWindow.makeKeyAndVisible()
                                                    alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alertWindow.rootViewController = UIViewController()
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)

        
        
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
