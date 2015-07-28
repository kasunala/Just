//
//  CloudLayer.swift
//  beacon
//
//  Created by Kasun Alahakoon on 7/28/15.
//  Copyright (c) 2015 holosofts. All rights reserved.
//

import Foundation
import Parse

class CloudLayer {
    
    
    var locald:String = ""
    
    
    func Insert(key :String,value : String,table : String) 
    {
        
        //Parse code
        
        var newMessageObject:PFObject = PFObject(className: table)
        
        newMessageObject[key] = value
        
        
        newMessageObject.saveInBackgroundWithBlock { (success:Bool,error:NSError?) -> Void in
            if(success){
                //Message sent
                println("message sent")
                
                //Retrive inbox
               
                
            }
            else{
                //error
                println("message failed")
            }

        }
        

    }
    

    
    
    /*

    //Create PFObject
    var newMessageObject:PFObject = PFObject(className: "Message")
    newMessageObject["Text"] = self.messageTextField.text
    
    
    
    
    //PF Query
    var query:PFQuery = PFQuery(className: "Message")


    query.whereKey("playerName", notEqualTo: "Michael Yabuti")
    query.whereKey("playerAge", greaterThan: 18)
    

    query.limit = 10









*/

}
