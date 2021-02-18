//
//  DataTests.swift
//  DataTests
//
//  Created by Carlos Farini on 12/18/20.
//

import XCTest

class DataTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let qtty = 10
        print("Quantity: \(qtty)")
    }
    
    func testAntennaLevel() {
        let antenna = PeripheralObject(peripheral: .Antenna)
        let level = antenna.level
//        let money = GameLogic.fibonnaci(index: level)
        
        let fixedProfits:Int = 300
        let variableProfits:Int = 100 * GameLogic.fibonnaci(index: antenna.level)
        let totalProfits = fixedProfits + variableProfits
        
        print("\n\n\t Antenna Profits ======== ")
        while antenna.level < 5 {
            print("Antenna level:\(level)\t = \(fixedProfits) + \(variableProfits) = \(totalProfits)")
            antenna.level += 1
        }
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
