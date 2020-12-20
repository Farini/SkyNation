//
//  GameViewController.swift
//  SkyNation iOS
//
//  Created by Carlos Farini on 12/18/20.
//

import UIKit
import SceneKit
import SwiftUI

class GameViewController: UIViewController {

    var gameView: SCNView {
        return self.view as! SCNView
    }
    
    var gameController: GameController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameController = GameController(sceneRenderer: gameView)
        self.gameController.gameNavDelegate = self
        
        // Allow the user to manipulate the camera
        self.gameView.allowsCameraControl = true
        
        // Show statistics such as fps and timing information
        self.gameView.showsStatistics = true
        
        // Configure the view
        self.gameView.backgroundColor = UIColor.black
        
        // Add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        var gestureRecognizers = gameView.gestureRecognizers ?? []
        gestureRecognizers.insert(tapGesture, at: 0)
        self.gameView.gestureRecognizers = gestureRecognizers
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let screenSize = self.view.bounds.size
        let width = screenSize.width
        let height = screenSize.height
        print("\n iOS Screen Size")
        print("Width: \(width) Height: \(height)")
    }
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        // Highlight the tapped nodes
        let p = gestureRecognizer.location(in: gameView)
        gameController.highlightNodes(atPoint: p)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

extension GameViewController:GameNavDelegate {
    
    func didChooseModule(name: String) {
        print("Module View")
        let childView = UIHostingController(rootView:SelectModuleTypeView(name: name))
        present(childView, animated: true, completion: nil)
    }
    
    func didSelectLab(module: LabModule) {
        print("Lab View")
        let controller = UIHostingController(rootView: LaboratoryView(module: module))
        present(controller, animated: true, completion: nil)
    }
    
    func didSelectHab(module: HabModule) {
        print("Hab View")
        let controller = UIHostingController(rootView: HabModuleView(module: module))
        controller.modalPresentationStyle = .currentContext
        controller.view.frame = CGRect(origin: .zero, size: CGSize(width: 800, height: 600))
        controller.view.center = view.center
        present(controller, animated: true, completion: nil)
    }
    
    func didSelectBio(module: BioModule) {
        print("Bio View")
    }
    
    func didSelectTruss(station: Station) {
        print("Truss View")
    }
    
    func didSelectGarage(station: Station) {
        print("Garage View")
    }
    
    func didSelectAir() {
        print("Air selected :)")
//        self.performSegue(withIdentifier: "suiHost", sender: <#T##Any?#>)
        let childView = UIHostingController(rootView: LifeSupportView())
//        childView.modalPresentationStyle = .overCurrentContext
        present(childView, animated: true, completion: nil)
        
//        childView.view.frame = CGRect(origin: .zero, size: CGSize(width: 800, height: 600))
//        childView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        childView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//
//        addChild(childView)
//
//        view.addSubview(childView.view)
//        childView.didMove(toParent: self)
//
//        let vc = UIHostingController(rootView: LifeSupportView())
//        vc.prese
    }
    
    func didSelectEarth() {
        print("Earth Order")
        
        let childView = UIHostingController(rootView:EarthRequestView())
        childView.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childView.view)
        childView.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        childView.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        childView.didMove(toParent: self)
        
        
//        present(childView, animated: true, completion: nil)
    }
    
    
    
}
