//
//  FeedbackItemViewController.swift
//  CSA Feedback
//
//  Created by Jay Mehta on 14/07/2015.
//  Copyright (c) 2015 Jay Mehta. All rights reserved.
//

import UIKit

class FeedbackItemViewController: UIViewController {
    
    var event:[String : String]!
    
    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var sessionDesc: UILabel!
    @IBOutlet weak var sessionDateTime: UILabel!
    @IBOutlet weak var scoreText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        sessionName.text = event["name"]
        sessionDesc.text = event["desc"]
        let str:NSString = event["starttime"]!
        let timeint = NSTimeInterval(str.doubleValue)
        let date = NSDate(timeIntervalSince1970: timeint)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        sessionDateTime.text = dateFormatter.stringFromDate(date)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func scoreSlider(sender: UISlider) {
        var newscore = roundf(sender.value)
        sender.value = newscore
        scoreText.text = "\(Int(newscore))"
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
