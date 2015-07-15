//
//  SyncManager.swift
//  CSA Feedback
//
//  Created by Jay Mehta on 12/07/2015.
//  Copyright (c) 2015 Jay Mehta. All rights reserved.
//

import UIKit

class SyncManager: NSObject {
    
    var dbm:DBManager
    var returnString = ""
    let hours:Double = 24
    
    override init() {
        dbm = DBManager(databaseFilename: "feedback.sql")
    }
    
    func doPost(url:String, values:[String : String], postCompleted : (succeeded: Bool, msg: NSData?) -> ()) {
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
                println(error.localizedDescription)
                postCompleted(succeeded: false, msg: nil)
                return
            }
            
            //let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            postCompleted(succeeded: true, msg: data)
        }
        task.resume()
    }
    
    func overall_sync(full:Bool, authtoken:String) {
        if(full) {
            if (!valid_user(authtoken)) {
                return
            }
        }
        syncup(authtoken)
        syncdown(authtoken)
    }
    
    func valid_user(authtoken:String) -> Bool {
        let urlvaliduser = "http://jkm50.user.srcf.net/feedback/post/index.php"
        var toreturn = false
        doPost(urlvaliduser, values: ["authtoken":authtoken]) { (succeeded: Bool, msg: NSData?) -> () in
            var respStr = NSString(data: msg!, encoding: NSUTF8StringEncoding)!
            
            if(respStr != "valid_user") {
                let invalidquery = "UPDATE userinfo SET valid = 0 WHERE valid = 1;"
                self.dbm.executeQuery(invalidquery)
                toreturn = false
                return
            }
            toreturn = true
        }
        return toreturn
    }
    
    func syncup(authtoken: String) {
        println("Run sync up")
        let urlsyncup = "http://jkm50.user.srcf.net/feedback/post/index.php/welcome/sync_up"
        let query = "SELECT event_id, score, comment, timestamp, notify_responses FROM fd_feedback WHERE sync_status = 0"
        
        let arrData = dbm.loadDataFromDB(query)
        
        if (arrData.count == 0) {return}
        
        var newArrData:NSMutableArray = []
        for item in arrData {
            if let temp = item as? NSMutableDictionary {
                var temp2 = temp
                temp2["comment"] = (temp["comment"] as! String).stringByReplacingOccurrencesOfString("''", withString: "'")
                newArrData.addObject(temp2)
            }
            else {
                newArrData.addObject(item)
            }
        }
        
        var err: NSError?
        let jsondata = NSJSONSerialization.dataWithJSONObject(newArrData, options: nil, error: &err)
        if (err != nil) {
            println(err?.localizedDescription)
            return
        }
        let jsonstring = NSString(data: jsondata!, encoding: NSUTF8StringEncoding)
        
        let postData = ["authtoken": authtoken, "fd_data": jsonstring! as String]
        
        self.doPost(urlsyncup, values: postData) { (succeeded: Bool, msg: NSData?) -> () in
            if(succeeded) {
                if let value = arrData as? [[String: String]] {
                    var updatequery = "UPDATE fd_feedback SET sync_status = 1 WHERE event_id = "
                    for(var i=0; i<arrData.count; i++) {
                        self.dbm.executeQuery(updatequery + value[i]["event_id"]! + ";")
                    }
                }
            }
        }
    }
    
    func syncdown(authtoken: String) {
        println("Run sync down")
        let urlsyncdown = "http://jkm50.user.srcf.net/feedback/post/index.php/welcome/sync_down"
        doPost(urlsyncdown, values: ["authtoken":authtoken]) { (succeeded: Bool, msg: NSData?) -> () in
            if(succeeded) {
                var err:NSErrorPointer = nil
                let parseJSON: AnyObject? = NSJSONSerialization.JSONObjectWithData(msg!, options: NSJSONReadingOptions.AllowFragments, error: err)
                
                if let JSONArray = parseJSON as? NSArray {
                    if let eventsArray = JSONArray[0] as? NSArray {
                        var first = true
                        for event in eventsArray {
                            if let value = event as? [String:AnyObject] {
                                
                                if (first) {
                                    let deletequery = "DELETE FROM fd_events;"
                                    self.dbm.executeQuery(deletequery)
                                }
                                
                                var insertquery = "INSERT INTO fd_events (_id, name, desc, starttime, endtime, responsible_person, response_user, response_name, response_text, response_time) VALUES ("
                                
                                insertquery += value["_ID"]! as! String + ", "
                                
                                insertquery += "'" + value["name"]!.stringByReplacingOccurrencesOfString("'", withString: "''") + "', "
                                
                                if let jsonstr = value["desc"] as? String {
                                    insertquery += "'" + jsonstr.stringByReplacingOccurrencesOfString("'", withString: "''") + "', "
                                }
                                else {
                                    insertquery += "'', "
                                }
                                
                                insertquery += value["starttime"]! as! String + ", "
                                
                                insertquery += value["endtime"]! as! String + ", "
                                
                                if let jsonstr = value["responsible_person"] as? String {
                                    insertquery += "'" + jsonstr.stringByReplacingOccurrencesOfString("'", withString: "''") + "', "
                                }
                                else {
                                    insertquery += "'', "
                                }
                                
                                if let jsonstr = value["response_user"] as? String {
                                    insertquery += "'" + jsonstr.stringByReplacingOccurrencesOfString("'", withString: "''") + "', "
                                }
                                else {
                                    insertquery += "'', "
                                }
                                
                                if let jsonstr = value["response_name"] as? String {
                                    insertquery += "'" + jsonstr.stringByReplacingOccurrencesOfString("'", withString: "''") + "', "
                                }
                                else {
                                    insertquery += "'', "
                                }
                                
                                if let jsonstr = value["response_text"] as? String {
                                    insertquery += "'" + jsonstr.stringByReplacingOccurrencesOfString("'", withString: "''") + "', "
                                }
                                else {
                                    insertquery += "'', "
                                }
                                
                                if let jsonstr = value["response_time"] as? String {
                                    insertquery += jsonstr.stringByReplacingOccurrencesOfString("'", withString: "''") + ");"
                                }
                                else {
                                    insertquery += "'');"
                                }
                                
                                self.dbm.executeQuery(insertquery)
                                first = false
                            }
                            else {
                                println("Hmm...for events")
                                println(event)
                            }
                        }
                    }
                    if let feedbackArray = JSONArray[1] as? NSArray {
                        var first = true
                        for feedback in feedbackArray {
                            if let value = feedback as? [String:AnyObject] {
                                
                                if (first) {
                                    let deletequery = "DELETE FROM fd_feedback WHERE sync_status = 1;"
                                    self.dbm.executeQuery(deletequery)
                                }
                                
                                var insertquery = "INSERT INTO fd_feedback (event_id, score, comment, timestamp, notify_responses, sync_status) VALUES ("
                                
                                insertquery += value["event_id"]! as! String + ", "
                                insertquery += value["score"]! as! String + ", "
                                
                                if let jsonstr = value["comment"] as? String {
                                    insertquery += "'" + jsonstr.stringByReplacingOccurrencesOfString("'", withString: "''") + "', "
                                }
                                else {
                                    insertquery += "'', "
                                }
                                
                                insertquery += value["timestamp"]! as! String + ", "
                                insertquery += value["notify_responses"]! as! String + ", "
                                insertquery += "1);"
                                
                                self.dbm.executeQuery(insertquery)
                                first = false
                            }
                            else {
                                println("Hmm...for feedback")
                                println(feedback)
                            }
                        }
                    }
                }
                else {
                    println(err.debugDescription)
                    var respStr = NSString(data: msg!, encoding: NSUTF8StringEncoding)!
                    println("ERROR - Resp String:")
                    println(respStr)
                }
            }
        }
    }
   
}
