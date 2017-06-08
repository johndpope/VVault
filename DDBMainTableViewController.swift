//
//  DDBMainTableViewController.swift
//  VVault
//
//  Created by Sean Zhang on 4/20/17.
//  Copyright © 2017 Sean Zhang. All rights reserved.
//

import Foundation
import UIKit
import AWSCore
import AWSDynamoDB

class DDBMainTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
   var table: UITableView?
    
    var tableRows: Array<DDBTableRow>?
    var lock:NSLock?
    var lastEvaluatedKey:[String : AWSDynamoDBAttributeValue]!
    var doneLoading = false
    var needsToRefresh = false
    
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
    
    func initTable(){
        DDBDynamoDBManager.describeTable().continueWith(executor: AWSExecutor.mainThread()){ task -> Any? in // (AWSTask<AnyObject>) -> Any?
            if let error = task.error {
                print("Describing table has an error and Error--------------------> \(error)")
            } else {
                print("No Error has occured during the describing the table -----!!!!!!-----Yata")
            }
            return nil
        }
    }
    
    func loadTable() {

        let scanExpression = AWSDynamoDBScanExpression()
        
        //scanExpression.limit = 10
        
        
        dynamoDBObjectMapper.scan(_: DDBTableRow.self, expression: scanExpression).continueWith() { task -> Any? in
             //task:(AWSTask<AWSDynamoDBPaginatedOutput>) -> Any?
            if let error = task.error {
                print("The error occured when scanning \(error)")
                print("Additional Description of Error \(error.localizedDescription)")
            } else {
                self.tableRows = task.result?.items as? [DDBTableRow]
                print("The task has successfully finsihed and scan results are \(String(describing: self.tableRows))")
                self.table?.reloadData()
            }
            return nil
        }
    }
    
    func setupTable() {
        //See if the table exist
        
        DDBDynamoDBManager.describeTable().continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            
            // If the test table doesn't exist, create one.
            if let error = task.error as NSError?, error.domain == AWSDynamoDBErrorDomain && error.code == AWSDynamoDBErrorType.resourceNotFound.rawValue {
                self.performSegue(withIdentifier: "DDBLoadingViewSegue", sender: self)
                
                return DDBDynamoDBManager.createTable() .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
                    if let error = task.error as NSError? {
                        //Handle errors.
                        print("Error: \(error)")
                        
                        let alertController = UIAlertController(title: "Failed to setup a test table.", message: error.description, preferredStyle: UIAlertControllerStyle.alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                        alertController.addAction(okAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        self.dismiss(animated: false, completion: nil)
                    }
                    
                    return nil
                    
                })
            } else {
                //load table contents
                self.refreshList(startFromBeginning: true)
            }
            
            return nil
        })
    }

    func refreshList(startFromBeginning: Bool)  {
//        if (self.lock?.try() != nil) {
        
            
//            if startFromBeginning {
//                self.lastEvaluatedKey = nil;
//                self.doneLoading = false
//            }
//            
//            
//            UIApplication.shared.isNetworkActivityIndicatorVisible = true
//            
//            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
//            let queryExpression = AWSDynamoDBScanExpression()
//            queryExpression.exclusiveStartKey = self.lastEvaluatedKey
//            queryExpression.limit = 20;
//            dynamoDBObjectMapper.scan(DDBTableRow.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
//                
//                if self.lastEvaluatedKey == nil {
//                    self.tableRows?.removeAll(keepCapacity: true)
//                }
        
//                if task.result != nil {
//                    let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
//                    for item in paginatedOutput.items as! [DDBTableRow] {
//                        self.tableRows?.append(item)
//                    }
//                    
//                    self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
//                    if paginatedOutput.lastEvaluatedKey == nil {
//                        self.doneLoading = true
//                    }
//                }
                
//                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                self.tableView.reloadData()
                
//                if ((task.error) != nil) {
//                    print("Error: \(task.error)")
//                }
//              return nil
//            })
//        }
    }
    
    func generateTestData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        
        var tasks = [AWSTask<AnyObject>]()
        let gameTitleArray =  ["Galaxy Invaders","Meteor Blasters", "Starship X", "Alien Adventure","Attack Ships"]
        for i in 0..<25 {
            for j in 0..<2 {
                let tableRow = DDBTableRow();
                tableRow?.UserId = "\(i)"
                if j == 0 {
                    let c = Int(arc4random_uniform(UInt32(gameTitleArray.count)))
                    tableRow?.GameTitle = gameTitleArray[c]
                } else {
                    tableRow?.GameTitle = "Comet Quest"
                }
                tableRow?.TopScore = Int(arc4random_uniform(3000)) as NSNumber?
                tableRow?.Wins = Int(arc4random_uniform(100)) as NSNumber?
                tableRow?.Losses = Int(arc4random_uniform(100)) as NSNumber?
                
                //Those two properties won't be saved to DynamoDB since it has been defined in ignoredAttributes
                tableRow?.internalName = "internal attributes(should not be saved to dynamoDB)"
                tableRow?.internalState = i as NSNumber?;
                
                tasks.append(dynamoDBObjectMapper.save(tableRow!))
            }
        }
        
        /*!
         Returns a task that will be completed (with result == nil) once
         all of the input tasks have completed.
         @param tasks An `NSArray` of the tasks to use as an input.
         */
        AWSTask<AnyObject>(forCompletionOfAllTasks: Optional(tasks)).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask) -> AnyObject? in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            self.refreshList(startFromBeginning: true)
            return nil
        })
    }
    
    func createTableRow() {
        
        
        let tableRow = DDBTableRow()
        tableRow?.UserId = "ID_\(Date().description)_\(arc4random())"
        tableRow?.GameTitle = "Clash of Clan \(Date().description)"
        tableRow?.Wins = 1
        tableRow?.Losses = 12
        tableRow?.TopScore = 129
        
        //Those two properties won't be saved to DynamoDB since it has been defined in ignoredAttributes
        tableRow?.internalName = "internal attributes(should not be saved to dynamoDB)"
        tableRow?.internalState = 1
        
        dynamoDBObjectMapper.save(tableRow!).continueWith(){ task -> Any? in
            
            if let error = task.error {
                print("Saving table has failed with error -------------> \(error)")
            } else {
                print("Saving table row as successful and status: \(task.isCompleted)")
                self.table.reloadData()
            }
            return nil
        }
    }
    
    func readTableRow() {
        //read or search for specific tableRows by using the scanExpression or QueryExpression
    }
    
    func updateTableRow() {
        
    }
    
    func deleteTableRow() {
        
    }
    
    override func viewDidLoad() {

        table?.delegate = self
        table?.dataSource = self
        
        tableRows = []
        lock = NSLock()
        
        //self.setupTable()
        //self.initTable()
        //self.loadTable()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
       
        if self.needsToRefresh {
            self.refreshList(startFromBeginning: true)
            self.needsToRefresh = false
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableRows?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = tableRows?[indexPath.row].GameTitle

        return cell
    }
    
    
    
    
}
