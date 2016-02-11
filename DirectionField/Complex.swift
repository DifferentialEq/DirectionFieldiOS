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

class Complex : CustomStringConvertible {
    let epsilon:Float32 = 1e-5
    var real:Float32
    var imaginary:Float32
    
    var description:String {
        get {
            return String(format: "%+5.4f%+5.4fi", self.real, self.imaginary)
        }
    }
    
    /*
     constructor -- initializer with 0, 1, or 2 Float32 attributes
    */
    init(r: Float32 = 0.0, i: Float32 = 0.0){
        self.real = r
        self.imaginary = i
    }
    
    /*
    constructor -- initializer with 0, 1, or 2 integer attributes
    */
    init(r: Int = 0, i: Int = 0){
        self.real = Float32(r)
        self.imaginary = Float32(i)
    }
    
    /*
    Constructor -- initializer for string interpolation FAILABLE convenience!
    */
    convenience init (realimag: String) throws {
        // first conveniently create a new Complex instance
        self.init(r: 0.0, i: 0.0)
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
    /**
     * http://floating-point-gui.de/errors/comparison/ Comparing complex conjugate to 0.0+0.0i
     */
    func isZero() -> Bool {
        let absR = abs(self.real)
        let absI = abs(self.imaginary)
        if (self.real == 0 && self.imaginary == 0){
            return true
        } else if (absR <= epsilon && absI <= epsilon){
            self.real = 0
            self.imaginary = 0
            return true
        } else {
            return false
        }
    }
    
    /**
     Distance on CxR plane
    */
    func distanceFromZero() -> Float32 {
        return sqrtf((self.real*self.real)+(self.imaginary*self.imaginary))
    }
}

func +(LHS: Complex, RHS: Complex) -> Complex{
    return Complex(r: (LHS.real + RHS.real), i: (LHS.imaginary + RHS.imaginary))
}

func -(LHS: Complex, RHS: Complex) -> Complex {
    return Complex(r: (LHS.real - RHS.real), i: (LHS.imaginary - RHS.imaginary))
}

func *(LHS: Complex, RHS: Complex) -> Complex {
    return Complex(r: (LHS.real*RHS.real)-(LHS.imaginary*RHS.imaginary), i: (LHS.real*RHS.imaginary)+(LHS.imaginary*RHS.real))
}

func /(LHS: Complex, RHS: Complex) -> Complex {
    if LHS.isZero() {
        return Complex(r: 0.0, i: 0.0)
    }
    var real:Float32 = LHS.real * RHS.real
    real += LHS.imaginary * RHS.imaginary
    var imaginary = LHS.real * RHS.imaginary * -1.0
    imaginary += LHS.imaginary * RHS.real
    let denominator:Float32 = RHS.real * RHS.real + RHS.imaginary * RHS.imaginary
    return Complex(r: real/denominator, i: imaginary/denominator)
}

func >= (LHS: Complex, RHS: Complex) -> Bool {
    return (LHS.real >= RHS.real)
}

func == (LHS: Complex, RHS: Complex) -> Bool {
    return (approxEqual(LHS.real, RHS: RHS.real, epsilon: 1E-10) && approxEqual(LHS.imaginary, RHS: RHS.imaginary, epsilon: 1E-10))
}

func square(base:Complex) -> Complex {
    return base*base
}

func realSqrt(radicand: Complex) -> Complex {
    return Complex(r: sqrtf(radicand.real))
}


