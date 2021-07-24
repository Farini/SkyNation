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
    @State var station:Station = LocalDatabase.shared.station!
    
    var body: some View {
        VStack {
            Diagram(tree: tree, node: { value in
//                Text("\(value.value.rawValue): \(value.value.getDuration())")
                VStack {
                    
                    Text("\(value.value.shortName)")
                        .font(.callout)
                        .padding([.top, .leading, .trailing], 6)
                    
                    Text("\(value.value.rawValue)")
                        .font(.caption)
                        .foregroundColor(.gray)
//                        .padding([.bottom], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        
                }
                .background(value.isUnlocked(station:station) ? Color.blue:Color.black)
                .cornerRadius(6)
                .padding(6)
                .onTapGesture {
                    controller.selectedFromDiagram(value.value)
                }
                
            })
        }
    }
}

struct DiagramContent_Previews: PreviewProvider {
    static var module = LocalDatabase.shared.station?.labModules.first ?? LabModule(module: Module(id: UUID(), modex: .mod0))
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
