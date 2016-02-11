//
//  MatrixMath.swift
//  DirectionField
//
//  Created by Eli Selkin on 12/27/15.
//  Copyright © 2015 DifferentialEq. All rights reserved.
//

import Foundation

enum MatrixMathError:ErrorType {
    case SizeError(message: String)
    case EigenVectorError(message: String)
    case MalformedMatrixError(message: String)
}

func eigenValues(matrix:TwoDimMatrix) throws -> [Complex] {
    var EigenValues:[Complex] = [Complex]()
    if matrix.getDimension() != 3 {
        throw MatrixMathError.SizeError(message: "Must be 2x3")
    }
    let a = matrix.getValueAt(1, col: 1)
    let b = matrix.getValueAt(1, col: 2)
    let c = matrix.getValueAt(2, col: 1)
    let d = matrix.getValueAt(2, col: 2)
    let four = Complex(r: 4.0, i: 0.0)
    let quadA = Complex(r: 1.0, i: 0.0)
    let quadB = a+d
    var quadC = a*d
    let quadCbc = b*c
    quadC = quadC - quadCbc
    let quadraticLambdas = Quadratic(a: quadA, b: quadB, c: quadC)
    var FourAC = four * quadA
    FourAC = FourAC * quadC
    if (FourAC) >= (square(quadB)) {
        EigenValues = quadraticLambdas.solvei()
    } else {
        EigenValues = quadraticLambdas.solve()
    }
    return EigenValues
}

