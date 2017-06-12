//
//  AppDelegate.swift
//  wiredline
//
//  Created by flidap on 10/12/15.
//  Copyright © 2015 flidap. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity
import PushKit
import UserNotifications
import AVFoundation
import CloudKit


public var logininfo=[String]()
let SendWiredHelloCommand="SENDWIHELLO"
let loginfail="LOGINFAIL"
let servernotalive="SERVERNOTALIVE"
var wiloginflag=0
public var hlloopdata:NSMutableData=NSMutableData()
public var inputHLStream:InputStream?=nil
public var outputHLStream:OutputStream?=nil
public var inputHLFileStream:InputStream?=nil
public var outputHLFileStream:OutputStream?=nil
//テストコード 変数
var urlsession=URLSession()


//
var hlflag:Int=0
var wiredflag:Int=0
var trtpflag:Bool=false
var audioPlayer:AVAudioPlayer!


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,StreamDelegate,WCSessionDelegate {
    /*!
     @method        pushRegistry:didUpdatePushCredentials:forType:
     @abstract      This method is invoked when new credentials (including push token) have been received for the specified
     PKPushType.
     @param         registry
     The PKPushRegistry instance responsible for the delegate callback.
     @param         credentials
     The push credentials that can be used to send pushes to the device for the specified PKPushType.
     @param         type
     This is a PKPushType constant which is present in [registry desiredPushTypes].
     */
    @available(iOS 8.0, *)
    public func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, forType type: PKPushType) {
        #if DEBUG
            print("pushRegistrydidupdate")
        #endif
        
    }

    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
        
    }

    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }

    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    var data:NSMutableData=NSMutableData()
    var window: UIWindow?
    var sendintflag=0
    var session:WCSession!
    var timer:Timer=Timer()
    var backgroundTaskID : UIBackgroundTaskIdentifier = 0
    //var cfReadStream:Unmanaged<CFReadStream>?
    //var cfWriteStream:Unmanaged<CFWriteStream>?
    func voipRegistration() {
        #if DEBUG
            print("voip registration")
            #endif
        let mainQueue = DispatchQueue.main
        // Create a push registry object
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        // Set the registry's delegate to self
        voipRegistry.delegate = self as? PKPushRegistryDelegate
        // Set the push type to VoIP
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    func pushRegistry(registry: PKPushRegistry!, didUpdatePushCredentials credentials: PKPushCredentials!, forType type: String!) {
        // Register VoIP push token (a property of PKPushCredentials) with server
        #if DEBUG
        print("pushRegistrydidupdate")
        #endif
    }
    func pushRegistry(registry: PKPushRegistry!, didReceiveIncomingPushWithPayload payload: PKPushPayload!, forType type: String!) {
        // Process the received push
        #if DEBUG
            print("pushRegistryreceive")
        #endif
    }
    //testコード
    func openSession(addr:String)
    {
        let url=NSURL(string:"192.168.1.11:2000")
        print(addr)
        let request=URLRequest(url:url! as URL)
        let config=URLSessionConfiguration.default
        urlsession=URLSession(configuration:config)
        let task=urlsession.dataTask(with: request)
        task.resume()
        print(task)
        
    }

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.voipRegistration()
        // Override point for customization after application launch.
        //let interval:TimeInterval = 60*60// 1時間
        //UIApplication.shared.setMinimumBackgroundFetchInterval(interval)
        //UIApplication.shared.setKeepAliveTimeout(interval) {
            
        //}
        UIApplication.shared.setMinimumBackgroundFetchInterval(10)
        //let setting = UIUserNotificationSettings(types: [.sound, .alert], categories: nil)
        var center = UNUserNotificationCenter.current()
        /*center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            let setting=UNNotificationSetting(rawValue: 2)
            UIApplication.shared.registerUserNotificationSettings(setting)
            
        }*/
        center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
            if error != nil {
                return
            }
            
            if granted {
                #if DEBUG
                debugPrint("通知許可")
                    #endif
                let center = UNUserNotificationCenter.current()
                center.delegate = self as? UNUserNotificationCenterDelegate
            } else {
                #if DEBUG
                debugPrint("通知拒否")
                #endif
            }
        })
       let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch  {
            // エラー処理
            fatalError("カテゴリ設定失敗")
        }
        
        // sessionのアクティブ化
        do {
            try session.setActive(true)
        } catch {
            // audio session有効化失敗時の処理
            // (ここではエラーとして停止している）
            fatalError("session有効化失敗")
        }
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let directoryName = "icons"  // 作成するディレクトリ名
        let createPath = documentsPath + "/" + directoryName    // 作成するディレクトリ名を含んだフルパス
        #if DEBUG
            print(createPath)
            #endif
        
        do {
            try FileManager.default.createDirectory(atPath: createPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            // Faild to wite folder
        }
        let key = "iCloud.com.flipware.wiredline"
        let fileManager = FileManager.default
        if let currentiCloudToken = fileManager.ubiquityIdentityToken { // iCould にサインインしているか否か
            let newTokenData = NSKeyedArchiver.archivedData(withRootObject: currentiCloudToken)
            UserDefaults.standard.set(newTokenData, forKey: key)
            #if DEBUG
            print("currentiCloudToken = \(currentiCloudToken)")
            #endif
        }else{
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // iCloud の状態変化の通知
        NotificationCenter.default.addObserver(
            self,
            selector: Selector(("iCloudAccountAvailabilityChanged:")),
            name: NSNotification.Name.NSUbiquityIdentityDidChange,
            object: nil)
        
        // アプリケーションが iCloud にアクセスできるように準備
        DispatchQueue.main.async{
            let vStore = NSUbiquitousKeyValueStore.default
            if var icloudURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.flipware.wiredline") {
                #if DEBUG
                print("iCloud is available. \(icloudURL)")
                   #endif
                icloudURL=icloudURL.appendingPathComponent("Documents/icons")
                #if DEBUG
                    print("iCloud is available. \(icloudURL)")
                #endif
                do {
                    try FileManager.default.createDirectory(atPath: icloudURL.path, withIntermediateDirectories: true, attributes: nil)
                    vStore.synchronize()
                    
                } catch {
                    #if DEBUG
                    print("error createing folder")
                    #endif
                    // Faild to wite folder
                }
                // App can write to the iCloud container
            }else{
                #if DEBUG
                print("iCloud is not available.")
                #endif
            }
        }
        
        /*CKContainer.default().accountStatus { (accountStatus, error) in
            switch accountStatus {
            case .available:
                #if DEBUG
                print("iCloud Available")
                    #endif
            case .noAccount:
                #if DEBUG
                print("No iCloud account")
                    #endif
            case .restricted:
                #if DEBUG
                print("iCloud restricted")
                    #endif
            case .couldNotDetermine:
                #if DEBUG
                print("Unable to determine iCloud status")
                #endif
            }
        }*/

        
        return true
    }
    /*func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
    }*/
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        /*self.backgroundTaskID = application.beginBackgroundTask(){
            [weak self] in
            application.endBackgroundTask((self?.backgroundTaskID)!)
            self?.backgroundTaskID = UIBackgroundTaskInvalid
        }*/
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "applicationDidEnterBackground"), object: nil)
        pingtime=120
        if wiredflag==1{
            let wisend=WiredSend()
            wisend.sendWiredPing()
        }else if hlflag==1{
            let hlsend=HLSend()
            hlsend.sendhlping()
        }
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch  {
            // エラー処理
            fatalError("カテゴリ設定失敗")
        }
        
        // sessionのアクティブ化
        do {
            try session.setActive(true)
        } catch {
            // audio session有効化失敗時の処理
            // (ここではエラーとして停止している）
            fatalError("session有効化失敗")
        }
        let audioPath = NSURL(fileURLWithPath: Bundle.main.path(forResource:"silent", ofType: "m4a")!)
        if inputHLStream != nil{
        do {
            let sound = try AVAudioPlayer(contentsOf: audioPath as URL)
            #if DEBUG
            print("audio playing")
            #endif
            audioPlayer = sound
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            audioPlayer.numberOfLoops = -1
        } catch {
            // couldn't load file :(
            print("error loading mp3")
        }
        }
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "applicationWillEnterForeground"), object: nil)
        //let notification:UILocalNotification=UILocalNotification()
        //UIApplication.shared.cancelAllLocalNotifications()
        let center=UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        if (audioPlayer != nil) {
            
              audioPlayer.stop()
            #if DEBUG
                print("stop playing")
            #endif
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //application.endBackgroundTask(self.backgroundTaskID)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "applicationWillEnterForeground"), object: nil)
        //let notification:UILocalNotification=UILocalNotification()
        //UIApplication.shared.cancelLocalNotification(notification)
        //let notif:UILocalNotification=UILocalNotification()
        //UIApplication.shared.cancelLocalNotification(notif)
        let center=UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    @objc
    func HLOpenStream(_ addr:[String])
    {
        _=0
        var cfReadStream:Unmanaged<CFReadStream>?
        var cfWriteStream:Unmanaged<CFWriteStream>?
        var address:CFString
        let port:Int=(Int(addr[1]))!
        let objcm:objcmethod=objcmethod()
        hlflag=1
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var loop:RunLoop
        timer=Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(closeStream), userInfo: nil, repeats: false)
        address=addr[0] as CFString
        CFStreamCreatePairWithSocketToHost(nil, address as NSString, UInt32(port), &cfReadStream, &cfWriteStream)
        if((cfReadStream) != nil && (cfWriteStream) != nil ){
            timer.invalidate()
            //result=0
            #if DEBUG
            //print(0)
            #endif
        }else{
            #if DEBUG
            //print(10)
            #endif
            //return(1)
        }
        
        inputHLStream=cfReadStream!.takeRetainedValue() as InputStream!
        outputHLStream=cfWriteStream!.takeRetainedValue() as OutputStream!
        loop=RunLoop.current
        inputHLStream?.delegate = self
        outputHLStream?.delegate = self
        
        //inputHLStream.setProperty(StreamNetworkServiceTypeValue.voIP, forKey: Stream.PropertyKey.networkServiceType)
        //inputHLStream.setProperty(StreamNetworkServiceTypeValue.voIP, forKey: Stream.PropertyKey.networkServiceType)
        //outputHLStream.setProperty(StreamNetworkServiceTypeValue.voIP, forKey: Stream.PropertyKey.networkServiceType)
        inputHLStream?.schedule(in: .main, forMode: RunLoopMode.defaultRunLoopMode)
        outputHLStream?.schedule(in: .main, forMode: RunLoopMode.defaultRunLoopMode)
        //inputHLStream.setProperty(StreamNetworkServiceTypeValue.voIP, forKey: Stream.PropertyKey.networkServiceType)
        //outputHLStream.setProperty(StreamNetworkServiceTypeValue.voIP, forKey: Stream.PropertyKey.networkServiceType)
        objcm.setKeepAlive(outputHLStream)
        inputHLStream?.open()
        outputHLStream?.open()
        inputHLStream?.setProperty(StreamNetworkServiceTypeValue.voIP as AnyObject, forKey: Stream.PropertyKey.networkServiceType)
        outputHLStream?.setProperty(StreamNetworkServiceTypeValue.voIP as AnyObject, forKey: Stream.PropertyKey.networkServiceType)
        
        //let hlsend:HLSend=HLSend()
        //hlsend.sendHLInit()
        loop.run()
        //return(result)
        
    }
    
    func wireOpenStream(_ addr:[String])
    {
        let send:WiredSend=WiredSend()
        //var result=0
        var cfReadStream:Unmanaged<CFReadStream>?
        var cfWriteStream:Unmanaged<CFWriteStream>?
        var address:CFString
        let port:Int=Int(addr[1])!
        var property:NSDictionary//=NSDictionary()
        let objc:objcmethod=objcmethod()
        //let dic:NSDictionary=NSDictionary()
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var loop:RunLoop
        wiredflag=1
        timer=Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(closeStream), userInfo: nil, repeats: false)
        address=addr[0] as CFString
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, address as NSString, UInt32(port), &cfReadStream, &cfWriteStream)
        if(cfReadStream != nil || cfWriteStream != nil){
            timer.invalidate()
            //result=0
            //print(0)
        }else{
            //print(10)
            //return(1)
        }
        //inputHLStream=cfReadStream!.takeRetainedValue()
        //outputHLStream=cfWriteStream!.takeRetainedValue()
        inputHLStream=cfReadStream!.takeUnretainedValue()
        outputHLStream=cfWriteStream!.takeUnretainedValue()
        loop=RunLoop.current
        inputHLStream?.delegate = self
        outputHLStream?.delegate = self
        inputHLStream?.schedule(in: .main, forMode: RunLoopMode.defaultRunLoopMode)
        outputHLStream?.schedule(in: .main, forMode: RunLoopMode.defaultRunLoopMode)
        inputHLStream?.setProperty(StreamSocketSecurityLevel.tlSv1 as AnyObject, forKey: Stream.PropertyKey.socketSecurityLevelKey)
        outputHLStream?.setProperty(StreamSocketSecurityLevel.tlSv1 as AnyObject, forKey: Stream.PropertyKey.socketSecurityLevelKey)
        property=objc.setSSLProperty() as NSDictionary
        objc.setstreamproperty(inputHLStream,test: outputHLStream,dic: property as! [AnyHashable: Any])
        inputHLStream?.setProperty(StreamNetworkServiceTypeValue.voIP as AnyObject, forKey: Stream.PropertyKey.networkServiceType)
        outputHLStream?.setProperty(StreamNetworkServiceTypeValue.voIP as AnyObject, forKey: Stream.PropertyKey.networkServiceType)
        //objc.setKeepAlive(inputHLStream)
            //let errmsg = String.fromCString(strerror(errno))
            //println("setsockopt failed: \(errno) \(errmsg)")
        
        inputHLStream?.open()
        outputHLStream?.open()
        
        //sendNotification(SendWiredHelloCommand, dic:dic)
        send.sendHelloCommand()
        loop.run()

        //return(result)
    }
    func wireFileStream(_ addr:[String])
    {
        //let send:WiredSend=WiredSend()
        //var result=0
        var cfReadStream:Unmanaged<CFReadStream>?
        var cfWriteStream:Unmanaged<CFWriteStream>?
        var address:CFString
        let port:Int=Int(addr[1])!+1
        var property:NSDictionary//=NSDictionary()
        let objc:objcmethod=objcmethod()
        //let dic:NSDictionary=NSDictionary()
        print("port=",port)
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var loop:RunLoop
        wiredflag=1
        timer=Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(closeStream), userInfo: nil, repeats: false)
        address=addr[0] as CFString
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, address as NSString, UInt32(port), &cfReadStream, &cfWriteStream)
        if(cfReadStream != nil || cfWriteStream != nil){
            timer.invalidate()
            //result=0
            //print(0)
        }else{
            //print(10)
            //return(1)
        }
        //inputHLStream=cfReadStream!.takeRetainedValue()
        //outputHLStream=cfWriteStream!.takeRetainedValue()
        inputHLFileStream=cfReadStream!.takeUnretainedValue()
        outputHLFileStream=cfWriteStream!.takeUnretainedValue()
        loop=RunLoop.current
        inputHLFileStream?.delegate = self
        outputHLFileStream?.delegate = self
        inputHLFileStream?.schedule(in: .main, forMode: RunLoopMode.defaultRunLoopMode)
        outputHLFileStream?.schedule(in: .main, forMode: RunLoopMode.defaultRunLoopMode)
        inputHLFileStream?.setProperty(StreamSocketSecurityLevel.tlSv1 as AnyObject, forKey: Stream.PropertyKey.socketSecurityLevelKey)
        outputHLFileStream?.setProperty(StreamSocketSecurityLevel.tlSv1 as AnyObject, forKey: Stream.PropertyKey.socketSecurityLevelKey)
        property=objc.setSSLProperty() as NSDictionary
        objc.setstreamproperty(inputHLFileStream,test: outputHLFileStream,dic: property as! [AnyHashable: Any])
        inputHLFileStream?.setProperty(StreamNetworkServiceTypeValue.voIP as AnyObject, forKey: Stream.PropertyKey.networkServiceType)
        outputHLFileStream?.setProperty(StreamNetworkServiceTypeValue.voIP as AnyObject, forKey: Stream.PropertyKey.networkServiceType)
        //let errmsg = String.fromCString(strerror(errno))
        //println("setsockopt failed: \(errno) \(errmsg)")
        //objc.setKeepAlive(outputHLStream)
        inputHLFileStream?.open()
        outputHLFileStream?.open()
        //sendNotification(SendWiredHelloCommand, dic:dic)
        //send.sendHelloCommand()
        //outputCommandQueue = OutgoingCommandQueue(Stream: outputHLStream)
        loop.run()
        
        //return(result)
    }
    
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
    switch (eventCode){
        case Stream.Event.errorOccurred:
            #if DEBUG
                NSLog("ErrorOccurred")
            #endif
            self.closeStream()
            let nf=Notification(name: Notification.Name(rawValue: servernotalive), object: self,userInfo:nil)
            NotificationCenter.default.post(nf)
            
            
            break
        case Stream.Event.endEncountered:
            #if DEBUG
                NSLog("EndEncountered")
            #endif
            self.closeStream()
            
            break
        case Stream.Event():
            #if DEBUG
                NSLog("None")
            #endif
            break
        case Stream.Event.hasBytesAvailable:
            #if DEBUG
                NSLog("HasBytesAvaible")
            #endif
            let hloop:HLLoop=HLLoop()
            let wloop:wiredloop=wiredloop()
            var range:NSRange
            var datatofind:Data
            var buffer = [UInt8](repeating: 0, count: 1024*100)
            
            if ( aStream == inputHLStream || aStream==inputHLFileStream){
                while (inputHLStream!.hasBytesAvailable){
                    //println(sendinitflag)
                    var len:(Int)=0
                    if aStream==inputHLStream{
                        #if DEBUG
                        print("handling inputHLStream")
                        #endif
                        len = inputHLStream!.read(&buffer, maxLength: 1024*100 )
                    }else if aStream==inputHLFileStream{
                        #if DEBUG
                            print("handling inputHLFileStream")
                        #endif
                        len=(inputHLFileStream?.read(&buffer, maxLength: 1024*100))!
                    }
                    if(len > 0){
                        #if DEBUG
                        //let output = NSString(bytes: &buffer, length: 1024, encoding: String.Encoding.ascii.rawValue)
                            #endif
                        data.append(&buffer, length: len)
                        var bytesRead:Int=0
                        bytesRead+=len
                        if(hlflag==1){
                            if(sendintflag==1 && trtpflag==false){
                                datatofind=String(0xFF).data(using: String.Encoding(rawValue: encoding.rawValue))!
                                range=data.range(of: datatofind, options: NSData.SearchOptions.backwards , in: NSMakeRange(0, data.length))
                                hloop.hlloop(Data(bytes: UnsafePointer<UInt8>(buffer), count: len))
                                data=NSMutableData()
                            }else if(sendintflag==0 && trtpflag==true){
                                sendintflag=1
                                trtpflag=false
                                hloop.hlloopinit(Data(bytes: UnsafePointer<UInt8>(buffer), count: len))
                                data=NSMutableData()
                            }
                            #if DEBUG
                            //NSLog("server said: %@", output!)
                            #endif
                        }else if(wiredflag==1){
                            datatofind=String(term).data(using: String.Encoding.utf8)!
                            range=data.range(of: datatofind, options: NSData.SearchOptions.backwards , in: NSMakeRange(0, data.length))
                            
                            if(range.location == data.length-1 ){
                                wloop.wiredloop(data as Data)
                                wiloginflag=1
                                #if DEBUG
                                   // NSLog("server said: %@", data)
                                    //print("server said:",output)
                                #endif
                                data=NSMutableData()
                                bytesRead=0
                            }else{
                                //data.appendBytes(&buffer, length: len)
                            }
                        }
                }
            }
            }
            break
        case Stream.Event():
            #if DEBUG
                NSLog("allZeros")
            #endif
            break
        case Stream.Event.openCompleted:
            #if DEBUG
                NSLog("OpenCompleted")
            #endif
            let socketData = CFWriteStreamCopyProperty(outputHLStream!, CFStreamPropertyKey.socketNativeHandle) as! CFData
            let handle = CFSocketNativeHandle(CFDataGetBytePtr(socketData).pointee)
            var one: Int = 1
            let size = UInt32(MemoryLayout.size(ofValue: one))
            if setsockopt(handle, SOL_SOCKET, SO_KEEPALIVE, &one, size) == -1{
                #if DEBUG
                print("setsockopt failed")
                #endif
            }else{
                #if DEBUG
                print("setsockopt complete")
                #endif
            }
            let socketDatar = CFReadStreamCopyProperty(inputHLStream!, CFStreamPropertyKey.socketNativeHandle) as! CFData
            let handler = CFSocketNativeHandle(CFDataGetBytePtr(socketDatar).pointee)
            var oner: Int = 1
            var sizer = UInt32(MemoryLayout.size(ofValue: oner))
            if setsockopt(handler, SOL_SOCKET, SO_KEEPALIVE, &oner, sizer) == -1{
                #if DEBUG
                    print("setsockopt failed")
                #endif
            }else{
                #if DEBUG
                    print("setsockopt complete")
                #endif
            }
            var delay:Int=10
            sizer=UInt32(MemoryLayout.size(ofValue: delay))
            if setsockopt(handler,IPPROTO_TCP, TCP_KEEPALIVE, &delay, sizer) == -1{
                print("setsockopt error")
            }
            
            break
        case Stream.Event.hasSpaceAvailable:
            #if DEBUG
                NSLog("HasSpaceAvailable")
            #endif
            let hlsend:HLSend=HLSend()
            if sendintflag==0 && hlflag==1 && trtpflag==false {
                 hlsend.sendHLInit()
                trtpflag=true
                //println(outputHLStream)
                //sendintflag=1
                //sendinitflag=0
            }
            //sendinitflag=0*/
            /*
            let socketData = CFReadStreamCopyProperty(inputHLStream, kCFStreamPropertySocketNativeHandle) as! NSData
            var socket: CFSocketNativeHandle = 0
            socketData.getBytes(&socket, length: sizeofValue(socket))
            var on: UInt32 = 1;
            if setsockopt(socket, SOL_SOCKET, SO_KEEPALIVE, &on, socklen_t(sizeofValue(on))) == -1 {
                let errmsg = String.fromCString(strerror(errno))
                print("setsockopt failed: \(errno) \(errmsg)")
            }
*/
            break
        default:
            break
        }
    }
    @objc func closeStream()
    {
        #if DEBUG
            print("closeStream")
            #endif
        if outputHLStream != nil {
             sendintflag=0
             hlflag=0
             wiredflag=0
             outputHLStream?.close()
             inputHLStream?.close()
             inputHLStream?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
             outputHLStream?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
             let nf=Notification(name: Notification.Name(rawValue: buttontitle), object: self,userInfo:nil)
             NotificationCenter.default.post(nf)
             outputHLStream?.delegate=nil
             inputHLStream?.delegate=nil
        }
        //inputHLStream=cfReadStream!.takeUnretainedValue()
        ////outputHLStream=cfWriteStream!.takeUnretainedValue()
        //cfReadStream?.
        
        
    }
    func sendNotification(_ name:String,dic:NSDictionary)
    {
        let notif:Notification=Notification(name: Notification.Name(rawValue: name), object: self, userInfo: dic as? [AnyHashable: Any])
        NotificationCenter.default.post(notif)
    }
    
    /*func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        _ = message["Disconnect"] as? String
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) {
            self.closeStream()
        }
    }*/
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.flipware.coredata" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "favourite", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    //MARK: Pickerview
    
    
}

