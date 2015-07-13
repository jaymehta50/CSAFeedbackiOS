//
//  SyncManager.swift
//  CSA Feedback
//
//  Created by Jay Mehta on 12/07/2015.
//  Copyright (c) 2015 Jay Mehta. All rights reserved.
//

import UIKit

class SyncManager: NSObject {
    
    func doPost(url:String, values:[String : String], postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var postString = ""
        var first = true
        
        for (key, value) in values {
            if(!first) { postString += "&" }
            postString += key + "=" + value
            first = false
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                postCompleted(succeeded: false, msg: error.description)
                return
            }
            
            println("response = \(response)")
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            postCompleted(succeeded: true, msg: responseString! as String)
        }
        task.resume()
    }
    
    func syncup() {
        var query = "SELECT event_id, score, comment, timestamp, notify_responses FROM fd_feedback WHERE sync_status = 0"
        var arrData = DBManager(databaseFilename: "feedback.sql").loadDataFromDB(query)
        
        if (arrData.count == 0) {return}
        let postData = ["authtoken": "abc", "fd_data": ""]
    }
   
}
