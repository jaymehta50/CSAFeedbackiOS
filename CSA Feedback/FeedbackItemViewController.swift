//
//  FeedbackItemViewController.swift
//  CSA Feedback
//
//  Created by Jay Mehta on 14/07/2015.
//  Copyright (c) 2015 Jay Mehta. All rights reserved.
//

import UIKit

class FeedbackItemViewController: UIViewController, UITextViewDelegate {
    
    var event:[String : String]!
    
    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var sessionDesc: UILabel!
    @IBOutlet weak var sessionDateTime: UILabel!
    @IBOutlet weak var csresponse: UILabel!
    @IBOutlet weak var csresponsenametime: UILabel!
    
    @IBOutlet weak var scoreSlider: UISlider!
    @IBOutlet weak var scoreText: UILabel!
    @IBOutlet weak var cbresponse: UISwitch!
    @IBOutlet weak var notifyText: UILabel!
    @IBOutlet weak var textComment: UITextView!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    var score = 5
    var feedbackData:[String:String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textComment.delegate = self
        
        // Do any additional setup after loading the view.
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        sessionName.text = event["name"]!
        sessionDesc.text = event["desc"]!
        let str:NSString = event["starttime"]!
        let timeint = NSTimeInterval(str.doubleValue)
        let date = NSDate(timeIntervalSince1970: timeint)
        sessionDateTime.text = dateFormatter.stringFromDate(date)
        
        if(event["response_text"] != "") {
            csresponse.hidden = false
            csresponse.text = event["response_text"]!
            let respstr:NSString = event["response_time"]!
            let resptimeint = NSTimeInterval(respstr.doubleValue)
            let respdate = NSDate(timeIntervalSince1970: resptimeint)
            csresponsenametime.hidden = false
            csresponsenametime.text = event["response_name"]! + " - " + dateFormatter.stringFromDate(respdate)
        }
        
        var query = "SELECT score, comment FROM fd_feedback WHERE event_id = " + event["_id"]!
        var fdreturned = DBManager(databaseFilename: "feedback.sql").loadDataFromDB(query)
        
        if (fdreturned.count >= 1) {
            scoreSlider.hidden = true
            notifyText.hidden = true
            cbresponse.hidden = true
            textComment.hidden = false
            if let comment = fdreturned[0] as? [String: String] {
                if (comment["comment"] != "") {
                    textComment.text = comment["comment"]
                    textComment.editable = false
                    saveButtonOutlet.hidden = true
                    feedbackData = comment
                }
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
    
    
    @IBAction func saveButton(sender: UIButton) {
//        var insertquery = "INSERT INTO fd_feedback (event_id, score, timestamp, notify_responses, sync_status) VALUES ("
//        insertquery += event["_id"]! + ", "
//        insertquery += "\(score), "
//        insertquery += "strftime('%s','now'), "
//        if (cbresponse.selected) {
//            insertquery += "1, "
//        }
//        else {
//            insertquery += "0, "
//        }
//        insertquery += "0);"
//        DBManager(databaseFilename: "feedback.sql").executeQuery(insertquery)
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
