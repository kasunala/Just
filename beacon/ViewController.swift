//
//  ViewController.swift
//  beacon
//
//  Created by Kasun Alahakoon on 6/7/15.
//  Copyright (c) 2015 holosofts. All rights reserved.
//

import UIKit
import Parse
import CoreLocation


//Delegate and protocols need trainning
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,UINavigationControllerDelegate, CLLocationManagerDelegate {

    let locationmanager = CLLocationManager()
    
    @IBOutlet weak var messageTableView: UITableView!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var messageButton: UIButton!
    
    @IBOutlet weak var dockViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var counterLable: UILabel!
    var messageArray:[String] = [String]()
    
    
    @IBOutlet weak var messageOl: UIView!
    
    
    var local:String = ""
    var country:String = ""
    
    
    //Hide Staus bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    //Core location
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil
            {
            
                    
            }
            
            if placemarks.count > 0
            {
        
                let pm = placemarks[0] as! CLPlacemark
                self.displayLocationInfo(pm)
            
            }
    
        })
        
    }
    
    func displayLocationInfo(placemark: CLPlacemark)
    {
    
    
        self.locationmanager.stopUpdatingLocation()
        println(placemark.locality)
        println(placemark.postalCode)
        println(placemark.administrativeArea)
        println(placemark.country)
        local = placemark.locality
        country = placemark.country
    
    }
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("ERROR:" + error.localizedDescription)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        messageOl.hidden = true
        
        self.locationmanager.delegate = self
        self.locationmanager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationmanager.requestWhenInUseAuthorization()
        self.locationmanager.startUpdatingLocation()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        
        //Set self as a delegate for messageTextField
        
        self.messageTextField.delegate = self
        
        //Add tap gesture recognition for the table view
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableViewTapped")
        self.messageTableView.addGestureRecognizer(tapGesture)
        
        
        //Retrive messges
        
        self.retriveMessages()
        
    }
    
    
    @IBAction func sendButtonTapped(sender: UIButton) {
        
        //utc date

        
        self.messageArray.append(self.messageTextField.text)
        //Call end editing method for the text field
        self.messageTextField.endEditing(true)
        
        //Disable send button and text field
        self.messageTextField.enabled = false
        self.messageButton.enabled = false
        
        //Create PFObject
        var newMessageObject:PFObject = PFObject(className: "Message")
        newMessageObject["text"] = self.messageTextField.text
        //let d = CloudLayer()
        //d.Insert("Text", value: self.messageTextField.text,table:"Message")
        
        
        //Set textLocation DUMMY
        //var textLocation:PFObject = PFObject(className: "Message")
        newMessageObject["location"] = local + ", " + country
        //d.Insert("textLocation", value: local + ", " + country,table:"Message")
        //Set UTC time GMT
        
        let time = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let string = dateFormatter.stringFromDate(time)
        
        //var utcTime:PFObject = PFObject(className: "Message")
        newMessageObject["utcTime"] = string
        //d.Insert("utcTime", value: string,table:"Message")
        
        //Local Time
        
        let time2 = NSDate()
        let dateFormatter2 = NSDateFormatter()
        dateFormatter2.dateFormat = "dd/MM/yy HH:mm"
        let string1 = dateFormatter2.stringFromDate(time2)
        
        
        //var localTime:PFObject = PFObject(className: "Message")
        newMessageObject["localTime"] = string1
        //d.Insert("localTime", value: string1,table:"Message")
        
        
      
        newMessageObject.saveInBackgroundWithBlock { (success:Bool,error:NSError?) -> Void in
            if(success){
            //Message sent
              println("message sent")
            
            //Retrive inbox
             self.retriveMessages()
                
            }
            else{
            //error
              println("message failed")
            }

            
            //Dispatch to main thread
            dispatch_async(dispatch_get_main_queue()){
                //Enable stuff
                self.messageButton.enabled = true
                self.messageTextField.enabled = true
                self.messageTextField.text = ""
            
            }


        }
        
        messageOl.hidden = true

    }
    
    func retriveMessages(){
    
        var query:PFQuery = PFQuery(className: "Message")
        
        //Get Current posts - get messages within a miniute of time
        //GMT time
        
        let time = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let string = dateFormatter.stringFromDate(time)

        query.whereKey("utcTime", equalTo: string)
        
        
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?,error:NSError?) -> Void in
            //Clear messages array
            self.messageArray = [String]()
            //Loop through messages array
         if let objs = objects {
            for messageObject in objs{
                
                
                
                //Limit posts size to 100 within a minute
                
                if self.messageArray.count < 100 {

                 //Retrive text column value
                let messageText:String? = (messageObject as! PFObject)["text"] as? String
                 //if  not null populate message array
                
                //Created time stamp
                let textLocation:String? = (messageObject as! PFObject) ["location"] as? String
                
                
                if messageText != nil {
                    
                    
                    
                    self.messageArray.append(messageText! + "/n" + textLocation!)
                    
                    println(self.messageArray.last)
                        
                    
                    
                    }
                }
            }
            
        }
            //Dispatch to main thread
            dispatch_async(dispatch_get_main_queue()){
                
                self.messageTableView.reloadData()
                
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableViewTapped(){
    
        //let text field to end editing
        self.messageTextField.endEditing(true)
        
        
    }
    
    
    
   
    //MARK: textField Delegate methods
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        //perform an animation to grow the dock view
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            
            self.dockViewHeightConstraint.constant = 350
            self.view.layoutIfNeeded()
            
            
            }, completion: nil)
        return true

    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        //perform an animation to shrink the dock view
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            
            self.dockViewHeightConstraint.constant = 60
            self.view.layoutIfNeeded()
            
            
            }, completion: nil)
        return true

    
    }
    
    //MARK: tableView Delegate methods change
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Create, modify and return the cell
       
        //create cell / Define cell type sending or Receiving
        let cell = self.messageTableView.dequeueReusableCellWithIdentifier("messageCell2") as! UITableViewCell
        
        //modify / Optional type
        cell.textLabel?.text = self.messageArray[indexPath.row]
        
        
        
        //retern cell
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageArray.count
    }



    
    @IBAction func newMessage(sender: AnyObject) {
        
        messageOl.hidden = false
        
    }
    
}

