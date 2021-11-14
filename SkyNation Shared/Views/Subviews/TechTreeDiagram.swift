//
//  TechTreeDiagram.swift
//  SkyTestSceneKit
//
//  Created by Farini on 9/22/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI

// MARK: - Diagrams

struct DiagramContent: View {
    
    @ObservedObject var controller:LabViewModel
    @State var tree = TechnologyTree().uniqueTree
    @State var station:Station = LocalDatabase.shared.station
    
    var body: some View {
        VStack {
            Diagram(tree: tree, node: { value in
                
                StationTechItemView(item: value.value, status: statusFor(value.value, val: value))
                .onTapGesture {
                    controller.selectedFromDiagram(value.value)
                }
                
            })
        }
    }
    
    func statusFor(_ tech:TechItems, val:(Unique<TechItems>)) -> StationTechStatus {
        
        if self.station.unlockedTechItems.contains(tech) {
            return .researched
        } else if val.isUnlocked(station:station) == true {
            return .unlocked
        } else {
            return .locked
        }
    }
}


struct DiagramContent_Previews: PreviewProvider {
    static var module = LocalDatabase.shared.station.labModules.first ?? LabModule(module: Module(id: UUID(), modex: .mod0))
    static var previews: some View {
        DiagramContent(controller: LabViewModel(lab: module))
        
    }
}

struct CollectDict<Key: Hashable, Value>: PreferenceKey {
    static var defaultValue: [Key:Value] { [:] }
    static func reduce(value: inout [Key:Value], nextValue: () -> [Key:Value]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct Diagram<A: Identifiable, V: View>: View {
    let tree: Tree<A>
    let node: (A) -> V
//    var done:Bool? = false
    
    typealias Key = CollectDict<A.ID, Anchor<CGPoint>>

    var body: some View {
        VStack(alignment: .center) {
            node(tree.value)
               .anchorPreference(key: Key.self, value: .center, transform: {
                   [self.tree.value.id: $0]
               })
            HStack(alignment: .top, spacing: 10) {
                ForEach(tree.children, id: \.value.id, content: { child in
                    Diagram(tree: child, node: self.node)
                })
            }
            
        }.backgroundPreferenceValue(Key.self, { (centers: [A.ID: Anchor<CGPoint>]) in
            GeometryReader { proxy in
                ForEach(self.tree.children, id: \.value.id, content: { child in
                    Line(
                        from: proxy[centers[self.tree.value.id]!],
                        to: proxy[centers[child.value.id]!]
                    ).stroke()
                })
            }
        })
    }
}

struct Line: Shape {
    var from: CGPoint
    var to: CGPoint

    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: self.from)
            p.addLine(to: self.to)
        }
    }
}

public enum StationTechStatus {
    case locked
    case unlocked
    case researched
}

struct StationTechItemView: View {
    
    var item:TechItems
    var status:StationTechStatus
    
    var body: some View {
        VStack(spacing:3) {
            Text(item.shortName)
                .font(GameFont.section.makeFont())
                .padding([.top, .leading, .trailing], 6)
            
            //            Divider()
            //                .frame(width:100)
            Image(systemName: imageName)
                .font(.title)
                .foregroundColor(status == StationTechStatus.researched ? Color.green:Color.white)
            
        }
        .padding(5)
        .background(makeGradient())
        .cornerRadius(5)
        .padding(4)
        
    }
    
    var statusColor:Color {
        switch self.status {
            case .locked: return Color(.sRGB, red: 0.5, green: 0.1, blue: 0.1, opacity: 1.0)
            case .unlocked: return .blue//Color(.sRGB, red: 0.1, green: 0.1, blue: 0.6, opacity: 1.0)
            case .researched: return Color.black.opacity(1.0)
        }
    }
    
    var imageName:String {
        switch self.status {
            case .locked: return "lock"
            case .unlocked: return "lock.open"
            case .researched: return "checkmark.circle"
        }
    }
    
    func makeGradient() -> LinearGradient {
        return LinearGradient(colors: [statusColor, GameColors.darkGray, GameColors.darkGray, Color.black], startPoint: .bottom, endPoint: .top)
    }
    
}

struct StationTech_Previews: PreviewProvider {
    static var previews: some View {
        StationTechItemView(item: TechItems.allCases.randomElement()!, status: .researched)
    }
}
