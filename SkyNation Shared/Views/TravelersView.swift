//
//  TravelersView.swift
//  SkyTestSceneKit
//
//  Created by Farini on 10/24/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import SwiftUI
import SpriteKit
//import SpriteView

struct TravelersView: View {
    
    var body: some View {
        SpriteKitContainer(scene: self.scene)
            .frame(width: 600, height: 400)
//            .edgesIgnoringSafeArea(.all)
        
    }
    
    var scene:SKScene {
        let scene = TravelersScene(size: CGSize(width: 600, height: 400))
//        scene.size =
//        scene.scaleMode = .fill
        return scene
    }
}

struct TravelersView_Previews: PreviewProvider {
    static var previews: some View {
        TravelersView()
    }
}

#if os(macOS)
struct SpriteKitContainer: NSViewRepresentable {
    
    typealias NSViewType = SKView
//    typealias UIViewType = SKView
    
    var skScene: SKScene!
    
    init(scene: SKScene) {
        skScene = scene
//        self.skScene.scaleMode = .aspectFill
    }
    
    class Coordinator: NSObject {
        var scene: SKScene?
    }
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.scene = self.skScene
        return coordinator
    }
    
    // MARK: - Make Views
    
    
    func makeNSView(context: Context) -> SKView {
        
        let view = SKView(frame: .zero)
        view.preferredFramesPerSecond = 60
        view.showsFPS = true
        view.showsNodeCount = true
        return view
    }
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: .zero)
        view.preferredFramesPerSecond = 60
        view.showsFPS = true
        view.showsNodeCount = true
        return view
    }
    
    
    /*
    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: .zero)
        view.preferredFramesPerSecond = 60
        view.showsFPS = true
        view.showsNodeCount = true
        return view
    }
    */
    
    // MARK: - Updates
    /*
    func updateUIView(_ view: SKView, context: Context) {
        view.presentScene(context.coordinator.scene)
    }
    */
    
    func updateNSView(_ nsView: SKView, context: Context) {
        nsView.presentScene(context.coordinator.scene)
    }
}

#else

struct SpriteKitContainer: UIViewRepresentable {
    
    typealias NSViewType = SKView
    //    typealias UIViewType = SKView
    
    var skScene: SKScene!
    
    init(scene: SKScene) {
        skScene = scene
        //        self.skScene.scaleMode = .aspectFill
    }
    
    class Coordinator: NSObject {
        var scene: SKScene?
    }
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.scene = self.skScene
        return coordinator
    }
    
    // MARK: - Make Views
    
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: .zero)
        view.preferredFramesPerSecond = 60
        view.showsFPS = true
        view.showsNodeCount = true
        return view
    }
    
  
    
    // MARK: - Updates
    
     func updateUIView(_ view: SKView, context: Context) {
        view.presentScene(context.coordinator.scene)
     }
     
   
}

#endif
