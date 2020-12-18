//  SkillData.swift
//  SKN3: Created by carlos farini on 5/8/18.
//  Copyright © 2018 Farini. All rights reserved.

/*
import CloudKit


class SkillData: NSObject, NSCoding {
    
    var exact:Int
    var human:Int
    var biology:Int
    var pilot:Int
    
    var specialities:[String:Int]
    
    override init() {
        self.exact = 0
        self.human = 0
        self.biology = 0
        self.pilot = 0
        
        self.specialities = [:]
        super.init()
    }
    
    func addRandomKnowledge(maximum:Int, subject:String?){
//        let rnd = Int(arc4random_uniform(UInt32(maximum - 1))) + 1 // At least 1
        // Subfunction that returns a random number
        
        func rndKnowledgeAmount(top:Int) -> Int{
            return Int(arc4random_uniform(UInt32(maximum - 1))) + 1 // At least 1
        }
        
        if let aSubject = subject{
            switch aSubject{
                case "exact": self.exact = rndKnowledgeAmount(top: maximum)
                case "human": self.human = rndKnowledgeAmount(top: maximum)
                case "biology": self.biology = rndKnowledgeAmount(top: maximum)
                case "pilot": self.pilot = rndKnowledgeAmount(top: maximum)
                default:                            // Default means all.
                self.exact = rndKnowledgeAmount(top: maximum)
                self.biology = rndKnowledgeAmount(top: maximum)
                self.pilot = rndKnowledgeAmount(top: maximum)
            }
        }else{
            let arrayOfSubjects = ["exact", "human", "biology", "pilot", "all"]
            let randomSubject = arrayOfSubjects.randomElement()!
            switch randomSubject{
                case "exact": self.exact = rndKnowledgeAmount(top: maximum)
                case "human": self.human = rndKnowledgeAmount(top: maximum)
                case "biology": self.biology = rndKnowledgeAmount(top: maximum)
                case "pilot": self.pilot = rndKnowledgeAmount(top: maximum)
                default:                            // Default means all.
                    self.exact = rndKnowledgeAmount(top: maximum)
                    self.biology = rndKnowledgeAmount(top: maximum)
                    self.pilot = rndKnowledgeAmount(top: maximum)
            }
        }
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.exact, forKey: "exact")
        aCoder.encode(self.human, forKey: "human")
        aCoder.encode(self.biology, forKey:"biology")
        aCoder.encode(self.pilot, forKey:"pilot")
        
        aCoder.encode(self.specialities, forKey:"specialities")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.exact = aDecoder.decodeInteger(forKey: "exact")
        self.human = aDecoder.decodeInteger(forKey: "human")
        self.biology = aDecoder.decodeInteger(forKey: "biology")
        self.pilot = aDecoder.decodeInteger(forKey: "pilot")
        
        self.specialities = (aDecoder.decodeObject(forKey: "specialities") as! [String:Int])
    }
    
    
}
*/

