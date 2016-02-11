//
//  Complex.swift
//  DirectionField
//
//  Created by Eli Selkin on 12/27/15.
//  Copyright © 2015 DifferentialEq. All rights reserved.
//

import Foundation

enum ComplexError: ErrorType {
    case BadRegexConstruction(message: String)
    case BadStringConstruction(message: String)
}

class Complex {
    var real:Float32 {
        // -- getter and setter for REAL
        get {
            return self.real
        }
        set(newr){
            self.real = newr
        }
    }
    var imaginary:Float32 {
        // -- getter and setter for IMAGINARY
        get {
            return self.imaginary
        }
        set(newi){
            self.imaginary = newi
        }
    }
    
    /*
     constructor -- initializer with 0, 1, or 2 Float32 attributes
    */
    init(newreal: Float32 = 0.0, newimaginary: Float32 = 0.0){
        self.real = newreal
        self.imaginary = newimaginary
    }
    
    /*
    constructor -- initializer with 0, 1, or 2 integer attributes
    */
    init(newreal: Int = 0, newimaginary: Int = 0){
        self.real = Float32(newreal)
        self.imaginary = Float32(newimaginary)
    }
    
    /*
    Constructor -- initializer for string interpolation FAILABLE convenience!
    */
    convenience init (realimag: String) throws {
        // first conveniently create a new Complex instance
        self.init(newreal: 0.0, newimaginary: 0.0)
        // then try to store the real values
        do {
            let internalRegularExpression = try NSRegularExpression(pattern: "^([+-]?[0-9]*[.]?[0-9]+)([+-][0-9]*[.]?[0-9]+)[i]$", options: .CaseInsensitive)
            let matches = internalRegularExpression.matchesInString(realimag, options: .Anchored, range: NSRange(location: 0, length: realimag.utf16.count))
            for match in matches as [NSTextCheckingResult] {
                let realString:NSString = (realimag as NSString).substringWithRange(match.rangeAtIndex(1))
                self.real = realString.floatValue
                let imagString:NSString = (realimag as NSString).substringWithRange(match.rangeAtIndex(2))
                self.imaginary = imagString.floatValue
            }
        } catch {
            throw ComplexError.BadRegexConstruction(message: "Bad expression")
        }
    }
    
}

func +(LHS: Complex, RHS: Complex)->Complex{
    return Complex(newreal: (LHS.real + RHS.real), newimaginary: (LHS.imaginary + RHS.imaginary))
}

func -(LHS: Complex, RHS: Complex)->Complex{
    return Complex(newreal: (LHS.real - RHS.real), newimaginary: (LHS.imaginary - RHS.imaginary))
}

func *(LHS: Complex, RHS: Complex)->Complex{
    return Complex(newreal: (LHS.real*RHS.real)-(LHS.imaginary*RHS.imaginary), newimaginary: (LHS.real*RHS.imaginary)+(LHS.imaginary*RHS.real))
}




