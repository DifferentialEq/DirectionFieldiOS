//
//  AppDelegate.swift
//  DirectionField
//
//  Created by Eli Selkin on 12/27/15.
//  Copyright © 2015 DifferentialEq. All rights reserved.
//

import UIKit
import GRDB
import Fabric
import TwitterKit
// Systemwide available
var dfDBQueue:DatabaseQueue!


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let TABLE_NAME:String = "matrices"
    let MATRIX_COL_NAME:String = "MatrixName"
    let MATRIX_COL_TYPE:String = "VARCHAR(128)"
    let EIG1_COL_NAME:String = "EigenValue1"
    let EIG1_COL_TYPE:String = "VARCHAR(64)"
    let EIG2_COL_NAME:String = "EigenValue2"
    let EIG2_COL_TYPE:String = "VARCHAR(64)"
    let EIGVEC1_COL_NAME:String = "EigenVector1"
    let EIGVEC1_COL_TYPE:String = "VARCHAR(64)"
    let EIGVEC2_COL_NAME:String = "EigenVector2"
    let EIGVEC2_COL_TYPE:String = "VARCHAR(64)"
    let PTS_COL_NAME:String = "Points"
    let PTS_COL_TYPE:String = "VARCHAR(256)"
    let TABLE_NAME_TUTORIAL:String = "tutorial"
    let TUTORIAL_COMPLETE_NAME = "tutorialcomplete"
    let TUTORIAL_COMPLETE_TYPE = "INTEGER" // 0 == false, 1 == true
    var window: UIWindow?
    var dbFilePath: NSString = NSString()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString
        let databasePath = documentsPath.stringByAppendingPathComponent("dfDB.sqlite")
        dfDBQueue = try! DatabaseQueue(path: databasePath)
        
        // Migrate would handle old DBs too if there were some
        var migrator = DatabaseMigrator()
        migrator.registerMigration("createMatrixTable"){ db in
            // closure in
            var CREATE_QUERY:String = "CREATE TABLE IF NOT EXISTS " + self.TABLE_NAME + "( "
            CREATE_QUERY.appendContentsOf(" " + self.MATRIX_COL_NAME + " " + self.MATRIX_COL_TYPE + " primary key, ")
            CREATE_QUERY.appendContentsOf(" id  INTEGER, ")
            CREATE_QUERY.appendContentsOf(" " + self.EIG1_COL_NAME + " " + self.EIG1_COL_TYPE + ", ")
            CREATE_QUERY.appendContentsOf(" " + self.EIG2_COL_NAME + " " + self.EIG2_COL_TYPE + ", ")
            CREATE_QUERY.appendContentsOf(" " + self.EIGVEC1_COL_NAME + " " + self.EIGVEC1_COL_TYPE + ", ")
            CREATE_QUERY.appendContentsOf(" " + self.EIGVEC2_COL_NAME + " " + self.EIGVEC2_COL_TYPE + ", ")
            CREATE_QUERY.appendContentsOf(" " + self.PTS_COL_NAME + " " + self.PTS_COL_TYPE + ");")
            try db.execute(CREATE_QUERY) // instantiate the DB and the QUEUE is only in memory
        }
        migrator.registerMigration("addDefault") { db in
            try DBMatrix(matrixName: "[[+1.0000+0.0000i,+1.0000+0.0000i,+0.0000+0.0000i],[+4.0000+0.0000i,+1.0000+0.000i,+0.0000+0.0000i]]", eigenValue1: "-1.0+0.0i", eigenValue2: "3.0+0i", eigenVector1: "[[1.0+0.0i],[-2.0+0.0i]]", eigenVector2: "[[1.0+0i],[2+0i]]", points: "(-.33,.19),(.52,.12),(.05,-.17),(0.17,-0.31),(-.04,.13),(-.2,0.0)").insert(db)
        }
        migrator.registerMigration("createTutorial") { db in
            let CREATE_QUERY = "CREATE TABLE IF NOT EXISTS " + self.TABLE_NAME_TUTORIAL + "( " + self.TUTORIAL_COMPLETE_NAME + " " + self.TUTORIAL_COMPLETE_TYPE + " primary key, id INTEGER);"
            try db.execute(CREATE_QUERY)
        }
        try! migrator.migrate(dfDBQueue)
        Fabric.with([Twitter.self])
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

