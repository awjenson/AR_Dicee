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

        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        // Set the view's delegate
        sceneView.delegate = self




//        // Create geometry called cube
//        // Units are meters
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//
//        let sphere = SCNSphere(radius: 0.2)
//
//        let materal = SCNMaterial()
////        materal.diffuse.contents = UIColor.red
//        materal.diffuse.contents = UIImage(named: "art.scnassets/8k_moon")
//
////        cube.materials = [materal]
//        sphere.materials = [materal]
//
//        // Nodes are points in 3D space
//        let node = SCNNode()
//        // for z, negative is going away from you, positive coming towards you
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//
//        // assign geometry
////        node.geometry = cube
//        node.geometry = sphere
//
//        sceneView.scene.rootNode.addChildNode(node)

        sceneView.autoenablesDefaultLighting = true

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        var configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

//        if ARWorldTrackingConfiguration.isSupported {
//            configuration = ARWorldTrackingConfiguration
//        } else {
//            configuration = AROrientationTrackingConfiguration()
//        }

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // Touch detected in view or window
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check if touches was detected or just an error
        if let touch = touches.first {
            // SceneView is where our touch event was initiated
            let touchLocation = touch.location(in: sceneView)

            // convert touch location into 3D location inside our scene
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)

            if let hitResult = results.first {

                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    // Set the scene to the view
                    // y position = how much elevation to give with the plane
                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hitResult.worldTransform.columns.3.z)

                    sceneView.scene.rootNode.addChildNode(diceNode)
                }
            }
        }

    }

    // Detect a horizontal surface and it's given that surface a width and a height which is an AR anchor so we can use it to place things or use it
    // When it detects a horizontal plane, this method will be called
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // An anchor is like a tile, it has a width and a height
        // We want to check if the anchor that was identified is a planeAnchor
        if anchor is ARPlaneAnchor {

            // downcast planeAnchor into the data type ARPlaneAnchor
            let planeAnchor = anchor as! ARPlaneAnchor

            // convert into scenePlane that allows us to create a plane in sceneKit
            // Only put 'x' and 'z' here (Not 'y').
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))

            // Create a plane node
            let planeNode = SCNNode()

            // Y position is 0 because it is a flat horizontal plane
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)

            // Scene planes are detected as vertical, but we want a horizontal plane
            // angle: the angle that you want to rotate it by (counterclockwise)
            // x, y, z: specify along which axis you want to rotate by
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)

            let gridMaterial = SCNMaterial()

            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")

            plane.materials = [gridMaterial]

            planeNode.geometry = plane

            // Add child node into the root node (use node created when this method is called
            node.addChildNode(planeNode)


        } else {
            // return / exit method
            return
        }
    }

}
