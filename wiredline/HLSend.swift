//
//  HLSend.swift
//  wiredline
//
//  Created by HiraoKazumasa on 10/20/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import UIKit
import Foundation
let HLINITLEN=12
let HLINT="TRTPHOTL"
let HLSINT="TRTP"
//HDR
let SIZEOF_HL_HDR:Int=22
let SIZEOF_DATA_HDR:Int=4
let SIZEOF_FILE_DATA:Int=20

let HL_HDR_GETNEWS:UInt32=101 //65
let HL_HDR_NEWSFILEPOST:UInt32=103
let HL_HDR_SENDCHAT:UInt32=105 //67
let HL_HDR_LOGIN:UInt32=107  
let HL_HDR_MESSAGE:UInt32=108  //6C
let HL_HDR_USERKICK:UInt32=110 //6E
let HL_HDR_USERBAN:UInt32=113
let HL_HDR_SENDAGREE:UInt32=121
let HL_HDR_GETFILELIST:UInt32=200 //c8
let HL_HDR_USERLIST:UInt32=300 //12C
let HL_HDR_GETUSER_INFO:UInt32=303 //12F
let HL_HDR_USER_CHANGE:UInt32=304 //130
let HL_HDR_PING:UInt32=500 //1f4


//DataHDR
let HL_DATA_LOGIN:UInt16=105
let HL_DATA_PASSWD:UInt16=106
let HL_DATA_ICON:UInt16=104
let HL_DATA_NICK:UInt16=102
let HL_DATA_STYLE:UInt16=109
let HL_DATA_UID:UInt16=103   //67
let HL_DATA_USERBAN:UInt16=113
let HL_DATA_BAN:UInt16=117 //0x0075
let HL_DATA_CLIENTVER:UInt16=160
let HL_DATA_SENDCHAT:UInt16=101
let HL_DATA_GETFILELIST:UInt16=202

var hl_hdrtrans:UInt32=1
struct HL_HDR{
    var type:UInt16
    var trans:UInt32
    var flag:UInt32
    var len:UInt32
    var len2:UInt32
    var hc:UInt16
    init(){
        type=0
        trans=0
        flag=0
        len=0
        len2=0
        hc=0
    }
}
struct HL_DATA{
    var type:UInt16
    var len:UInt16
    var data:UInt16
    init(){
        type=0
        len=0
        data=0
    }
    
}

let HLINTARRAY=[0x0,0x1,0x0,0x2] as [UInt8]
let HLINITBIN1=Character(UnicodeScalar(0))
let HLINITBIN2=Character(UnicodeScalar(1))
let HLINITBIN3=Character(UnicodeScalar(0))
let HLINITBIN4=Character(UnicodeScalar(2))
let HLINITBIN5=Character(UnicodeScalar(7))
var loginflag=false
class HLSend: UIViewController {
    let hlcmethod:HLCMethod=HLCMethod()
    let hlstr:HLString=HLString()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func sendHLUserInfo(_ usernum:AnyObject)
    {
        var hdr=HL_HDR()
        var dhdr=HL_DATA()
        var num:UInt32=UInt32()
        var senddata:NSMutableData=NSMutableData()
        var data:Data=Data()
        num=UInt32(usernum as! String)!
        #if DEBUG
            print("sendHLUserinfo:ok")
            print(num)
            #endif
        hdr=makeHLHeader(HL_HDR_GETUSER_INFO, hccount: 1, datalen: 10)//UInt32(SIZEOF_DATA_HDR+SIZEOF_HL_HDR))
        senddata=NSMutableData(bytes: &hdr, length: SIZEOF_HL_HDR)
        dhdr=makeHLDataHeader(HL_DATA_UID, datalen: 4)
        data=NSData(bytes:&dhdr, length: SIZEOF_DATA_HDR) as Data
        //data=Data(bytes: UnsafePointer<UInt8>(&dhdr), count: SIZEOF_DATA_HDR)
        senddata.append(data)
        //print(senddata)
        data=iconbyteorder(num)
        senddata.append(data)
        
        writeDataToServer(senddata as Data)
        //print(senddata)
    }
    func sendHLInit()
    {
        let command=HLINT+String(HLINITBIN1)+String(HLINITBIN2)+String(HLINITBIN3)+String(HLINITBIN4)
        writeToServer(command, length: HLINITLEN)
        #if DEBUG
             print("sendHLInit=",command)
        #endif
        
    }
    func sendHLPrivateMSG()
    {
        
        
    }
    
