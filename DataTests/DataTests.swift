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
    
    func testGameGenerators() {
        
        print("\n Game Generators --- ")
        
        print("\n[] People")
        let delta = Date().timeIntervalSince(LocalDatabase.shared.gameGenerators!.datePeople)
        let oo = Calendar.current.dateComponents([.minute, .second], from: LocalDatabase.shared.gameGenerators!.datePeople, to: Date())
        print("Time (seconds) since last generation: \(delta)")
        print("Time 2: \(oo.minute ?? 0)m \(oo.second ?? 0)s")
        
        print("\n[] Freebie")
        let dFree = Date().timeIntervalSince(LocalDatabase.shared.gameGenerators!.dateFreebies)
        let tFree = Calendar.current.dateComponents([.minute, .second], from: LocalDatabase.shared.gameGenerators!.datePeople, to: Date())
        print("Time (seconds) since last generation: \(dFree)")
        print("Time 2: \(tFree.minute ?? 0)m \(tFree.second ?? 0)s")
        print("\n\n")
    }
    
    // MARK: - Accounting
    
    func testAccounting() throws {
        
        print("\n --- Accounting Start ---")
        
        
        GameSettings.shared.debugAccounting = true
        let station = LocalDatabase.shared.station
        
        // Part 1 (Validation)
        XCTAssertNotNil(station)
        
        //        let tsResult = station!.acc
        //        print("Timesheet result: \(tsResult.loops)")
        
        station?.accountingLoop(recursive: true) { errors in
            print("Errors: \(errors)")
            print("code completion")
        }
        
        //        station?.runAccounting()
        //
        //        let report = station?.accounting
        //        print("\n [Accounting report] ")
        //        for item in report?.problems ?? [] {
        //            print(" +⚠️ \(item)")
        //        }
        //        for item in report?.notes ?? [] {
        //            print(" +[N] \(item)")
        //        }
        //        for item in report?.humanNotes ?? [] {
        //            print(" +[H] \(item)")
        //        }
        //        for item in report?.peripheralNotes ?? [] {
        //            print(" +[P] \(item)")
        //        }
        
        print("\n --- Accounting End ---")
    }
    
    // MARK: - Peripherals
    
    func testAntennaLevel() throws {
        
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
    
    // MARK: - Humans
    
    func testWillingnessToStudy() {
        
        for idx in 0...25 {
            let p1 = Person(random: true)
            print("\n [\(idx)] *** 🙋‍♂️ Person \(p1.name) | age: \(p1.age) | skills: \(p1.skills.map({ $0.skill.rawValue}).joined(separator: ", "))")
            
            let w1 = p1.willingnessToStudy()
            print("Willing to study: \(w1) | skills:\(p1.sumOfSkills())")
            p1.learnNewSkill(type: Skills.allCases.randomElement()!)
            
            let w2 = p1.willingnessToStudy()
            print("Willing to study: \(w2) | skills:\(p1.sumOfSkills())")
            p1.learnNewSkill(type: Skills.allCases.randomElement()!)
            
            let w3 = p1.willingnessToStudy()
            print("Willing to study: \(w3) | skills:\(p1.sumOfSkills())")
            p1.learnNewSkill(type: Skills.allCases.randomElement()!)
            
            let w4 = p1.willingnessToStudy()
            print("Willing to study: \(w4) | skills:\(p1.sumOfSkills())")
            p1.learnNewSkill(type: Skills.allCases.randomElement()!)
            
            let w5 = p1.willingnessToStudy()
            print("Willing to study: \(w5) | skills:\(p1.sumOfSkills())")
            p1.learnNewSkill(type: Skills.allCases.randomElement()!)
            
            print("🙋‍♂️ Person \(p1.name) | age: \(p1.age) | skills: \(p1.skills.map({ $0.skill.rawValue}).joined(separator: ", "))")
        }
    }
    
    // MARK: - Bugs
    
    func testDateWeirdness() throws {
        
        let now = Date()
        let date2 = now.addingTimeInterval(3600)
        let formatter = GameFormatters.dateFormatter
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        let s1 = formatter.string(from: now)
        let s2 = formatter.string(from: date2)
        
        print("Dates")
        print(s1)
        print(s2)
        
    }
    
    // MARK: - Performance
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
            
        }
    }

}
