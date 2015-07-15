//
//  TableEventsTableViewController.swift
//  CSA Feedback
//
//  Created by Jay Mehta on 11/07/2015.
//  Copyright (c) 2015 Jay Mehta. All rights reserved.
//

import UIKit


class TableEventsTableViewController: UITableViewController {
    
    var arrData:NSArray = []
    var authtoken = "javMj36V4GZpCfRpYqQBTgtgSUhehi2i58Nvl7qr7f2bTodP3kTESaJD9YaKnO9MNPs5UUcSth0jON6YHWuZevoVwwFlW1DtbxIomWsLDEsIeJM4CdkAXKHxqzKy8m6G"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        var query = "SELECT _id, name, starttime, desc, response_name, response_text, response_time FROM fd_events WHERE starttime <= strftime('%s','now') ORDER BY starttime DESC"
        
        arrData = DBManager(databaseFilename: "feedback.sql").loadDataFromDB(query)
        println(arrData)
        
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        
        println(SyncManager().valid_user(authtoken))
    }
    
    func refresh(sender:AnyObject) {
        SyncManager().syncup(authtoken)
        SyncManager().syncdown(authtoken)
        refreshControl!.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return arrData.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCellRecord", forIndexPath: indexPath) as UITableViewCell

        let row = indexPath.row
        if let namevalue = arrData[row]["name"] as? String {
            cell.textLabel?.text = namevalue
        }
        println(arrData[row])
        if let timevalue = arrData[row]["starttime"] as? NSString {
            println("Yes!")
            let timeint = NSTimeInterval(timevalue.doubleValue)
            let date = NSDate(timeIntervalSince1970: timeint)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            cell.detailTextLabel?.text = dateFormatter.stringFromDate(date)
        }
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.tintColor = UIColor.grayColor()
        if let resp_user = arrData[row]["response_text"] as? String {
            if (resp_user != "") {
                cell.tintColor = UIColor.blueColor()
                cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
            }
            else if let fdid = arrData[row]["_id"] as? String {
                var query = "SELECT _id FROM fd_feedback WHERE event_id = " + fdid
                var fdreturned = DBManager(databaseFilename: "feedback.sql").loadDataFromDB(query)
                if (fdreturned.count >= 1) {
                    cell.tintColor = UIColor.greenColor()
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
            }
        }
        

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showFeedback" {
            let FeedbackItemDetailViewController = segue.destinationViewController as FeedbackItemViewController
            
            // Get the cell that generated this segue.
            if let selectedEventCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(selectedEventCell)!
                if let selectedEvent = arrData[indexPath.row] as? [String: String] {
                    FeedbackItemDetailViewController.event = selectedEvent
                }
            }
        }
    }
    

}
