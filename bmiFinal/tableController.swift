//
//  tableController.swift
//  bmi
//
//  Created by Emmanuel Etti on 2016-03-18.
//  Copyright © 2016 Emmanuel Etti. All rights reserved.
//

import UIKit
import Social

class tableController: UITableViewController{
    var tableName = [String]()
    var tableID = [String]()
    let record_key : String = "bmiArray"
    
    //    var detailViewController: ViewController? = nil
    let defaults = NSUserDefaults.standardUserDefaults() //set defaults ? localStorage
    var objects = [[String: String]]()
    var objects1 = [[String: String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
//        self.view.backgroundColor = UIColor.whiteColor()
        let add:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addBmi")
//        let chart:UIBarButtonItem = UIBarButtonItem(title: "chart", style: .Plain, target: self, action: "showChart")
        let share:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "share")
        
        navigationItem.rightBarButtonItems = [share,add]
        getData()
        //        tableView.reloadData()
    }
    
    
    func getData(){
        let myElement = defaults.objectForKey(record_key) as? [[String:Float]] ?? [[String:Float]]()
        if myElement.count > 0 {
            for (key) in myElement {
                let bmi = String(key["bmi"]!)
                let weight  = String(key["weight"]!)
                let height  = String(key["height"]!)
                let obj   = ["bmi": bmi,"weight": weight, "height": height]
                objects.append(obj)
            }
            print(objects)
        }
         tableView.reloadData()
    }
    
    func showError(msg: String) {
        //if(msg == "status"){
        
        //}else
        let ac = UIAlertController(title: "Data Error", message: msg, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func addBmi(){
        let ac = UIAlertController(title: "Enter Height and Weight", message: nil, preferredStyle: .Alert)
        
        var tableData = [String:String]()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            (_) in
        }
        
        let submitAction  = UIAlertAction(title: "Submit", style: .Default) {
            [unowned self, ac] (action: UIAlertAction) in
            
            if let _ = Float(ac.textFields![0].text!){
                if let _ = Float(ac.textFields![0].text!){
                    let weight = Float(ac.textFields![0].text!)!
                    let height = Float(ac.textFields![1].text!)!
                    //calculate bmi
                    
                    let bmi = weight/(height*height)
                    //new array
                    let newArray = ["bmi":bmi, "height":height, "weight": weight]
                    tableData = ["bmi":String(bmi), "height":String(height), "weight": String(weight)]
                    
                    //retrieve old storage
                    var oldData  = self.defaults.objectForKey(self.record_key) as? [[String:Float]] ?? [[String:Float]]()
                    
                    //append data to old storage
                    oldData.insert(newArray, atIndex: 0)
                    
                    //save data to local storage
                    self.defaults.setObject(oldData, forKey: self.record_key)
                    
                    //retrieve data from local storage
                    let myElement = self.defaults.objectForKey(self.record_key) as? [[String:Float]] ?? [[String:Float]]()
                    
                    //not in use
                    //functionality: Format's text into tabular data
                    let tabs = "\t\t\t"
                    var text = "Weight\(tabs)Height\(tabs)Bmi "
                    for (key) in myElement {
                        text+=String(format: "\n%5.2f\(tabs)%5.2f\(tabs)%5.2f",
                            arguments: [key["weight"]!,key["height"]!,key["bmi"]!])
                    }
                    self.objects.insert(tableData, atIndex: 0)
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

                }else{
                    self.showError("You entered an inappopriate data type\n Your data was not stored")
                }
            }else{
                self.showError("You entered and inappopriate data type\n Your data was not stored")
            }
            
        } //end SubmitAction
        submitAction.enabled = false
        
        ac.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.keyboardType = UIKeyboardType.DecimalPad
            textField.placeholder = "Mass (kg)"
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                if let _ = Float(textField.text!){
                    submitAction.enabled = textField.text != ""
                }else{
                    submitAction.enabled = false
                }
            }
        }
        
        
        ac.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.keyboardType = UIKeyboardType.DecimalPad
            textField.placeholder = "height(m)"
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                if let _ = Float(textField.text!){
                submitAction.enabled = textField.text != ""
                }else{
                    submitAction.enabled = false
                }
            }
        }

        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        ac.dismissViewControllerAnimated(true, completion: nil)
        presentViewController(ac, animated: true, completion: nil )
    }
    
    func share(){
        let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        let myElement = self.defaults.objectForKey(record_key) as? [[String:Float]] ?? [[String:Float]]()
        
        vc.setInitialText("Hey guys, my current BMI is: \(myElement.first!["bmi"]!)")
        let url:String = "http://www.facebook.com"
        let newurl = NSURL(string: url)
        vc.addURL(newurl)
        presentViewController(vc, animated: true, completion: nil)
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let object = self.objects[indexPath.row]
        cell.textLabel!.text = "BMI: \(object["bmi"]!)"
        cell.detailTextLabel!.text = "Height: \(object["height"]!) Weight: \(object["weight"]!)"
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            var oldData  = self.defaults.objectForKey(self.record_key) as? [[String:Float]] ?? [[String:Float]]()
            oldData.removeAtIndex(indexPath.row)
            //save data to local storage
            self.defaults.setObject(oldData, forKey: self.record_key)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
}