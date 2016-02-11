//
//  Quadratic.swift
//  DirectionField
//
//  Created by Eli Selkin on 12/27/15.
//  Copyright © 2015 DifferentialEq. All rights reserved.
//

import Foundation

class Quadratic {
    let a:Complex
    let b:Complex
    let c:Complex
    // Frequently used Complex values
    let negativeone = Complex(r: -1.0, i: 0)
    let onehalf = Complex(r: 0.5, i: 0.0)
    let four = Complex(r: 4.0, i: 0.0)
    let i = Complex(r: 0.0, i: 1.0)

    init (a: Complex, b: Complex, c: Complex){
        self.a = a
        self.b = b
        self.c = c
    }
    
    func solve() -> [Complex] {
        var roots = Array<Complex>()
        let rValue = onehalf * a * b
        let iValue = onehalf * a * realSqrt(((square(b) - four * a * c)))
        roots.append(rValue-iValue)
        roots.append(rValue+iValue)
        return roots
    }

    func solvei() -> [Complex] {
        var roots = Array<Complex>()
        let rValue = (onehalf * a) * b
        let iValue = (onehalf * a) * (realSqrt(negativeone*(square(b)-four*a*c))*i)
        roots.append(rValue-iValue)
        roots.append(rValue+iValue)
        return roots
    }
    
    
}