func gaussianElimination(matrix: TwoDimMatrix) throws -> TwoDimMatrix {
    if (matrix.getValueAt(1, col: 1).isZero()) {
        // IF A == 0
        matrix.swapRows()
        if (matrix.getValueAt(1, col: 1).isZero()) {
            // IF C == 0
            if (matrix.getValueAt(1, col: 2).isZero()){
                // IF D == 0
                matrix.swapRows() // swap first row back
                if (matrix.getValueAt(1, col: 2).isZero()){
                    // IF B == 0
                    if (matrix.getValueAt(1, col: 3).isZero() && matrix.getValueAt(2, col: 3).isZero()) {
                        // ok matrix where 0 matrix ([A,B,E],[C,D,F]) all 0
                        return matrix
                    } else {
                        // BAD MATRIX where ([0,0,E],[0,0,F])
                        throw MatrixMathError.MalformedMatrixError(message: "A,B,C,D == 0, but E,F not both 0")
                    }
                } else {
                    // If B != 0
                    // Matrix where ([0,B,E],[0,0,F])
                    if (matrix.getValueAt(2, col: 3).isZero()){
                        // Matrix where ([0,1,E/B],[0,0,0])
                        matrix.setValueAt(1, col: 3, val: matrix.getValueAt(1, col: 3) / matrix.getValueAt(1, col: 2))
                        matrix.setValueAt(1, col: 3, val: Complex(r: 1.0, i: 0.0))
                        return matrix
                    } else {
                        throw MatrixMathError.MalformedMatrixError(message: "C,D = 0, but F not 0")
                    }
                }
            } else {
                // IF D != 0
                if (matrix.getValueAt(2, col: 2).isZero() && !matrix.getValueAt(2, col: 3).isZero()){
                    // Error condition
                    throw MatrixMathError.MalformedMatrixError(message: "A, B = 0, but E != 0")
                } else {
                    // E/B must == F/D
                    matrix.setValueAt(1, col: 3, val: matrix.getValueAt(1, col: 3)/matrix.getValueAt(1, col: 2))
                    matrix.setValueAt(1, col: 2, val: Complex(r: 1.0, i: 0.0))
                    matrix.setValueAt(2, col: 3, val: matrix.getValueAt(2, col: 3)/matrix.getValueAt(2, col: 2))
                    matrix.setValueAt(2, col: 2, val: Complex(r: 1.0, i: 0.0))
                    if (matrix.getValueAt(1, col: 3) == matrix.getValueAt(2, col: 3)) {
                        //Ok matrix
                        matrix.setValueAt(2, col: 2, val: Complex(r: 0.0, i: 0.0))
                        matrix.setValueAt(2, col: 3, val: Complex(r: 0.0, i: 0.0))
                        return matrix
                    } else {
                        throw MatrixMathError.MalformedMatrixError(message: "E/B != F/D")
                    }
                }
                
            }
        } else {
            // IF C != 0
            if (matrix.getValueAt(2, col: 2).isZero()){
                // B == 0
                if (matrix.getValueAt(2, col: 3).isZero()) {
                    if (matrix.getValueAt(1, col: 2).isZero()){
                        // D == 0
                        matrix.setValueAt(1, col: 3, val: matrix.getValueAt(1, col: 3) / matrix.getValueAt(1, col: 1))
                        matrix.setValueAt(1, col: 1, val: Complex(r: 1.0, i: 0.0))
                        return matrix
                    } else {
                        // D != 0
                        matrix.setValueAt(1, col: 3, val: matrix.getValueAt(1, col: 3) / matrix.getValueAt(1, col: 1))
                        matrix.setValueAt(1, col: 1, val: Complex(r: 1.0, i: 0.0))
                        matrix.setValueAt(1, col: 2, val: matrix.getValueAt(1, col: 2) / matrix.getValueAt(1, col: 1))
                        return matrix
                    }
                } else {
                    // error A, B == 0, but E != 0
                    throw MatrixMathError.MalformedMatrixError(message: "A,B = 0, but E != 0")
                }
            } else {
                // B != 0
                let B = matrix.getValueAt(2, col: 2)
                let C = matrix.getValueAt(1, col: 1)
                let D = matrix.getValueAt(1, col: 2)
                let E = matrix.getValueAt(2, col: 3)
                let F = matrix.getValueAt(1, col: 3)
                var FDEBC = E/B
                FDEBC = D * FDEBC
                FDEBC = F - FDEBC
                FDEBC = FDEBC / C
                matrix.setValueAt(1, col: 3, val: FDEBC)
                matrix.setValueAt(2, col: 3, val: E/B)
                matrix.setValueAt(1, col: 1, val: Complex(r: 1.0, i: 0.0))
                matrix.setValueAt(2, col: 2, val: Complex(r: 1.0, i: 0.0))
                return matrix
            }
        }
    } else {
        // A != 0
        if (matrix.getValueAt(2, col: 1).isZero()) {
            // C == 0
            if (matrix.getValueAt(1, col: 2).isZero()) {
                // B == 0
                matrix.setValueAt(1, col: 3, val: matrix.getValueAt(1, col: 3)/matrix.getValueAt(1, col: 1))
                matrix.setValueAt(1, col: 1, val: Complex(r: 1.0, i: 0.0))
                if (matrix.getValueAt(2, col: 2).isZero()){
                    // D == 0
                    if (matrix.getValueAt(2, col: 3).isZero()){
                        return matrix
                    } else {
                        throw MatrixMathError.MalformedMatrixError(message: "C,D == 0, but F != 0")
                    }
                } else {
                    // D != 0
                    matrix.setValueAt(2, col: 3, val: matrix.getValueAt(2, col: 3)/matrix.getValueAt(2, col: 2))
                    matrix.setValueAt(2, col: 2, val: Complex(r: 1.0, i: 0.0))
                    return matrix
                }
            } else {
                // B != 0
                if (matrix.getValueAt(2, col: 2).isZero()) {
                    // D == 0
                    matrix.setValueAt(1, col: 3, val: matrix.getValueAt(1, col: 3)/matrix.getValueAt(1, col: 1))
                    matrix.setValueAt(1, col: 2, val: matrix.getValueAt(1, col: 2)/matrix.getValueAt(1, col: 1))
                    if (matrix.getValueAt(2, col: 3).isZero()){
                        return matrix
                    } else {
                        throw MatrixMathError.MalformedMatrixError(message: "C,D = 0, F != 0")
                    }
                } else {
                    // D != 0
                    let A = matrix.getValueAt(1, col: 1)
                    let B = matrix.getValueAt(1, col: 2)
                    let D = matrix.getValueAt(2, col: 2)
                    let E = matrix.getValueAt(1, col: 3)
                    let F = matrix.getValueAt(2, col: 3)
                    matrix.setValueAt(1, col: 3, val: ((E - (B * (F / D)))/A))
                    matrix.setValueAt(2, col: 3, val: F/D)
                    return matrix
                }
            }
        } else {
            // C != 0
            if (matrix.getValueAt(1, col: 2).isZero()) {
                // B == 0
                if (matrix.getValueAt(2, col: 2).isZero()) {
                    // D == 0
                    matrix.setValueAt(1, col: 3, val: matrix.getValueAt(1, col: 3)/matrix.getValueAt(1, col: 1))
                    matrix.setValueAt(2, col: 3, val: matrix.getValueAt(2, col: 3)/matrix.getValueAt(2, col: 1))
                    if (matrix.getValueAt(1, col: 3) == matrix.getValueAt(2, col: 3)) {
                        return matrix
                    } else {
                        throw MatrixMathError.MalformedMatrixError(message: "E/A != F/C and A/A == C/C")
                    }
                } else {
                    // D != 0
                    let A = matrix.getValueAt(1, col: 1)
                    let C = matrix.getValueAt(2, col: 1)
                    let D = matrix.getValueAt(2, col: 2)
                    let E = matrix.getValueAt(1, col: 3)
                    let F = matrix.getValueAt(2, col: 3)
                    matrix.setValueAt(1, col: 1, val: Complex(r: 1.0, i: 0.0))
                    matrix.setValueAt(1, col: 3, val: E/A)
                    var FCEAD = E/A
                    FCEAD = FCEAD * C
                    FCEAD = F - FCEAD
                    FCEAD = FCEAD / D
                    matrix.setValueAt(2, col: 1, val: Complex(r: 0.0, i: 0.0)) // A != 0 A/A = 1, C- C*A/A = 0
                    matrix.setValueAt(2, col: 3, val: FCEAD)
                    matrix.setValueAt(2, col: 2, val: Complex(r: 1.0, i: 0.0))
                    return matrix
                }
            } else {
                // B != 0
                let A = matrix.getValueAt(1, col: 1)
                let B = matrix.getValueAt(1, col: 2)
                let C = matrix.getValueAt(2, col: 1)
                let D = matrix.getValueAt(2, col: 2)
                let E = matrix.getValueAt(1, col: 3)
                let F = matrix.getValueAt(2, col: 3)
                matrix.setValueAt(1, col: 2, val: B/A)
                matrix.setValueAt(1, col: 3, val: E/A)
                matrix.setValueAt(1, col: 1, val: A/A)
                matrix.setValueAt(2, col: 1, val: Complex(r: 0.0, i: 0.0))
                var DCBA = matrix.getValueAt(1, col: 2)
                DCBA = DCBA * C
                DCBA = D - DCBA
                matrix.setValueAt(2, col: 2, val: DCBA)
                var FCEA = matrix.getValueAt(1, col: 3)
                FCEA = C * FCEA
                FCEA = F - FCEA
                matrix.setValueAt(2, col: 3, val: FCEA)
                if (matrix.getValueAt(2, col: 2).isZero() && !matrix.getValueAt(2, col: 3).isZero()){
                    throw MatrixMathError.MalformedMatrixError(message: "D-C(B/A) == 0, but F - C(E/A) != 0")
                }
                matrix.setValueAt(2, col: 3, val: matrix.getValueAt(2, col: 3)/matrix.getValueAt(2, col: 2))
                matrix.setValueAt(2, col: 2, val: matrix.getValueAt(2, col: 2)/matrix.getValueAt(2, col: 2))
                matrix.setValueAt(1, col: 2, val: matrix.getValueAt(1, col: 2) - (matrix.getValueAt(1, col: 2)*matrix.getValueAt(2, col: 2)))
                matrix.setValueAt(1, col: 3, val: matrix.getValueAt(1, col: 3) - ((B/A)*matrix.getValueAt(2, col: 3)))
                return matrix
            }
        }
    }
}

