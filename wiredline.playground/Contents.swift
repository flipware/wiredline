import UIKit

//playgroundで実行する際に必要なだけ
import XCPlayground

//Construct url object via string
var url = NSURL(string: "192.168.1.11:2000")
let config = URLSessionConfiguration.default
let session = URLSession(configuration: config)
var req = URLRequest(url: url! as URL)

//NSURLSessionDownloadTask is retured from session.dataTaskWithRequest
var task = session.dataTask(with: req, completionHandler: {
    (data, resp, err) in
    //print(resp?.URL! ?? <#default value#> )
    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) ?? "ああ")
})
task.resume()

//playgroundで実行する際に必要なだけ
//XCPSetExecutionShouldContinueIndefinitely()
