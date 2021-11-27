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
    
    func testTokens() {
        
        let myPID:UUID = UUID()
        let store = Wallet(lid: myPID)
        print("My Store")
        print("Token count: \(store.tokens.count)")
        
        for t in store.tokens {
            print("Token \(t.origin), DBPlayer ID:\(t.dbUser), TokenID:\(t.id)")
        }
        let player = LocalDatabase.shared.player
        
        for i in 1...5 {
            if let token = player.requestToken() {
                let result = player.spendToken(token: token, save: false)
                print("Using token #\(i): \(result)")
            }
        }
        if store.timeToGenerateNextFreebie() < 1.0 {
            let dict = store.generateFreebie()
            print("Free dic.: \(dict.description)")
        }
        let time = store.timeToGenerateNextFreebie()
        print("Next Freebie Generation in \(time) seconds")
        XCTAssert(time > 0)
        
        print("Making Purchase")
        store.makePurchase(cart: Purchase(product: .five, kit: .SurvivalKit, receipt: "ABCD"))
        print("Count after purchase: \(store.tokens.count)")
        print("Valid Tokens: \(player.countTokens().count)")
    }
    
    func testFreebies() {
        
        print("\n\n * Testing Freebies + Dates")
        
        let player = LocalDatabase.shared.player
        
        let lastDate = player.wallet.freebiesLast // player.lastSeen
        let df = GameFormatters.dateFormatter
        let lastString = df.string(from: lastDate)
        
        print("Date Last Freebies: \(lastString)")
        
        let delta:Double = player.wallet.timeToGenerateNextFreebie()
        print("Delta: \(delta)")
        
        let dayAgo = Date().addingTimeInterval(TimeInterval.oneDay * -1.0)
        let dayAgoString = df.string(from: dayAgo)
        print("Day Ago: \(dayAgoString)")
        
        print("\n Finished Testing Freebies \n\n")
        
    }
    
    func testOutpostContribution() {
        
        print("\n\n Testing Outpost Contribution.")
        //        guard LocalDatabase.shared.player != nil else {
//            print("Failed test. No Player")
//            return
//        }
        
        let outpost = Outpost(type: .Energy, posdex: .power1, guild: UUID())
        if let job = outpost.getNextJob() {
            print("Job in.: Max score:\(job.maxScore())")
            print("\t Ingredients")
            for (ing, value) in job.wantedIngredients {
                print("\(ing) : \(value)")
                let supplied = outpost.supplied.ingredients.filter({ $0.type == ing}).compactMap({$0.current}).reduce(0, +)
                print("Supplied : \(supplied) of \(value)")
            }
        }
        
        /*
        outpost.supplied.contribute(with: StorageBox(ingType: .SolarCell, current: Ingredient.SolarCell.boxCapacity()), player: player)
        outpost.supplied.contribute(with: StorageBox(ingType: .SolarCell, current: 186), player: player)
        outpost.supplied.contribute(with: StorageBox(ingType: .Aluminium, current: 20), player: player)
        outpost.supplied.contribute(with: StorageBox(ingType: .Circuitboard, current: 20), player: player)
        outpost.supplied.contribute(with: StorageBox(ingType: .Polimer, current: 50), player: player)
        */
        
        let p1 = Person(random: true)
        p1.name = "Genius"
        p1.learnNewSkill(type: .Material)
        p1.learnNewSkill(type: .Material)
        p1.learnNewSkill(type: .Material)
        p1.learnNewSkill(type: .Material)
        p1.learnNewSkill(type: .Material)
        p1.learnNewSkill(type: .Material)
        p1.learnNewSkill(type: .Material)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        p1.learnNewSkill(type: .Handy)
        
        p1.learnNewSkill(type: .Handy)
        
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        p1.learnNewSkill(type: .Electric)
        
//        outpost.supplied.contribute(with: p1, player: player)
        
        print("\n Genius:")
        for sks in p1.skills {
            print("\(sks.skill): \(sks.level)")
        }
        
        
        if let job = outpost.getNextJob() {
            print("Job in.: Max score:\(job.maxScore())")
            print("\t Ingredients")
            for (ing, value) in job.wantedIngredients {
                print("\(ing) : \(value)")
                let supplied = outpost.supplied.ingredients.filter({ $0.type == ing}).compactMap({$0.current}).reduce(0, +)
                print("Supplied : \(supplied) of \(value)")
            }
        }
        
        print("\nMissing")
        let missing = outpost.calculateRemaining()
        print(missing)
        
        print("\n Score Card")
        let scoreCard = outpost.supplied.players
        print(scoreCard.description)
        
        print("\n Upgrade 1")
        let firstUpgrade = outpost.runUpgrade()
        switch firstUpgrade {
            case .noChanges: print("No Changes, Current State: \(outpost.state)")
            case .dateUpgradeShouldBeNil, .needsDateUpgrade: print("Error")
            case .nextState(let state): print("Next State >>> \(state)")
            case .applyForLevelUp(currentLevel: let level): print("Should Apply for level up. Current:\(level), next:\(level + 1)")
        }
        
        print("\n Upgrade 2")
        let secondUpgrade = outpost.runUpgrade()
        switch secondUpgrade {
            case .noChanges: print("No Changes, Current State: \(outpost.state)")
            case .dateUpgradeShouldBeNil, .needsDateUpgrade: print("Error")
            case .nextState(let state): print("Next State >>> \(state)")
            case .applyForLevelUp(currentLevel: let level): print("Should Apply for level up. Current:\(level), next:\(level + 1)")
        }
        print("\n Stats ---")
        print("Current State: \(outpost.state), Level:\(outpost.level)")
        print("Upgrade: \(firstUpgrade)")
        
        if let _ = outpost.getNextJob() {
            print("Next job. Level:\(outpost.level), State:\(outpost.state)")
        }
        
        
        let expectation = self.expectation(description: "Async call")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 8.0) {
            print("\n Results after wait...")
            print("Upgrade 3")
            let upgrade3 = outpost.runUpgrade()
            switch upgrade3 {
                case .noChanges: print("No Changes")
                case .dateUpgradeShouldBeNil, .needsDateUpgrade: print("Error")
                case .nextState(let state): print("Next State: \(state)")
                case .applyForLevelUp(currentLevel: let level): print("Should Apply for level up. Current:\(level), next:\(level + 1)")
//                default: print("Not ready")
            }
            
            print("\n Upgrade 4")
            let upgrade4 = outpost.runUpgrade()
            switch upgrade4 {
                case .noChanges: print("No Changes")
                case .dateUpgradeShouldBeNil, .needsDateUpgrade: print("Error")
                case .nextState(let state): print("Next State: \(state)")
                case .applyForLevelUp(currentLevel: let level): print("Should Apply for level up. Current:\(level), next:\(level + 1)")
                //                default: print("Not ready")
            }
            print("\n")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10)
        
        
    }
    
    /** Tests if there is common strings between tanktype, ingredient, DNAOption and Skills,
     If this test fails, it makes building this game much harder. */
    func testModelTypesNames() {
        
        let allTanks = TankType.allCases
        let allIngredients = Ingredient.allCases
        let dnas = DNAOption.allCases
        
        var array:[String] = []
        
        print("\n\n Testing Model Types Names...")
        
        print("\n\t Tank Types:")
        for t in allTanks {
            print(t.rawValue)
            array.append(t.rawValue)
        }
        
        print("\n\t Ingredient Types:")
        for i in allIngredients {
            print(i.rawValue)
            array.append(i.rawValue)
        }
        
        print("\n\t DNA Types:")
        for d in dnas {
            print(d.rawValue)
            array.append(d.rawValue)
        }
        
        print("\n\t Peripheral Types:")
        for p in PeripheralType.allCases {
            print(p.rawValue)
            array.append(p.rawValue)
        }
        
        // Skills
        print("\n\t Skills Types:")
        for s in Skills.allCases {
            print(s.rawValue)
            array.append(s.rawValue)
        }
        
        // Tech
//        print("\n Tech Types:")
//        for t in TechItems.allCases {
//            print(t.rawValue)
//        }
        
//        for s in array {
//            print(s)
//        }
        print("\n---- results  -----")
        print("Array Count: \(array.count)")
        
        let aSet = Set(array)
        print("Set Count: \(aSet.count)")
        print("---- results end  -----\n\n")
        
        XCTAssert(array.count == aSet.count)
        
        
    }
    
    // MARK: - Accounting
    
    func testAccounting() throws {
        
        print("\n --- Accounting Start ---")
        
//        GameSettings.shared.debugAccounting = true
        let station = LocalDatabase.shared.station
        
        // Part 1 (Validation)
        XCTAssertNotNil(station)
        
        station.accountingLoop(recursive: true) { errors in
            print("Errors: \(errors)")
            print("code completion")
        }
        
        print("\n --- Accounting End ---")
    }
    
    // MARK: - Peripherals
    
    func testAntennaLevel() throws {
        
        let antenna = PeripheralObject(peripheral: .Antenna)
        let fixedProfits:Int = 300
        print("\n\n\t Antenna Profits ======== ")
        while antenna.level < 5 {
            let variableProfits:Int = 80 * GameLogic.fibonnaci(index: antenna.level + 1)
            let totalProfits = fixedProfits + variableProfits
            print("Antenna level:\(antenna.level)\t = \(fixedProfits) + \(variableProfits) = \(totalProfits)")
            antenna.level += 1
        }
    }
    
    func testOutposts() throws {
        print("\n\n\t Outpost Test -----\n.")
        
        print("ENERGY:")
        let op1 = Outpost(type: .Energy, posdex: .power1, guild:nil)
        while let job = op1.getNextJob() {
            print("Next Job @lvl: \(op1.level)")
            print("Ingredients")
            print(job.wantedIngredients)
            print("Skills")
            print(job.wantedSkills)
            print("Output: \(op1.energy()) KW/h \n")
            op1.level += 1
        }
        
        print("\n\nWATER:")
        let op2 = Outpost(type: .Water, posdex: .mining2, guild: nil)
        while let job = op2.getNextJob() {
            print("Next Job @lvl: \(op2.level)")
            print("Ingredients")

            for (ing, val) in job.wantedIngredients {
                print("\t \(ing.rawValue):\(val)")
            }
            print("Skills")
            for (sk, lvl) in job.wantedSkills {
                print("\t \(sk.rawValue):\(lvl)")
            }
            print("Energy: \(op2.energy()) KW/h")
            print("Output")
//            for (k, v) in op2.produceIngredients() {
//                print("\t\(k.rawValue):\(v)")
//            }
            
            op2.level += 1
        }
        
        print("\n\nSILICA:")
        let op3 = Outpost(type: .Silica, posdex: .mining1, guild: nil)
        while let job = op3.getNextJob() {
            print("Next Job @lvl: \(op3.level)")
            print("Ingredients")

            for (ing, val) in job.wantedIngredients {
                print("\t \(ing.rawValue):\(val)")
            }
            print("Skills")
            for (sk, lvl) in job.wantedSkills {
                print("\t \(sk.rawValue):\(lvl)")
            }
            print("Energy: \(op3.energy()) KW/h")
            print("Output")
//            for (k, v) in op3.produceIngredients() {
//                print("\t\(k.rawValue):\(v)")
//            }
            
            op3.level += 1
        }
        
        print("\n\nBIO:")
        let op4 = Outpost(type: .Biosphere, posdex: .biosphere1, guild: nil)
        while let job = op4.getNextJob() {
            print("Next Job @lvl: \(op4.level)")
            print("Ingredients")

            for (ing, val) in job.wantedIngredients {
                print("\t \(ing.rawValue):\(val)")
            }
            print("Skills")
            for (sk, lvl) in job.wantedSkills {
                print("\t \(sk.rawValue):\(lvl)")
            }
            print("Energy: \(op4.energy()) KW/h")
            print("Output")
//            for (k, v) in op4.produceIngredients() {
//                print("\t\(k.rawValue):\(v)")
//            }
            
            op4.level += 1
        }
    }
    
    // MARK: - Humans
    
    func testWillingnessToStudy() throws {
        
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
    
    // guild missions
    func testGuildMission() {
        
        let mission = GuildMission()
        mission.start = Date(timeIntervalSinceNow: -300)
        
        let contrib1 = UUID()
        let contribu2 = UUID()
        let page = mission.pageOf()
        
        let vvv = "\(mission.mission.rawValue), page:\(page.page), of \(page.total)"
        print("Start: \(vvv) \t Ends:\(mission.calculatedEnding().timeIntervalSinceNow)")
        
        // contrib 1
        mission.makeProgress(pid: contrib1)
        print("Contr 1: \t Ends:\(mission.calculatedEnding().timeIntervalSinceNow) + \(mission.mission.rawValue), page:\(page.page), of \(page.total)")
        
        // contrib 2
        mission.makeProgress(pid: contribu2)
        print("Contr 2: \t Ends:\(mission.calculatedEnding().timeIntervalSinceNow) + \(mission.mission.rawValue), page:\(page.page), of \(page.total)")
        
        for i in 0...150 {
            let newPlayer = UUID()
            print("Contrib # \(i). \(mission.mission.rawValue), page:\(mission.currentTask), remains: \(mission.needsTasks())")
            mission.makeProgress(pid: newPlayer)
        }
        
        print("Expecting...")
        
        let expectation = self.expectation(description: "Async call")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 8.0) {
            print("\n Results after wait...")
            
            for i in 0...85 {
                let newPlayer = UUID()
                print("Contrib 2 # \(i). \(mission.mission.rawValue), page:\(mission.currentTask), remains: \(mission.needsTasks())")
                mission.makeProgress(pid: newPlayer)
            }
            print("\n")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15)
        
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