func eigenVectors(matrix:TwoDimMatrix) throws -> ([TwoDimMatrix]?, TwoDimMatrix?) {
    var EigenVectors = Array<TwoDimMatrix>()
    EigenVectors.append(TwoDimMatrix(a11: Complex(r: 0.0, i: 0.0), a21: Complex(r: 0.0, i: 0.0)))
    EigenVectors.append(TwoDimMatrix(a11: Complex(r: 0.0, i: 0.0), a21: Complex(r: 0.0, i: 0.0)))
    let EigenValues = TwoDimMatrix(a11: Complex(r: 0.0, i: 0.0), a21: Complex(r: 0.0, i: 0.0))
    do {
        let Lambdas = try eigenValues(matrix)
        for (var i = 0; i < Lambdas.count; i++){
            EigenValues.setValueAt(i+1, col: 1, val: Lambdas[i])
            var I = TwoDimMatrix(a11: Complex(r: 1.0, i: 0.0), a12: Complex(r: 0.0, i: 0.0), a21: Complex(r: 0.0, i: 0.0), a22: Complex(r: 1.0, i: 0.0), a13: Complex(r: 0.0, i: 0.0), a23: Complex(r: 0.0, i: 0.0))
            I = Lambdas[i] * I // complex scalar mult
            var M = try matrix - I
            M = try gaussianElimination(M)
            if (M.getValueAt(1, col: 1).isZero()){
                if (M.getValueAt(1, col: 2).isZero()) {
                    continue
                } else {
                    EigenVectors[i].setValueAt(2, col: 1, val: Complex(r: 1.0, i: 0.0))
                    continue
                }
            } else {
                if (M.getValueAt(1, col: 2).isZero() && M.getValueAt(2, col: 2).isZero()){
                    EigenVectors[i].setValueAt(1, col: 1, val: Complex(r: 1.0, i: 0.0))
                    continue
                } else if (M.getValueAt(1, col: 2).isZero()){
                    continue
                } else {
                    EigenVectors[i].setValueAt(2, col: 1, val: M.getValueAt(1, col: 1))
                    EigenVectors[i].setValueAt(1, col: 1, val: Complex(r: -1.0, i: 0.0) * M.getValueAt(1, col: 2))
                    // simplify as much as possible
                    if (EigenVectors[i].getValueAt(1, col: 1).distanceFromZero()  < 1.0){
                        EigenVectors[i].setValueAt(2, col: 1, val: EigenVectors[i].getValueAt(2, col: 1)/EigenVectors[i].getValueAt(1, col: 1))
                        EigenVectors[i].setValueAt(1, col: 1, val: EigenVectors[i].getValueAt(1, col: 1)/EigenVectors[i].getValueAt(1, col: 1))
                    }
                    if (EigenVectors[i].getValueAt(1, col: 1).imaginary != 0.0){
                        EigenVectors[i].swapRows()
                    }
                }
            }
        }
        return (EigenVectors as Array<TwoDimMatrix>?, EigenValues as TwoDimMatrix?)
    } catch {
        throw MatrixMathError.EigenVectorError(message: "something happened")
    }
}