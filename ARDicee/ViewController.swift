//
//  ViewController.swift
//  ARDicee
//
//  Created by Andrew Jenson on 8/17/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        // Create geometry called cube
        // Units are meters
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)

        let sphere = SCNSphere(radius: 0.2)

        let materal = SCNMaterial()
//        materal.diffuse.contents = UIColor.red
        materal.diffuse.contents = UIImage(named: "art.scnassets/8k_moon")

//        cube.materials = [materal]
        sphere.materials = [materal]

        // Nodes are points in 3D space
        let node = SCNNode()
        // for z, negative is going away from you, positive coming towards you
        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)

        // assign geometry
//        node.geometry = cube
        node.geometry = sphere

        sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true

//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        print("World Tracking is supported = \(ARWorldTrackingConfiguration.isSupported)")

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

}