    func sendNickIcon(_ nickstr:String, icon:String)
    {
        var hdr:HL_HDR=HL_HDR()
        var dhdr:HL_DATA=HL_DATA()
        var length:UInt32
        
        var data:NSMutableData=NSMutableData()
        var temp:Data=Data()
        length=UInt32(nickstr.lengthOfBytes(using: encoding))
        length+=UInt32(icon.lengthOfBytes(using: encoding))
        //length+=UInt32(SIZEOF_HL_HDR)
        length+=UInt32(SIZEOF_DATA_HDR*2)+1
        hdr=makeHLHeader(HL_HDR_USER_CHANGE, hccount: 2, datalen:length)
        data=NSMutableData(bytes: &hdr, length: SIZEOF_HL_HDR)
        dhdr=makeHLDataHeader(HL_DATA_NICK, datalen: UInt16(nickstr.lengthOfBytes(using: encoding)))
        data.append(&dhdr, length:Int(SIZEOF_DATA_HDR))
        temp=nickstr.data(using: String.Encoding.utf8,allowLossyConversion:false)!
        data.append(temp)
        //temp=hlcsend.getIconno(icon)
        temp=iconbyteorder(UInt32(icon)!)
        dhdr=makeHLDataHeader(HL_DATA_ICON, datalen: UInt16(temp.count))
        data.append(&dhdr, length: SIZEOF_DATA_HDR)
        //temp=iconbyteorder(UInt32(icon)!)
        data.append(temp)
        //print(data)
        self.writeDataToServer(data as Data)
        
    }
    func HLGetUerlist()
    {
        #if DEBUG
        print("getuserlist")
        #endif
        var hdr=HL_HDR()
        let hlrecv=HLRecv()
        hlrecv.clearUserlist()
        hluidarray.removeAllObjects()
        hlcolorarray.removeAllObjects()
        hliconarray.removeAllObjects()
        hlnicknamearray.removeAllObjects()
        hdr=makeHLHeader(HL_HDR_USERLIST,hccount:0,datalen:2)
        let data=NSData(bytes: &hdr, length: SIZEOF_HL_HDR)
        self.writeDataToServer(data as Data)
        
    }
    
