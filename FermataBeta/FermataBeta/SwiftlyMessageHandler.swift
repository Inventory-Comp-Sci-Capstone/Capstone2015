/*
The MIT License (MIT)

Copyright (c) 2015 Lee Barney

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

//Kyle modified this code 

import Foundation

import WebKit

class SwiftlyMessageHandler:NSObject, WKScriptMessageHandler{
    var appWebView:WKWebView?
    
    var testStr = "0"
    
    
    init(theController:SongViewController){
        super.init()
        let theConfiguration = WKWebViewConfiguration()
        
        theConfiguration.userContentController.addScriptMessageHandler(self, name: "native")
        print("hiii")
        
        let rect = CGRect(
            origin: CGPoint(x: 0, y: 40),
            size: UIScreen.mainScreen().bounds.size)
        
        let indexHTMLPath = NSBundle.mainBundle().pathForResource("index", ofType: "html")
        appWebView = WKWebView(frame: rect, configuration: theConfiguration)
        let url = NSURL(fileURLWithPath: indexHTMLPath!)
        let request = NSURLRequest(URL: url)
        appWebView!.loadRequest(request)
        theController.view.addSubview(appWebView!)
    }
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        print("hello")
        let sentData = message.body as! NSDictionary
        
        var response = Dictionary<String,AnyObject>()
        
        let callbackString = sentData["callbackFunc"] as? String
        sendResponse(response, callback: callbackString)
    }
    func sendResponse(aResponse:Dictionary<String,AnyObject>, callback:String?){
        guard let callbackString = callback else{
            return
        }
        guard let generatedJSONData = try? NSJSONSerialization.dataWithJSONObject(aResponse, options: NSJSONWritingOptions(rawValue: 0)) else{
            print("failed to generate JSON for \(aResponse)")
            return
        }
        appWebView!.evaluateJavaScript("(\(callbackString)('\(NSString(data:generatedJSONData, encoding:NSUTF8StringEncoding)!)'))")
            {
                (JSReturnValue:AnyObject?, error:NSError?) in
                if let errorDescription = error?.description{
                    print("returned value: \(errorDescription)")
                }
                else if JSReturnValue != nil{
                    print("returned value: \(JSReturnValue!)")
                }
                else{
                    print("no return from JS")
                }
        }
        appWebView!.evaluateJavaScript("createSheetMusic('FLUTE')", completionHandler: nil  )
        print("exit")
        testStr = "1"
        
    }
    
}
