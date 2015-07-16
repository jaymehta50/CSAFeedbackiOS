//
//  LoginViewController.swift
//  CSA Feedback
//
//  Created by Jay Mehta on 15/07/2015.
//  Copyright (c) 2015 Jay Mehta. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webViewLoading: UIActivityIndicatorView!
    @IBOutlet weak var webviewlogin: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webviewlogin.delegate = self
        
        webviewlogin.loadRequest(NSURLRequest(URL: NSURL(string: "http://jkm50.user.srcf.net/feedback/login/index.php/welcome/index/Fuzw2lg1GCyw2ZfH1jN8F1IMPszq4f69")!))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        webViewLoading.hidden = false
        webViewLoading.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webViewLoading.stopAnimating()
        webViewLoading.hidden = true
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        var url = request.URL
        println(url)
        if(url!.scheme == "closeWebView") {
            var params = url!.absoluteString!
            var params2 = params
            println(params)
            var range = params.rangeOfString("(?<=crsid=)[^&]+(?=&)", options:.RegularExpressionSearch)
            var crsid:String
            var authtoken:String
            if range != nil {
                crsid = params.substringWithRange(range!)
                println("crsid: \(crsid)") // found: google
                
                range = params2.rangeOfString("(?<=authtoken=)([^&]*)$", options:.RegularExpressionSearch)
                if range != nil {
                    authtoken = params2.substringWithRange(range!)
                    println("authtoken: \(authtoken)") // found: google
                    
                    var insertquery = "INSERT INTO userinfo (crsid, authtoken, timestamp, valid) VALUES ("
                    insertquery += "'" + crsid + "', "
                    insertquery += "'" + authtoken + "', "
                    insertquery += "strftime('%s','now'), "
                    insertquery += "1);"
                    println(insertquery)
                    DBManager(databaseFilename: "feedback.sql").executeQuery(insertquery)
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                    return false
                }
            }
        }
        return true
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
