//
//  DirectionFieldTests.swift
//  DirectionFieldTests
//
//  Created by Eli Selkin on 12/27/15.
//  Copyright © 2015 DifferentialEq. All rights reserved.
//

import XCTest
@testable import DirectionField

class DirectionFieldTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        do {
            try print(Complex(realimag: "0.00+0.1i")/Complex(r: 2.0, i: 0.1))
            let matrix = TwoDimMatrix(a11: Complex(r: 1.0, i: 0.0), a12: Complex(r: 2.0, i: 0.0), a21: Complex(r: 4.0, i: 0.0), a22: Complex(r: 1.0, i: 0.0), a13: Complex(r: 3.0, i: 0.0), a23: Complex(r: 6.0, i: 0.0))
            matrix.swapRows()
            print(matrix.description)
            let complex1 = matrix.getValueAt(1, col: 2)
            print(complex1.real.description)
            print("Is zero: " + matrix.getValueAt(1, col: 2).isZero().description)
            let complex = matrix.getValueAt(1, col: 2)
            print(complex.real.description)
            
        } catch {
            print("oops")
        }
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let a = TwoDimMatrix(a11: Complex(r: -0.9, i: 0.0), a12: Complex(r: -1.0, i: 0.0), a21: Complex(r: -0.1, i: 0.0), a22: Complex(r: 2.0, i: 0.0), a13: Complex(r: 0.0, i: 0.0), a23: Complex(r: 0.0, i: 0.0))
        print(a)
        do {
            //let b = try gaussianElimination(a)
            let (c, d) = try eigenVectors(a)
            // XCTAssert(b!.description.containsString("[[[+1.0000+0.0000i],[-2.0000-0.0000i]], [[+1.0000+0.0000i],[+2.0000+0.0000i]]]"))
            //print (b.description)
            print (c?.description)
            print (d?.description)
        } catch {
            //
            print(error)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
