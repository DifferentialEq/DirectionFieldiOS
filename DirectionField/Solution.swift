//
//  Solution.swift
//  DirectionField
//
//  Created by Eli Selkin on 12/31/15.
//  Copyright © 2015 DifferentialEq. All rights reserved.
//

import UIKit

enum CalculationError:ErrorType  {
    case cannotComputeC(message:String)
}

class Solution {
    var x:[CGFloat]
    var Rs:[Complex]
    var EigVecs:[TwoDimMatrix]
    var pointsAtT:[CGPoint]
    var derivativesAtT:[CGFloat]
    var Cs:[Float32]
    var isDrawn:Bool
    let E:Float32 = 2.718281828459045235360287
    
    
    init(x:[CGFloat], Rs:[Complex], EigVecs:[TwoDimMatrix]) {
        self.x = x
        self.Rs = Rs
        self.EigVecs = EigVecs
        self.pointsAtT = [CGPoint]()
        self.derivativesAtT = [CGFloat]()
        self.Cs = [Float32]()
        Cs.append(1.0)
        Cs.append(1.0)
        self.isDrawn = false
    }
    
    func determineCs() throws {
        var GetC = TwoDimMatrix()
        GetC.setValueAt(1, col: 1, val: EigVecs[0].getValueAt(1, col: 1))
        GetC.setValueAt(1, col: 2, val: EigVecs[1].getValueAt(1, col: 1))
        GetC.setValueAt(2, col: 1, val: EigVecs[0].getValueAt(2, col: 1))
        GetC.setValueAt(2, col: 2, val: EigVecs[1].getValueAt(2, col: 1))
        GetC.setValueAt(1, col: 3, val: Complex(r: Float32(self.x[0]), i: 0.0))
        GetC.setValueAt(2, col: 3, val: Complex(r: Float32(self.x[1]), i: 0.0))
        do {
            GetC = try gaussianElimination(GetC)
            Cs[0] = GetC.getValueAt(1, col: 3).real
            Cs[1] = GetC.getValueAt(2, col: 3).real
        } catch {
            throw CalculationError.cannotComputeC(message: "Error in gauss jordan")
        }
    }
    
    func getXY(t:Float32) -> (CGPoint) {
        var xy = CGPoint()
        xy.x = CGFloat((Cs[0]*EigVecs[0].getValueAt(1, col: 1).real * powf(E,Rs[0].real*t))+(Float32(Cs[1])*EigVecs[1].getValueAt(1, col:1).real*powf(E,Rs[1].real*t)));
        xy.y = CGFloat((Cs[0]*EigVecs[0].getValueAt(2, col: 1).real * powf(E,Rs[0].real*t))+(Float32(Cs[1])*EigVecs[1].getValueAt(2, col:1).real*powf(E,Rs[1].real*t)));
        return xy
    }
    
    func getDerivativeAtT(t:Float32) -> CGFloat {
        var xy = CGPoint()
        let powER1T = powf(E,Rs[0].real*t)
        let powER2T = powf(E,Rs[1].real*t)
        let C1:Float32 = Cs[0]
        let C2:Float32 = Cs[1]
        let R1:Float32 = Rs[0].real
        let R2:Float32 = Rs[1].real
        xy.x = CGFloat((R1 * C1 * EigVecs[0].getValueAt(1, col: 1).real * powER1T) + (R2 * C2 * EigVecs[1].getValueAt(1, col:1).real * powER2T));
        xy.y = CGFloat((R1 * C1 * EigVecs[0].getValueAt(2, col: 1).real * powER1T) + (R2 * C2 * EigVecs[1].getValueAt(2, col:1).real * powER2T));
        if xy.x == 0.0 {
            return CGFloat.infinity
        }
        else {
            return xy.y/xy.x
        }
    }
    
    func generatePoints() {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            for (var i:Float32 = -5.0; i < 5.0; i += 0.1){
                self.pointsAtT.append(self.getXY(i))
            }
        }
    }
    
    func generateDerivatives() {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            for (var i:Float32 = -5.0; i < 5.0; i += 0.1){
                self.derivativesAtT.append(self.getDerivativeAtT((i)))
            }
        }
    }
}
