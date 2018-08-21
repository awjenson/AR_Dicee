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

    // MARK: - IB Outlets
    @IBOutlet var sceneView: ARSCNView!

    // MARK: - Properites

    var diceArray = [SCNNode]()

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self

        sceneView.autoenablesDefaultLighting = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        var configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - Dice Rendering Methods

    // Touch detected in view or window
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check if touches was detected or just an error
        if let touch = touches.first {
            // SceneView is where our touch event was initiated
            let touchLocation = touch.location(in: sceneView)

            // convert touch location into 3D location inside our scene
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)

            if let hitResult = results.first {
                addDice(atLocation: hitResult)
            }
        }
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }

    func addDice(atLocation location: ARHitTestResult) {

        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            // Set the scene to the view
            // y position = how much elevation to give with the plane
            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z: location.worldTransform.columns.3.z)

            // Every time we create a diceNode, we append it to the diceArray
            diceArray.append(diceNode)

            sceneView.scene.rootNode.addChildNode(diceNode)

            roll(dice: diceNode)
        }
    }

    func roll(dice: SCNNode) {
        // generate random number from 1 to 4
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)

        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)

        // added * 5 to increase speed of spin
        dice.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX * 5),
            y: 0,
            z: CGFloat(randomZ * 5),
            duration: 0.5))
    }

    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }

    // MARK: - IB Actions

    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {

        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }

    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }

    // MARK: - ARSceneViewDelegateMethods

    // Detect a horizontal surface and it's given that surface a width and a height which is an AR anchor so we can use it to place things or use it
    // When it detects a horizontal plane, this method will be called
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        // An anchor is like a tile, it has a width and a height
        // We want to check if the anchor that was identified is a planeAnchor
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}

        let planeNode = createPlane(withPlaneAnchor: planeAnchor)

        // Add child node into the root node (use node created when this method is called
        node.addChildNode(planeNode)
    }

    // MARK: - Plane Rendering Methods

    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {

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

        return planeNode
    }
}
