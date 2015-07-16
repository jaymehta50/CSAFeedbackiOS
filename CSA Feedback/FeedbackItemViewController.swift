//
//  FeedbackItemViewController.swift
//  CSA Feedback
//
//  Created by Jay Mehta on 14/07/2015.
//  Copyright (c) 2015 Jay Mehta. All rights reserved.
//

import UIKit

class FeedbackItemViewController: UIViewController, UITextViewDelegate, UIScrollViewDelegate {
    
    var event:[String : String]!
    var authtoken:String!
    
    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var sessionDesc: UILabel!
    @IBOutlet weak var sessionDateTime: UILabel!
    @IBOutlet weak var csresponse: UILabel!
    @IBOutlet weak var csresponsenametime: UILabel!
    
    @IBOutlet var overallView: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var response_container: UIView!
    @IBOutlet weak var scoreSlider: UISlider!
    @IBOutlet weak var scoreText: UILabel!
    @IBOutlet weak var cbresponse: UISwitch!
    @IBOutlet weak var notifyText: UILabel!
    @IBOutlet weak var textComment: UITextView!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    var score = 5
    var feedbackData:[String:String]!
    var fdreturned:NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var leftConstraint:NSLayoutConstraint = NSLayoutConstraint(item: container, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: overallView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0)
        
        var rightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: container, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: overallView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0)
        
        overallView.addConstraint(leftConstraint)
        overallView.addConstraint(rightConstraint)
        
        var authquery = "SELECT authtoken FROM userinfo WHERE valid = 1"
        var authData = DBManager(databaseFilename: "feedback.sql").loadDataFromDB(authquery) as! [[String:String]]
        println(authData)
        if(authData.count == 0) {
            println("Redirecting")
            var vc: UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("loginNavView")! as! UINavigationController
            presentViewController(vc, animated: true, completion: nil)
            return
        }
        authtoken = authData[0]["authtoken"]!
        
        textComment.delegate = self
        
        // Do any additional setup after loading the view.
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        sessionName.text = event["name"]!.stringByReplacingOccurrencesOfString("''", withString: "'")
        sessionDesc.text = event["desc"]!.stringByReplacingOccurrencesOfString("''", withString: "'")
        let str:NSString = event["starttime"]!
        let timeint = NSTimeInterval(str.doubleValue)
        let date = NSDate(timeIntervalSince1970: timeint)
        sessionDateTime.text = dateFormatter.stringFromDate(date)
        
        if(event["response_text"] != "") {
            response_container.hidden = false
            csresponse.hidden = false
            csresponse.text = event["response_text"]!.stringByReplacingOccurrencesOfString("''", withString: "'")
            let respstr:NSString = event["response_time"]!
            let resptimeint = NSTimeInterval(respstr.doubleValue)
            let respdate = NSDate(timeIntervalSince1970: resptimeint)
            csresponsenametime.hidden = false
            csresponsenametime.text = event["response_name"]!.stringByReplacingOccurrencesOfString("''", withString: "'") + " - " + dateFormatter.stringFromDate(respdate)
        }
        
        var query = "SELECT score, comment FROM fd_feedback WHERE event_id = " + event["_id"]!
        fdreturned = NSMutableArray(array: DBManager(databaseFilename: "feedback.sql").loadDataFromDB(query) as! [[String: String]]!)
        
        doUIFormatting()
    }
    
//    @IBOutlet weak var scoreSliderHeight: NSLayoutConstraint!
//    @IBOutlet weak var consUnderSlider: NSLayoutConstraint!
//    @IBOutlet weak var constAboveSlider: NSLayoutConstraint!
    func doUIFormatting() {
        if (fdreturned.count >= 1) {
            scoreText.text = (fdreturned[0]["score"]! as! String)
            scoreSlider.hidden = true
//            scoreSliderHeight.constant = 0
//            constAboveSlider.constant = 0
//            consUnderSlider.constant = 0
            notifyText.hidden = true
            cbresponse.hidden = true
            textComment.hidden = false
            if ((fdreturned[0]["comment"]! as! String) != "") {
                textComment.text = (fdreturned[0]["comment"] as! String).stringByReplacingOccurrencesOfString("''", withString: "'")
                textComment.editable = false
                saveButtonOutlet.hidden = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(textView: UITextView) { //Handle the text changes here
        if (textView.text == "Type your comment here...") {
            textView.text = ""
        }
    }

    @IBAction func scoreSlider(sender: UISlider) {
        var newscore = roundf(sender.value)
        sender.value = newscore
        score = Int(newscore)
        scoreText.text = "\(score)"
    }
    
    @IBAction func saveButtonAction(sender: UIButton) {
        if (textComment.hidden) {
            var insertquery = "INSERT INTO fd_feedback (event_id, score, timestamp, notify_responses, sync_status) VALUES ("
            insertquery += event["_id"]! + ", "
            insertquery += "\(score), "
            insertquery += "strftime('%s','now'), "
            if (cbresponse.on) {
                insertquery += "1, "
            }
            else {
                insertquery += "0, "
            }
            insertquery += "0);"
            println(insertquery)
            DBManager(databaseFilename: "feedback.sql").executeQuery(insertquery)
            fdreturned.addObject(["score":"\(score)", "comment":""])
        }
        else {
            var updatequery = "UPDATE fd_feedback SET sync_status=0, comment='"
            updatequery += textComment.text.stringByReplacingOccurrencesOfString("'", withString: "''") + "' "
            updatequery += " WHERE event_id=" + event["_id"]! + ";"
            println(updatequery)
            fdreturned.removeAllObjects()
            fdreturned.addObject(["score":"\(score)", "comment":textComment.text])
            
            DBManager(databaseFilename: "feedback.sql").executeQuery(updatequery)
        }
        doUIFormatting()
        SyncManager().syncup(authtoken)
        SyncManager().syncdown(authtoken)
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
