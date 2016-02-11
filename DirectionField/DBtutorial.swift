//
//  Matrix.swift
//  DirectionField
//
//  Created by Eli Selkin on 1/7/16.
//  Copyright © 2015-2016 DifferentialEq. All rights reserved.
//

import GRDB

class DBtutorial : Record {
    var id: Int64!
    var tutorialcomplete: Int!
    
    init(complete: Int) {
        self.id = Int64(rand()) * Int64(10)
        self.tutorialcomplete = complete
        super.init()
    }
    
    // MARK: - Record
    override class func databaseTableName() -> String {
        return "tutorial"
    }
    
    required init(_ row: Row) {
        id = row.value(named: "id")
        tutorialcomplete = row.value(named: "tutorialcomplete")
        super.init(row)
        
    }
    
    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return [
            "id": id,
            "tutorialcomplete": tutorialcomplete]
    }
    
    override func didInsertWithRowID(rowID: Int64, forColumn column: String?) {
        id = rowID
    }
    
}

