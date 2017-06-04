//
//  Document.swift
//  VVault
//
//  Created by Sean Zhang on 4/20/17.
//  Copyright © 2017 Sean Zhang. All rights reserved.
//

import Foundation
import AWSDynamoDB

class Document: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    
    var title: String? = "V17501-EMNB-0002"
    var detail: String? = "Vibration Analysis"
    var code: String? = "EM"
    var type: String? = "NB"
    var revision: String? = "1"
    
    /**
     Returns the Amazon DynamoDB table name.
     
     @return A table name.
     */
    public static func dynamoDBTableName() -> String {
        
        
        return "DCAP"
    }
    
    
    /**
     Returns the hash key attribute name.
     
     @return A hash key attribute name.
     */
    public static func hashKeyAttribute() -> String {
        
        return "DocumentID"
    }
    
    
}