    func writeToServer(_ str:String, length:Int)
    {
        #if DEBUG
            print("wireToServer:ok")
        #endif
        _ = [UInt8](str.utf8)
        let data: Data = str.data(using: String.Encoding(rawValue: encoding.rawValue))!
        
        //print(data)
        outputHLStream?.write((data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), maxLength:length)
    }
    func HLVersionLogin(_ data:Data)
    {
        #if DEBUG
        print("HLVersionLogin:ok")
            print(data as! NSMutableData)
        #endif
        var sever:UInt=0
        (data as NSData).getBytes(&sever, length: MemoryLayout<UInt>.size)
        hlversion = String(CFSwapInt16BigToHost(UInt16(sever)))
        #if DEBUG
            print(hlversion)
            #endif
        if loginflag==false{
        if hlversion == "191" || hlversion == "185" {
            //sendOver151()
        }else {
            sendOldLogin()
        }
            loginflag=true
        }
        
        
    }
    func HLLoginSequence()
    {
        var senddata:NSMutableData=NSMutableData()
        var tempdata:NSData=NSData()
        let ldata=hlcmethod.hlEncryptedLogin(logininfo[0] as String)
        let pdata=hlcmethod.hlEncryptedPassword(logininfo[1] as String)
        var hdr:HL_HDR
        var clientver:UInt32
        var clientdata:NSData
        var dhdr:HL_DATA
        var plen,llen,clen:Int
        var totallen:UInt32
        clientver=190
        clientdata=clientbyteorder(clientver) as NSData
        //hlstr.HLStringEncript(logininfo[0] as String)
        llen=logininfo[0].lengthOfBytes(using: String.Encoding.utf8)
        plen=logininfo[1].lengthOfBytes(using: String.Encoding.utf8)
        clen=clientdata.length
        
        totallen=UInt32(llen+plen+clen+2)
        hdr=makeHLHeader(HL_HDR_LOGIN, hccount: 3, datalen: UInt32(totallen)+UInt32(SIZEOF_DATA_HDR*3))
        senddata=NSMutableData(bytes: &hdr, length: SIZEOF_HL_HDR)
        dhdr=makeHLDataHeader(HL_DATA_LOGIN, datalen: UInt16(llen))
        tempdata=NSData(bytes: &dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        senddata.append(ldata!)
        
        dhdr=makeHLDataHeader(HL_DATA_PASSWD, datalen: UInt16(plen))
        tempdata=NSData(bytes: &dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        senddata.append(pdata!)
        
        dhdr=makeHLDataHeader(HL_DATA_CLIENTVER, datalen: UInt16(clen))
        tempdata=NSData(bytes: &dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        senddata.append(clientbyteorder16(UInt16(clientver)))
        writeDataToServer(senddata as Data)
        
        /*totallen=UInt32(nlen+ilen+2+2)
        hdr=makeHLHeader(HL_HDR_SENDAGREE, hccount: 3, datalen:UInt32(totallen)+UInt32(SIZEOF_DATA_HDR*3) )
        senddata=NSMutableData(bytes:&hdr,length:SIZEOF_HL_HDR)
        dhdr=makeHLDataHeader(HL_DATA_NICK, datalen: UInt16(nlen))
        tempdata=NSData(bytes: &dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        tempdata=logininfo[2].data(using: String.Encoding.utf8, allowLossyConversion: false  )! as NSData
        senddata.append(tempdata as Data)
        
        dhdr=makeHLDataHeader(HL_DATA_ICON, datalen: 2)
        tempdata=NSMutableData(bytes: &dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        senddata.append(icondata as Data)
        
        dhdr=makeHLDataHeader(HL_DATA_USERBAN, datalen:2)
        tempdata=NSMutableData(bytes: &dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        senddata.append(clientbyteorder16(0))
        self.writeDataToServer(senddata as Data)
        
        /*senddata=NSMutableData()
        hdr=makeHLHeader(HL_HDR_USERLIST,hccount:0,datalen:2)
        tempdata=NSData(bytes:&hdr, length: SIZEOF_HL_HDR)
        senddata.append(tempdata as Data)
        self.writeDataToServer(senddata as Data)*/
        
        /*let queue=OperationQueue()
        queue.addOperation { () -> Void in
                sleep(UInt32(2))
            senddata=NSMutableData()
            hdr=self.makeHLHeader(HL_HDR_USERLIST,hccount:0,datalen:2)
            tempdata=NSData(bytes:&hdr, length: SIZEOF_HL_HDR)
            senddata.append(tempdata as Data)
            self.writeDataToServer(senddata as Data)
                //NSThread.sleepForTimeInterval(150)
        }*/

        /*senddata=NSMutableData()
        hdr=makeHLHeader(HL_HDR_USERLIST,hccount:0,datalen:2)
        tempdata=NSData(bytes:&hdr, length: SIZEOF_HL_HDR)
        senddata.append(tempdata as Data)
        self.writeDataToServer(senddata as Data)*/
        /*
        totallen=UInt32(llen+plen+nlen+ilen+clen)
        var passlen=totallen//+UInt32((Int(5)*SIZEOF_DATA_HDR+Int(2)))
        passlen=passlen+2
        passlen=passlen+UInt32((Int(5)*SIZEOF_DATA_HDR))
        hdr=makeHLHeader(HL_HDR_LOGIN, hccount: 5, datalen: passlen)
        senddata=NSMutableData(bytes: &hdr, length: SIZEOF_HL_HDR)
        dhdr=makeHLDataHeader(HL_DATA_LOGIN, datalen: UInt16(llen))
        tempdata=NSData(bytes:&dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        senddata.append(ldata!)
        
        
        dhdr=makeHLDataHeader(HL_DATA_PASSWD, datalen: UInt16(plen))
        tempdata=NSData(bytes:&dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        senddata.append(pdata!)
        
        dhdr=makeHLDataHeader(HL_DATA_ICON, datalen: UInt16(ilen))
        tempdata=NSData(bytes:&dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        senddata.append(icondata as Data)
        
        dhdr=makeHLDataHeader(HL_DATA_NICK, datalen: UInt16(nlen))
        tempdata=NSData(bytes: &dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        let test=logininfo[2]
        tempdata=test.data(using: String.Encoding(rawValue: encoding.rawValue), allowLossyConversion: true)! as NSData
        //tempdata=test.data(using: String.Encoding(using:))
        //tempdata=logininfo[2].data(using: String.Encoding.utf8, allowLossyConversion: false  )!
        senddata.append(tempdata as Data)
        
        dhdr=makeHLDataHeader(HL_DATA_CLIENTVER, datalen: UInt16(clen))
        tempdata=NSData(bytes:&dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        senddata.append(clientdata as Data)
        self.writeDataToServer(senddata as Data)
        
        
        senddata=NSMutableData()
        hdr=makeHLHeader(HL_HDR_USERLIST,hccount:0,datalen:2)
        tempdata=NSData(bytes:&hdr, length: SIZEOF_HL_HDR)
        senddata.append(tempdata as Data)
        writeDataToServer(senddata as Data)
        */
        //self.getNews()
        //hdr=makeHLHeader(HL_HDR_PING, hccount: 0, datalen: 0)
        //data=Data(bytes: UnsafePointer<UInt8>(&hdr), count: SIZEOF_HL_HDR)
        //tempdata=NSData(bytes:&hdr, length: SIZEOF_HL_HDR)
        //writeDataToServer(tempdata as Data)*/
        
        
    }
    func sendOldLogin()
    {
        #if DEBUG
            print("sendOldLogin:ok")
            #endif
        //userchange nick icon userlist
        var hdr=HL_HDR()
        var dhdr=HL_DATA()
        var senddata:NSMutableData=NSMutableData()
        var tempdata:NSData=NSData()
        var totallen:UInt32
        var ilen,nlen:Int
        if hlversion != "185" || hlversion != "191" {
        let icondata=self.clientbyteorder16(UInt16(logininfo[4])!)
        nlen=logininfo[2].lengthOfBytes(using: String.Encoding.utf8)
        ilen=icondata.count
        totallen=UInt32(nlen+ilen+2)
        
        hdr=makeHLHeader(HL_HDR_USER_CHANGE, hccount: 2, datalen: UInt32(totallen)+UInt32(SIZEOF_DATA_HDR*2))
        senddata=NSMutableData(bytes: &hdr, length: SIZEOF_HL_HDR)
        dhdr=makeHLDataHeader(HL_DATA_NICK, datalen: UInt16(nlen))
        tempdata=NSData(bytes: &dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        tempdata=logininfo[2].data(using: String.Encoding.utf8, allowLossyConversion: false)! as NSData
        senddata.append(tempdata as Data)
        dhdr=makeHLDataHeader(HL_DATA_ICON, datalen: 2)
        tempdata=NSMutableData(bytes: &dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        senddata.append(icondata as Data)
        self.writeDataToServer(senddata as Data)
        #if DEBUG
            print(senddata)
        #endif
        //hlversion="123"
        }
        getUserList()
        /*senddata=NSMutableData()
        hdr=makeHLHeader(HL_HDR_USERLIST,hccount:0,datalen:2)
        tempdata=NSData(bytes:&hdr, length: SIZEOF_HL_HDR)
        senddata.append(tempdata as Data)
        writeDataToServer(senddata as Data)
        #if DEBUG
        print(senddata)
        #endif
        */
    }
    func getUserList()
    {
        var hdr=HL_HDR()
        let senddata=NSMutableData()
        hdr=makeHLHeader(HL_HDR_USERLIST,hccount:0,datalen:2)
        let tempdata=NSData(bytes:&hdr, length: SIZEOF_HL_HDR)
        senddata.append(tempdata as Data)
        hluidarray.removeAllObjects()
        hlcolorarray.removeAllObjects()
        hliconarray.removeAllObjects()
        hlnicknamearray.removeAllObjects()
        writeDataToServer(senddata as Data)
        #if DEBUG
            print(senddata)
        #endif
        
    }
    func sendOver151()
    {
        #if DEBUG
            print("sendOver151:ok")
            #endif
        var senddata:NSMutableData=NSMutableData()
        var tempdata:NSData=NSData()
        var hdr:HL_HDR
        //var clientdata:NSData
        //let icondata=self.iconbyteorder(UInt32(logininfo[4])!)
        let icondata=self.clientbyteorder16(UInt16(logininfo[4])!)
        var dhdr:HL_DATA
        var ilen,nlen:Int
        var totallen:UInt32
        //clientver=190
        //clientdata=clientbyteorder(clientver) as NSData
        //hlstr.HLStringEncript(logininfo[0] as String)
        nlen=logininfo[2].lengthOfBytes(using: String.Encoding.utf8)
        ilen=icondata.count
        
        totallen=UInt32(nlen+ilen+2+2)
        hdr=makeHLHeader(HL_HDR_SENDAGREE, hccount: 3, datalen:UInt32(totallen)+UInt32(SIZEOF_DATA_HDR*3) )
        senddata=NSMutableData(bytes:&hdr,length:SIZEOF_HL_HDR)
        dhdr=makeHLDataHeader(HL_DATA_NICK, datalen: UInt16(nlen))
        tempdata=NSData(bytes: &dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        tempdata=logininfo[2].data(using: String.Encoding.utf8, allowLossyConversion: false  )! as NSData
        senddata.append(tempdata as Data)
        
        dhdr=makeHLDataHeader(HL_DATA_ICON, datalen: 2)
        tempdata=NSMutableData(bytes: &dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        senddata.append(icondata as Data)
        
        dhdr=makeHLDataHeader(HL_DATA_USERBAN, datalen:2)
        tempdata=NSMutableData(bytes: &dhdr, length: SIZEOF_DATA_HDR)
        senddata.append(tempdata as Data)
        senddata.append(clientbyteorder16(0))
        self.writeDataToServer(senddata as Data)
        hlversion="191"
        joinchat = true
        getUserList()
        
    }
    func sendChat(_ string:String)
    {
        #if DEBUG
            print("sendChat:ok")
            #endif
        var hdr:HL_HDR=HL_HDR()
        var dhdr:HL_DATA=HL_DATA()
        var data:NSMutableData?=nil
        let chatdata:Data?=string.data(using: encoding)
        var length:Int
        var tempdata:Data
        if chatdata != nil{
        tempdata=Data()
        length=chatdata!.count
        if(string.lengthOfBytes(using: encoding)>0){
            hdr=makeHLHeader(HL_HDR_SENDCHAT, hccount: 1, datalen: UInt32(SIZEOF_DATA_HDR+length+2))
            data=NSMutableData(bytes: &hdr, length: SIZEOF_HL_HDR)
            dhdr=makeHLDataHeader(HL_DATA_SENDCHAT, datalen: UInt16(length))
            //tempdata=Data(bytes: UnsafePointer<UInt8>(&dhdr), count: SIZEOF_DATA_HDR)
            tempdata=NSData(bytes:&dhdr, length: SIZEOF_DATA_HDR) as Data
            data!.append(tempdata)
            data!.append(chatdata!)
            self.writeDataToServer(data! as Data)
        }
        }
    }
    func sendOptChat(_ string:String)
    {
        var hdr:HL_HDR=HL_HDR()
        var dhdr:HL_DATA=HL_DATA()
        var data:NSMutableData=NSMutableData()
        let chatdata:Data=string.data(using: encoding)!
        var length:Int
        var tempdata:Data
        tempdata=Data()
        length=chatdata.count
        if(string.lengthOfBytes(using: encoding)>0){
            hdr=makeHLHeader(HL_HDR_SENDCHAT, hccount: 2, datalen: UInt32(SIZEOF_DATA_HDR+SIZEOF_DATA_HDR+length+4))
            data=NSMutableData(bytes: &hdr, length: SIZEOF_HL_HDR)
            dhdr=makeHLDataHeader(HL_DATA_SENDCHAT, datalen: UInt16(length))
            //tempdata=Data(bytes: UnsafePointer<UInt8>(&dhdr), count: SIZEOF_DATA_HDR)
            tempdata=NSData(bytes: &dhdr, length: SIZEOF_DATA_HDR) as Data
            data.append(tempdata)
            dhdr=makeHLDataHeader(HL_DATA_STYLE, datalen:UInt16(2))
            //tempdata=Data(bytes: UnsafePointer<UInt8>(&dhdr), count: SIZEOF_DATA_HDR)
            tempdata=NSData(bytes:&dhdr, length: SIZEOF_DATA_HDR) as Data
            
            data.append(chatdata)
            data.append(tempdata)
            tempdata=clientbyteorder16(UInt16(1))
            data.append(tempdata)
            self.writeDataToServer(data as Data)
        }
    }
    
    func postNews(_ string:String)
    {
        var hdr=HL_HDR()
        var dhdr=HL_DATA()
        var data:NSMutableData=NSMutableData()
        var tempdata=Data()
        let newsdata:Data=string.data(using: encoding)!
        let length=string.lengthOfBytes(using: encoding)
        hdr=makeHLHeader(HL_HDR_NEWSFILEPOST, hccount: 1, datalen: UInt32(SIZEOF_DATA_HDR+length+2))
        data=NSMutableData(bytes: &hdr, length: SIZEOF_HL_HDR)
        dhdr=makeHLDataHeader(HL_DATA_SENDCHAT, datalen: UInt16(length))
        //tempdata=Data(bytes: UnsafePointer<UInt8>(&dhdr), count: SIZEOF_DATA_HDR)
        tempdata=NSData(bytes: &dhdr, length: SIZEOF_DATA_HDR) as Data
        data.append(tempdata)
        data.append(newsdata)
        #if DEBUG
            print("news=",data)
            #endif
        self.writeDataToServer(data as Data)
        
    }
    func getNews()
    {
        #if DEBUG
            print("HL_GET_NEWS")
        #endif
        var senddata:Data=Data()
        var hdr:HL_HDR=HL_HDR()
        hdr=makeHLHeader(HL_HDR_GETNEWS, hccount: 0, datalen: 2)
        //senddata=Data(bytes: UnsafePointer<UInt8>(&hdr), count: SIZEOF_HL_HDR)
        senddata=NSData(bytes:&hdr, length: SIZEOF_HL_HDR) as Data
        writeDataToServer(senddata)
    }
    
    func hotlineuserkick(_ num:String)
    {
        var hdr:HL_HDR=HL_HDR()
        var dhdr:HL_DATA=HL_DATA()
        let idnum=UInt32(num)
        var data:NSMutableData=NSMutableData()
        var tempdata:Data=Data()
        hdr=makeHLHeader(HL_HDR_USERKICK, hccount: 1, datalen: UInt32(SIZEOF_DATA_HDR+4+2))
        data=NSMutableData(bytes: &hdr, length:SIZEOF_HL_HDR)
        dhdr=makeHLDataHeader(HL_DATA_UID, datalen: 4)
        //tempdata=Data(bytes: UnsafePointer<UInt8>(&dhdr), count: SIZEOF_DATA_HDR)
        tempdata=NSData(bytes:&dhdr, length: SIZEOF_DATA_HDR) as Data
        data.append(tempdata as Data)
        //tempdata = NSData(bytes: &idnum, length: sizeof(NSInteger))
        tempdata=iconbyteorder(idnum!) as Data
        data.append(tempdata)
        writeDataToServer(data as Data)
    }
    func hotlineuserban(_ num:String)
    {
        var hdr:HL_HDR=HL_HDR()
        var dhdr:HL_DATA=HL_DATA()
        let idnum=UInt32(num)
        var data:NSMutableData=NSMutableData()
        var tempdata:Data=Data()
        hdr=makeHLHeader(HL_HDR_USERKICK, hccount: 2, datalen: UInt32(SIZEOF_DATA_HDR)+UInt32(SIZEOF_DATA_HDR)+4+4+2)
        data=NSMutableData(bytes: &hdr, length:SIZEOF_HL_HDR)
        dhdr=makeHLDataHeader(HL_DATA_UID, datalen: 4)
        //tempdata=Data(bytes: UnsafePointer<UInt8>(&dhdr), count: SIZEOF_DATA_HDR)
        tempdata=NSData(bytes:&dhdr, length: SIZEOF_DATA_HDR) as Data
        data.append(tempdata)
        tempdata=iconbyteorder(idnum!)
        data.append(tempdata)
        dhdr=makeHLDataHeader(HL_DATA_USERBAN, datalen: 4)
        //tempdata=Data(bytes: UnsafePointer<UInt8>(&dhdr), count: SIZEOF_DATA_HDR)
        tempdata=NSData(bytes:&dhdr, length: SIZEOF_DATA_HDR) as Data
        data.append(tempdata)
        tempdata=iconbyteorder(1)
        data.append(tempdata)
        //print(data)
        writeDataToServer(data as Data)
        
    }
    func makeHLHeader(_ hdrtype:UInt32,hccount:UInt16,datalen:UInt32)->HL_HDR
    {
        var hhdr:HL_HDR
        //var totallen:Int32
        //totallen=Int32(datalen)
        hhdr=HL_HDR()
        hhdr.type=UInt16(CFSwapInt32HostToBig(hdrtype))
        hhdr.trans=CFSwapInt32HostToBig(UInt32(hl_hdrtrans))
        hhdr.flag=CFSwapInt32HostToBig(0)
        hhdr.len=CFSwapInt32HostToBig(datalen)
        hhdr.len2=hhdr.len
        hhdr.hc=CFSwapInt16HostToBig(hccount)
        hl_hdrtrans=hl_hdrtrans+1
        return(hhdr)
    }
    func makeHLDataHeader(_ datatype:UInt16,datalen:UInt16)->HL_DATA
    {
        var dhdr:HL_DATA
        //var data:NSData
        
        dhdr=HL_DATA()
        dhdr.type=CFSwapInt16HostToBig(datatype)
        dhdr.len=CFSwapInt16HostToBig(datalen as UInt16)
        return(dhdr)
    }
    func sendhlping()
    {
        var hdr:HL_HDR=HL_HDR()
        var data:Data=Data()
        hdr=makeHLHeader(HL_HDR_PING, hccount: 0, datalen: UInt32(2))
        //data=Data(bytes: UnsafeBufferPointer<UInt8>(hdr), count: SIZEOF_HL_HDR)
        data=NSData(bytes:&hdr, length: SIZEOF_HL_HDR) as Data
        #if DEBUG
            print("sendhlping:ok")
            print(data as NSData)
            #endif
        writeDataToServer(data)
    }
    func iconbyteorder(_ iconno:UInt32)->Data
    {
        var iconrow:UInt32
        var data:Data
        iconrow=CFSwapInt32HostToBig(iconno)
        data=Data()
        //data=Data(bytes: UnsafePointer<UInt8>(&iconrow), count: 4)
        data=NSData(bytes:&iconrow, length: 4) as Data
        //println(data)
        return(data)
    }
    func clientbyteorder(_ iconno:UInt32)->Data
    {
        var iconrow:UInt32
        var data:Data
        iconrow=CFSwapInt32HostToBig(iconno)
        data=Data()
        //data=Data(bytes: UnsafePointer<UInt8>(&iconrow), count: 4)
        data=NSData(bytes:&iconrow, length: 2) as Data
        //println(data)
        return(data)
    }
    
    func clientbyteorder16(_ no:UInt16)->Data
    {
        var iconrow:UInt16
        
        var data:Data
        iconrow=CFSwapInt16HostToBig(no)
        data=Data()
        //data=Data(bytes: UnsafePointer<UInt8>(&iconrow), count: 2)
        data=NSData(bytes:&iconrow, length: 2) as Data
        //println(data)
        return(data)
        
    }
    func HLSendPrivateMSG(_ str:String,idata:Data)
    {
        var hdr:HL_HDR=HL_HDR()
        var dhdr:HL_DATA=HL_DATA()
        var tmpdata=Data()
        
        var packet:NSMutableData=NSMutableData()
        hdr=makeHLHeader(HL_HDR_MESSAGE, hccount: 2, datalen: /*UInt32(SIZEOF_HL_HDR)+*/UInt32(idata.count)+UInt32(SIZEOF_DATA_HDR)+UInt32(SIZEOF_DATA_HDR)+UInt32(str.lengthOfBytes(using: encoding))+2)
        packet=NSMutableData(bytes: &hdr, length: SIZEOF_HL_HDR)
        dhdr=makeHLDataHeader(HL_DATA_UID, datalen: UInt16(idata.count))
        //tmpdata=Data(bytes: UnsafePointer<UInt8>(&dhdr), count: SIZEOF_DATA_HDR)
        tmpdata=NSData(bytes:&dhdr, length: SIZEOF_DATA_HDR) as Data
        packet.append(tmpdata)
        packet.append(idata)
        dhdr=makeHLDataHeader(HL_DATA_SENDCHAT,datalen:UInt16(str.lengthOfBytes(using: encoding)))
        //tmpdata=Data(bytes: UnsafePointer<UInt8>(&dhdr), count: SIZEOF_DATA_HDR)
        tmpdata=NSData(bytes:&dhdr, length: SIZEOF_DATA_HDR as Int) as Data
        packet.append(tmpdata)
        tmpdata = str.data(using: encoding)!
        packet.append(tmpdata)
        
        writeDataToServer(packet as Data)
        
    }
   /*
    func HLGetFileList(_ str:String)
    {
        var hdr=HL_HDR()
        var dhdr=HL_DATA()
        var data=NSMutableData()
        if str.lengthOfBytes(using: encoding)==0 {
            hdr=makeHLHeader(HL_HDR_GETFILELIST, hccount: 1, datalen: 6)
            dhdr=makeHLDataHeader(HL_DATA_GETFILELIST, datalen: 0)
            data=NSMutableData(bytes: &hdr, length: Int(SIZEOF_HL_HDR))
            data.append(NSMutableData(bytes:&dhdr,length:Int(SIZEOF_DATA_HDR)) as Data)
        }else{
            hdr=makeHLHeader(HL_HDR_GETFILELIST, hccount: 1, datalen: 6 + UInt32(str.lengthOfBytes(using: encoding))+5)
            dhdr=makeHLDataHeader(HL_DATA_GETFILELIST, datalen:UInt16(str.lengthOfBytes(using: encoding))+5)
            data=NSMutableData(bytes: &hdr, length: Int(SIZEOF_HL_HDR))
            data.append(NSMutableData(bytes:&dhdr,length:Int(SIZEOF_DATA_HDR)) as Data)
            let bin=String(HLINITBIN1)+String(UnicodeScalar(UInt8(depth)))+String(HLINITBIN1)+String(HLINITBIN1)+String(str.characters.count)
            data.append(bin.data(using: encoding)!)
            data.append(str.data(using: encoding)!)
        }
        
        #if DEBUG
            print(data)
            #endif
        writeDataToServer(data as Data)
    }
 */
    func HotlineGetFileList(_ array:[String])
    {
        var hdr=HL_HDR()
        var dhdr=HL_DATA()
        var data=NSMutableData()
        var cmd=String()
        var cmda=String(HLINITBIN1)+String(UnicodeScalar(UInt8(array.count)))
        if array.count==0{
            #if DEBUG
                print("HLGFL.NoARRY")
                #endif
            hdr=makeHLHeader(HL_HDR_GETFILELIST, hccount: 1, datalen: 6)
            dhdr=makeHLDataHeader(HL_DATA_GETFILELIST, datalen: 0)
            data=NSMutableData(bytes: &hdr, length: Int(SIZEOF_HL_HDR))
            data.append(NSMutableData(bytes:&dhdr,length:Int(SIZEOF_DATA_HDR)) as Data)
            
        }else {
            for var str in array{
                cmd+=String(HLINITBIN1)+String(HLINITBIN1)+String(UnicodeScalar(UInt8(str.characters.count)))+str
            }
            cmda=cmda+cmd
            //print("cmd=",cmda.data(using: encoding)as? NSData)
            hdr=makeHLHeader(HL_HDR_GETFILELIST, hccount: 1, datalen: 6 + UInt32(cmda.lengthOfBytes(using: encoding)))
            dhdr=makeHLDataHeader(HL_DATA_GETFILELIST, datalen:UInt16(cmda.lengthOfBytes(using: encoding)))
            data=NSMutableData(bytes: &hdr, length: Int(SIZEOF_HL_HDR))
            data.append(NSMutableData(bytes:&dhdr,length:Int(SIZEOF_DATA_HDR)) as Data)
            data.append(cmda.data(using: encoding)!)
            
        }
        #if DEBUG
            print(data)
        #endif
        writeDataToServer(data as Data)
        
    }
    
    
    
    
    func writeDataToServer(_ data:Data)
    {
        #if DEBUG
            print("wireDataToServer:ok")
        #endif
        #if DEBUG
            //print(data.bytes)
        #endif
        //outputHLStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.count)
        outputHLStream?.write(UnsafeRawPointer((data as NSData).bytes).assumingMemoryBound(to: UInt8.self), maxLength:data.count)
        //outputHLStream?.write(buffer:UnsafePointer<UInt8>(data.bytes), maxLength:data.count)    
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
