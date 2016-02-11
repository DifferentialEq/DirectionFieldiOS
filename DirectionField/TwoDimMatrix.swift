//
//  TwoDimMatrix.swift
//  DirectionField
//
//  Created by Eli Selkin on 12/27/15.
//  Copyright © 2015 DifferentialEq. All rights reserved.
//

import Foundation

enum MatrixError: ErrorType {
    case SizeMismatch(message: String)
}

class TwoDimMatrix : CustomStringConvertible {
    var Matrix:[[Complex]]
    
    var description: String {
        var stringRepr : String = "[[" 
        for complexVal in Matrix[0] {
            stringRepr.appendContentsOf(complexVal.description + ",")
        }
        var nsstringRepr = stringRepr as NSString
        stringRepr = nsstringRepr.substringWithRange(NSRange(location: 0, length: nsstringRepr.length-1)) as String
        stringRepr.appendContentsOf("],[")
        for complexVal in Matrix[1] {
            stringRepr.appendContentsOf(complexVal.description + ",")
        }
        nsstringRepr = stringRepr as NSString
        stringRepr = nsstringRepr.substringWithRange(NSRange(location: 0, length: nsstringRepr.length-1)) as String
        stringRepr.appendContentsOf("]]")
        return stringRepr
    }
    
    init() {
        Matrix = Array<Array<Complex>>()
        Matrix.append(Array<Complex>())
        Matrix.append(Array<Complex>())
        Matrix[0].append(Complex(r: 0.0, i: 0.0))
        Matrix[0].append(Complex(r: 0.0, i: 0.0))
        Matrix[0].append(Complex(r: 0.0, i: 0.0))
        Matrix[1].append(Complex(r: 0.0, i: 0.0))
        Matrix[1].append(Complex(r: 0.0, i: 0.0))
        Matrix[1].append(Complex(r: 0.0, i: 0.0))
    }
    
    init (stringMatrix:[[String]]){
        Matrix = Array<Array<Complex>>()
        Matrix.append(Array<Complex>())
        Matrix.append(Array<Complex>())
        if stringMatrix[0].count == 1 {
            do {
                try self.Matrix[0].append(Complex(realimag: stringMatrix[0][0]))
                try self.Matrix[1].append(Complex(realimag: stringMatrix[1][0]))
            } catch {
                
            }
        } else {
            do {
                try self.Matrix[0].append(Complex(realimag: stringMatrix[0][0]))
                try self.Matrix[0].append(Complex(realimag: stringMatrix[0][1]))
                try self.Matrix[0].append(Complex(realimag: stringMatrix[0][2]))
                try self.Matrix[1].append(Complex(realimag: stringMatrix[1][0]))
                try self.Matrix[1].append(Complex(realimag: stringMatrix[1][1]))
                try self.Matrix[1].append(Complex(realimag: stringMatrix[1][2]))
            } catch {
                
            }
        }
    }
    
    // Eigenvector
    init (a11: Complex, a21: Complex) {
        Matrix = Array<Array<Complex>>()
        self.Matrix.append(Array<Complex>())
        self.Matrix.append(Array<Complex>())
        self.Matrix[0].append(a11)
        self.Matrix[1].append(a21)
    }
    
    // Matrix of complexes
    init (a11: Complex, a12: Complex, a21: Complex, a22: Complex, a13: Complex, a23: Complex) {
        Matrix = Array<Array<Complex>>()
        self.Matrix.append(Array<Complex>())
        self.Matrix.append(Array<Complex>())
        self.Matrix[0].append(a11)
        self.Matrix[0].append(a12)
        self.Matrix[0].append(a13)
        self.Matrix[1].append(a21)
        self.Matrix[1].append(a22)
        self.Matrix[1].append(a23)
    }
    
    func getValueAt(row: Int, col: Int) -> Complex {
        return self.Matrix[row-1][col-1]
    }
    
    func setValueAt(row: Int, col: Int, val: Complex) -> () {
        self.Matrix[row-1][col-1] = val
    }
    
    func getDimension() -> Int {
        return self.Matrix[0].count
    }
    
    func swapRows() -> () {
        let temp = Matrix[0]
        Matrix[0] = Matrix[1]
        Matrix[1] = temp
    }
}

func +(LHS: TwoDimMatrix, RHS: TwoDimMatrix) throws -> TwoDimMatrix {
    if LHS.getDimension() != RHS.getDimension() {
        throw MatrixError.SizeMismatch(message: "Dimensions are not equal")
    }
    var result:TwoDimMatrix
    if LHS.getDimension() == 1 {
        result = TwoDimMatrix(a11: Complex(r: 0.0, i: 0.0), a21: Complex(r: 0.0, i: 0.0))
    } else {
        result = TwoDimMatrix()
    }
    for (var i = 1; i <= 2; i++) {
        for (var j = 1; j <= LHS.getDimension(); j++) {
            result.setValueAt(i, col: j, val: LHS.getValueAt(i, col: j)+RHS.getValueAt(i, col: j))
        }
    }
    return result
}

func -(LHS: TwoDimMatrix, RHS: TwoDimMatrix) throws -> TwoDimMatrix {
    if LHS.getDimension() != RHS.getDimension() {
        throw MatrixError.SizeMismatch(message: "Dimensions are not equal")
    }
    var result:TwoDimMatrix
    if LHS.getDimension() == 1 {
        result = TwoDimMatrix(a11: Complex(r: 0.0, i: 0.0), a21: Complex(r: 0.0, i: 0.0))
    } else {
        result = TwoDimMatrix()
    }
    for (var i = 1; i <= 2; i++) {
        for (var j = 1; j <= LHS.getDimension(); j++) {
            result.setValueAt(i, col: j, val: LHS.getValueAt(i, col: j)-RHS.getValueAt(i, col: j))
        }
    }
    return result
}

func *(LHS: Complex, RHS: TwoDimMatrix) -> TwoDimMatrix {
    var result: TwoDimMatrix
    if RHS.getDimension() == 1 {
        result = TwoDimMatrix(a11: Complex(r: 0.0, i: 0.0), a21: Complex(r: 0.0, i: 0.0))
    } else {
        result = TwoDimMatrix()
    }
    for (var i = 1; i <= 2; i++) {
        for (var j = 1; j <= RHS.getDimension(); j++) {
            result.setValueAt(i, col: j, val: LHS * RHS.getValueAt(i, col: j))
        }
    }
    return result
}

