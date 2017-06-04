//
//  DDBDynamoDBManger.swift
//  VVault
//
//  Created by Sean Zhang on 4/20/17.
//  Copyright © 2017 Sean Zhang. All rights reserved.
//

import Foundation
import AWSCore
import AWSDynamoDB

let AWSSampleDynamoDBTableName = "DynamoDB-OM-SwiftSample"

class DDBDynamoDBManager: NSObject {
    
    class func describeTable() -> AWSTask<AnyObject> {
        let dynamoDB = AWSDynamoDB.default()
        
        // See if the test table exists.
        let describeTableInput = AWSDynamoDBDescribeTableInput()
        describeTableInput?.tableName = AWSSampleDynamoDBTableName
        return dynamoDB.describeTable(describeTableInput!) as! AWSTask<AnyObject>
    }
    
    // createTable() method creates an table by setting AWSDynamoDBCreateTableInput with the tableName, attribute Definitations, key schema,
    // you need to read through the documentation and understand this AWSDynamoDBCreateTableInput class and its settings in order to create a 
    // User table such as online chat app.
    class func createTable() -> AWSTask<AnyObject> {
        let dynamoDB = AWSDynamoDB.default()
        
        //Create the test table
        let hashKeyAttributeDefinition = AWSDynamoDBAttributeDefinition()
        hashKeyAttributeDefinition?.attributeName = "UserId"
        hashKeyAttributeDefinition?.attributeType = AWSDynamoDBScalarAttributeType.S
        
        let hashKeySchemaElement = AWSDynamoDBKeySchemaElement()
        hashKeySchemaElement?.attributeName = "UserId"
        hashKeySchemaElement?.keyType = AWSDynamoDBKeyType.hash
        
        let rangeKeyAttributeDefinition = AWSDynamoDBAttributeDefinition()
        rangeKeyAttributeDefinition?.attributeName = "GameTitle"
        rangeKeyAttributeDefinition?.attributeType = AWSDynamoDBScalarAttributeType.S
        
        let rangeKeySchemaElement = AWSDynamoDBKeySchemaElement()
        rangeKeySchemaElement?.attributeName = "GameTitle"
        rangeKeySchemaElement?.keyType = AWSDynamoDBKeyType.range
        
        //Add non-key attributes
        let topScoreAttrDef = AWSDynamoDBAttributeDefinition()
        topScoreAttrDef?.attributeName = "TopScore"
        topScoreAttrDef?.attributeType = AWSDynamoDBScalarAttributeType.N
        
        let winsAttrDef = AWSDynamoDBAttributeDefinition()
        winsAttrDef?.attributeName = "Wins"
        winsAttrDef?.attributeType = AWSDynamoDBScalarAttributeType.N
        
        let lossesAttrDef = AWSDynamoDBAttributeDefinition()
        lossesAttrDef?.attributeName = "Losses"
        lossesAttrDef?.attributeType = AWSDynamoDBScalarAttributeType.N
        
        let provisionedThroughput = AWSDynamoDBProvisionedThroughput()
        provisionedThroughput?.readCapacityUnits = 5
        provisionedThroughput?.writeCapacityUnits = 5
        
        //Create Global Secondary Index
        let rangeKeyArray = ["TopScore","Wins","Losses"]
        var gsiArray = [AWSDynamoDBGlobalSecondaryIndex]()
        
        for rangeKey in rangeKeyArray {
            let gsi = AWSDynamoDBGlobalSecondaryIndex()
            
            let gsiHashKeySchema = AWSDynamoDBKeySchemaElement()
            gsiHashKeySchema?.attributeName = "GameTitle"
            gsiHashKeySchema?.keyType = AWSDynamoDBKeyType.hash
            
            let gsiRangeKeySchema = AWSDynamoDBKeySchemaElement()
            gsiRangeKeySchema?.attributeName = rangeKey
            gsiRangeKeySchema?.keyType = AWSDynamoDBKeyType.range
            
            let gsiProjection = AWSDynamoDBProjection()
            gsiProjection?.projectionType = AWSDynamoDBProjectionType.all;
            
            gsi?.keySchema = [gsiHashKeySchema!,gsiRangeKeySchema!];
            gsi?.indexName = rangeKey;
            gsi?.projection = gsiProjection;
            gsi?.provisionedThroughput = provisionedThroughput;
            
            gsiArray.append(gsi!)
        }
        
        //Create TableInput
        let createTableInput = AWSDynamoDBCreateTableInput()
        createTableInput?.tableName = AWSSampleDynamoDBTableName;
        createTableInput?.attributeDefinitions = [hashKeyAttributeDefinition!, rangeKeyAttributeDefinition!, topScoreAttrDef!, winsAttrDef!,lossesAttrDef!]
        createTableInput?.keySchema = [hashKeySchemaElement!, rangeKeySchemaElement!]
        createTableInput?.provisionedThroughput = provisionedThroughput
        createTableInput?.globalSecondaryIndexes = gsiArray
        
        return dynamoDB.createTable(createTableInput!).continueOnSuccessWith(block: { task -> AnyObject? in
            guard task.result != nil else {
                return task
            }
            
            // Wait for up to 4 minutes until the table becomes ACTIVE.
            
            let describeTableInput = AWSDynamoDBDescribeTableInput()
            describeTableInput?.tableName = AWSSampleDynamoDBTableName;
            let describeTask = dynamoDB.describeTable(describeTableInput!)
            
            var localTask:AWSTask<AnyObject>?
            for _ in 0...15 {
                localTask = describeTask.continueOnSuccessWith(block: { task -> AnyObject? in
                    let describeTableOutput:AWSDynamoDBDescribeTableOutput = task.result!
                    let tableStatus = describeTableOutput.table!.tableStatus
                    if tableStatus == AWSDynamoDBTableStatus.active {
                        return task
                    }
                    
                    sleep(15)
                    return dynamoDB .describeTable(describeTableInput!)
                })
            }
            
            return localTask
        })
        
    }
}

