//
//  Zero.swift
//  DirectionField
//
//  Created by Eli Selkin on 12/27/15.
//  Copyright © 2015 DifferentialEq. All rights reserved.
//

import Foundation
import UIKit
// ** http://floating-point-gui.de/errors/comparison/
func approxEqual (LHS: Float32, RHS: Float32, epsilon: Float32) -> Bool {
    let absLHS = abs(LHS)
    let absRHS = abs(RHS)
    let diff = abs(LHS-RHS)
    if (LHS == RHS){
        return true
    } else if (LHS == 0 || RHS == 0 || diff <= epsilon){
        return diff <= epsilon
    } else {
        return (diff / min(absLHS+absRHS, Float32.infinity)) < epsilon
    }
}

func approxEqual (LHS: CGPoint, RHS: CGPoint, epsilon: Float32) -> Bool {
    if (approxEqual(Float(LHS.x), RHS: Float(RHS.x), epsilon: epsilon) && approxEqual(Float(LHS.y), RHS: Float(RHS.y), epsilon: epsilon)){
        return true
    }
    return false
}