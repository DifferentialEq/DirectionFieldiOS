//
//  iSolution.swift
//  DirectionField
//
//  Created by Eli Selkin on 1/1/16.
//  Copyright © 2016 DifferentialEq. All rights reserved.
//

import UIKit

class iSolution : Solution {
    var lambda:Float32
    var mu:Float32
    var As:[Float32]
    var Bs:[Float32]
    
    init(x:[CGFloat], Rs:[Complex], EigVecs:[TwoDimMatrix], As:[Float32], Bs:[Float32], mu:Float32, lambda:Float32) {
        self.As = As
        self.Bs = Bs
        self.mu = mu
        self.lambda = lambda
        super.init(x: x, Rs: Rs, EigVecs: EigVecs)
    }
    
    override func determineCs() throws {
        var result:TwoDimMatrix = solveForT(0.0)
        result.setValueAt(1, col: 3, val: Complex(r: Float32(self.x[0]), i: 0.0))
        result.setValueAt(2, col: 3, val: Complex(r: Float32(self.x[1]), i: 0.0))
        do {
            result = try gaussianElimination(result)
        } catch {
            throw CalculationError.cannotComputeC(message: "Error computing C")
        }
        Cs[0] = result.getValueAt(1, col: 3).real
        Cs[1] = result.getValueAt(2, col: 3).real
    }
    
    override func getXY(t:Float32) -> (CGPoint) {
        var xy = CGPoint()
        let result:TwoDimMatrix = solveForT(t)
        let powE:Float32 = powf(Float(M_E), self.lambda * t)
        xy.x = CGFloat ( powE * (result.getValueAt(1, col: 1).real + result.getValueAt(1, col: 2).real) )
        xy.y = CGFloat ( powE * (result.getValueAt(2, col: 1).real + result.getValueAt(2, col: 2).real) )
        return xy
    }
    
    func solveForT(t:Float32) -> (TwoDimMatrix) {
        let muT = mu * t;
        let xMatrix = TwoDimMatrix();

        xMatrix.setValueAt(1, col: 1, val: Complex(r: (Cs[0] * (As[0] * cos(muT) - Bs[0] * sin(muT))), i: 0.0))
        xMatrix.setValueAt(1, col: 2, val: Complex(r: (Cs[1] * (As[0] * sin(muT) + Bs[0] * cos(muT))), i: 0.0))
        xMatrix.setValueAt(2, col: 1, val: Complex(r: (Cs[0] * (As[1] * cos(muT) - Bs[1] * sin(muT))), i: 0.0))
        xMatrix.setValueAt(2, col: 2, val: Complex(r: (Cs[1] * (As[1] * sin(muT) + Bs[1] * cos(muT))), i: 0.0))
        // HERE we should do a solution to find x1 and x2 or u(t) and v(t) and return as float
        return xMatrix;
    }

    func solveDerivForT(t:Float32) -> (TwoDimMatrix) {
        let muT = mu * t;
        let xMatrix = TwoDimMatrix();
        xMatrix.setValueAt(1, col: 1, val: Complex(r: (-1 * Cs[0] * (As[0] * mu * sin(muT) + Bs[0] * mu * cos(muT))), i: 0.0))
        xMatrix.setValueAt(1, col: 2, val: Complex(r: (Cs[1] * (As[0] * mu * cos(muT) - Bs[0] * mu * sin(muT))), i: 0.0))
        xMatrix.setValueAt(2, col: 1, val: Complex(r: (-1 * Cs[0] * (As[1] * mu * sin(muT) + Bs[1] * mu * cos(muT))), i: 0.0))
        xMatrix.setValueAt(2, col: 2, val: Complex(r: (Cs[1] * (As[1] * mu * cos(muT) - Bs[1] * mu * sin(muT))), i: 0.0))
        return xMatrix;
    }
    
    
    override func getDerivativeAtT(t:Float32) -> CGFloat {
        var xy = CGPoint()
        let resultDeriv = solveDerivForT(t);
        let result = solveForT(t);
        let powerE = powf(Float(M_E), self.lambda * t);
        let powerEDeriv = self.lambda * powerE;
        
        var x1:Float32 = powerE * resultDeriv.getValueAt(1, col: 1).real
        x1 += powerEDeriv * result.getValueAt(1, col: 1).real
        x1 += powerE * resultDeriv.getValueAt(1, col: 2).real
        x1 += powerEDeriv * result.getValueAt(1, col: 2).real
        xy.x = CGFloat(x1)
        
        var x2:Float32 = powerE * resultDeriv.getValueAt(2, col: 1).real
        x2 += powerEDeriv * result.getValueAt(2, col: 1).real
        x2 += powerE * resultDeriv.getValueAt(2, col: 2).real
        x2 += powerEDeriv * result.getValueAt(2, col: 2).real
        xy.y = CGFloat(x2)
        
        if xy.x == 0.0 {
            return CGFloat.infinity
        }
        else {
            return xy.y/xy.x
        }
    }
    
}
