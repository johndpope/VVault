//
//  DDBTableRow.swift
//  VVault
//
//  Created by Sean Zhang on 4/22/17.
//  Copyright © 2017 Sean Zhang. All rights reserved.
//

import Foundation
import AWSDynamoDB

class DDBTableRow: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    
    var UserId:String?
    var GameTitle:String?
    
    //set the default values of scores, wins and losses to 0
    var TopScore:NSNumber? = 0
    var Wins:NSNumber? = 0
    var Losses:NSNumber? = 0
    
    //should be ignored according to ignoreAttributes
    var internalName:String?
    var internalState:NSNumber?
    
    class func dynamoDBTableName() -> String {
        return AWSSampleDynamoDBTableName
    }
    
    class func hashKeyAttribute() -> String {
        return "UserId"
    }
    
    class func rangeKeyAttribute() -> String {
        return "GameTitle"
    }
    
    class func ignoreAttributes() -> [String] {
        return ["internalName", "internalState"]
        
    }
}
