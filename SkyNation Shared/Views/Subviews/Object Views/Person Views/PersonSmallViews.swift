//
//  PersonSmallViews.swift
//  SkyNation
//
//  Created by Carlos Farini on 11/21/21.
//

import SwiftUI

struct PersonSmallView:View {
    
    var person:Person
    @State var selected:Bool = false
    
    private let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
    private let unselectedColor:Color = Color.white.opacity(0.4)
    private let selectedColor:Color = Color.blue
    
    var body: some View {
        
        HStack {
            Image(person.avatar)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
                .padding([.leading], 6)
            
            VStack(alignment: .leading, spacing: 2) {
                
                HStack {
                    Text(person.name)
                        .font(.headline)
                    Text("\(person.age)").font(GameFont.mono.makeFont())
                        .foregroundColor(.gray)
                }
                
                ProgressView(value: Float(person.intelligence), total:100.0) {
                    HStack {
                        ForEach(person.skills.compactMap({ $0.skill }), id:\.self) { skill in
                            GameImages.imageForSkill(skill:skill)
                                .resizable()
                                .aspectRatio(contentMode:.fit)
                                .frame(width:22, height:22)
                        }
                        
                    }
                }
                .foregroundColor(.blue)
                .accentColor(.orange)
                
            }
            .padding([.trailing], 8)
        }
        .frame(minWidth: 80, maxWidth: 190, minHeight: 56, maxHeight: 72, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .padding([.top, .leading, .bottom], 4)
        .background(Color.black.opacity(0.5))
        .overlay(
            shape
                .inset(by: selected ? 1.0:0.5)
                .stroke(selected ? selectedColor:unselectedColor, lineWidth: selected ? 1.5:1.0)
        )
    }
}

struct PersonOrderView:View {
    
    var person:Person
    
    var body: some View {
        
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            
            HStack {
                
                ZStack(alignment:.bottomLeading) {
                    
                    Image(person.avatar)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 56, height: 56)
                        .padding([.leading], 6)
                    
                    HStack {
                        
                        Text("🎂 \(person.age)").font(GameFont.mono.makeFont())
                            .font(Font.system(size: 9, weight: .bold, design: .monospaced))
                            .padding(2)
                            .padding(.horizontal, 4)
                            .background(Color.black.opacity(0.6))
                            .offset(x: 0, y: 3)
                        Spacer()
                        
                    }
                    .frame(width: 60)
                }
                
                
                VStack(alignment: .leading, spacing: 2) {
                    
                    HStack {
                        Text(person.name)
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.top, 4)
                    
                    ProgressView(value: Float(person.intelligence), total:100.0) {
                        HStack {
                            let map = person.skills.compactMap({ $0.skill })
                            ForEach(map, id:\.self) { skill in
                                GameImages.imageForSkill(skill: skill)
                                    .resizable()
                                    .aspectRatio(contentMode:.fit)
                                    .frame(width:22, height:22)
                            }
                            Spacer()
                            Text("$\(GameLogic.orderPersonPrice)")
                                .foregroundColor(.gray)
                                .background(Color.black)
                        }
                    }
                    .foregroundColor(.blue)
                    .accentColor(.orange)
                    
                }
                .padding([.trailing], 6)
            }
        }
        .padding(2)
        .background(Color.black)
        .cornerRadius(8)
        .frame(maxWidth:200)
    }
}

struct PersonSmall_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            PersonSmallView(person: makePerson())
            PersonSmallView(person: makePerson(), selected:true)
        }
    }
    
    /// Makes a person with more than 1 skill
    static func makePerson() -> Person {
        let p = Person(random: true)
        p.skills.append(.init(skill: .Biologic, level: 1))
        p.skills.append(.init(skill: .Medic, level: 2))
        return p
    }
}

struct PersonOrder_Preview: PreviewProvider {
    static var previews: some View {
        PersonOrderView(person: Person(random: true))
    }
}
