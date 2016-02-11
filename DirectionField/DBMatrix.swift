//
//  Matrix.swift
//  DirectionField
//
//  Created by Eli Selkin on 12/28/15.
//  Copyright © 2015 DifferentialEq. All rights reserved.
//

import GRDB

class DBMatrix : Record {
    var id: Int64!
    var matrixName: String
    var eigenValue1: String
    var eigenValue2: String
    var eigenVector1: String
    var eigenVector2: String
    var points: String
    
    init(matrixName: String, eigenValue1: String, eigenValue2: String, eigenVector1: String, eigenVector2: String, points: String) {
        self.matrixName = matrixName
        self.eigenValue1 = eigenValue1
        self.eigenValue2 = eigenValue2
        self.eigenVector1 = eigenVector1
        self.eigenVector2 = eigenVector2
        self.points = points
        super.init()
    }

    // MARK: - Record
    override class func databaseTableName() -> String {
        return "matrices"
    }
    
    required init(_ row: Row) {
        id = row.value(named: "id")
        matrixName = row.value(named: "MatrixName")
        eigenValue1 = row.value(named: "EigenValue1")
        eigenValue2 = row.value(named: "EigenValue2")
        eigenVector1 = row.value(named: "EigenVector1")
        eigenVector2 = row.value(named: "EigenVector2")
        points = row.value(named: "Points")
        super.init(row)
        
    }
    
    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return [
            "id": id,
            "MatrixName": matrixName,
            "EigenValue1": eigenValue1,
            "EigenValue2": eigenValue2,
            "EigenVector1": eigenVector1,
            "EigenVector2": eigenVector2,
            "Points": points]
    }
    
    override func didInsertWithRowID(rowID: Int64, forColumn column: String?) {
        id = rowID
    }
    
}

