//
//  ViewController.swift
//  LearnLang2
//
//  Created by Xinyue Amanda Li on 1/24/20.
//  Copyright © 2020 Xinyue Amanda Li. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSKViewDelegate {
    
    let model = ImageClassifier()
    
    @IBOutlet var sceneView: ARSKView!
    
    @IBOutlet weak var languagePicker: UISegmentedControl!
    
    var mlpredictiontext: String = ""
    
    let translationArray: [String: [String]] = ["backpack": ["la mochila", "书包"], "bookcase": ["la estantería", "书架"], "calculator": ["la calculadora", "计算器"], "carpet": ["la alfombra", "地毯"], "clock": ["el reloj", "钟"], "computer": ["la computadora", "计算机"], "curtain,window shade": ["la cortina", "窗帘"], "door": ["la puerta", "门"], "drinking cup": ["el vaso", "杯子"], "floor": ["el suelo", "地板"], "lamp": ["la lámpara", "灯"], "notebook": ["el cuaderno", "笔记本"], "paper": ["el papel", "纸"], "pencil": ["el lápiz", "铅笔"], "phone": ["el teléfono", "电话"], "shoe": ["los zapatos", "鞋子"], "wall": ["la pared", "墙"], "watch": ["el reloj", "手表"], "water bottle": ["la botella de agua", "水瓶"]]
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        
        self.view.addSubview(languagePicker)
        sceneView.bringSubviewToFront(languagePicker)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        
        let spriteNode = SKLabelNode(text: "")
        spriteNode.fontColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1)
        spriteNode.fontName = "Helvetica-Bold"
        spriteNode.isUserInteractionEnabled = true
        let pixbuff: CVPixelBuffer? = sceneView.session.currentFrame?.capturedImage
        if pixbuff != nil {
            getPredictionFromModel(cvbuffer: pixbuff!)
            spriteNode.text = "\(mlpredictiontext)"
            let audio = SKAction.playSoundFileNamed("\(mlpredictiontext).m4a", waitForCompletion: false)
                spriteNode.run(audio)
            spriteNode.horizontalAlignmentMode = .center
            spriteNode.verticalAlignmentMode = .center
        } else {
            spriteNode.text = "FAILED!"
            spriteNode.horizontalAlignmentMode = .center
            spriteNode.verticalAlignmentMode = .center
        }
        return spriteNode
    }
    
    func getPredictionFromModel(cvbuffer: CVPixelBuffer?){
        do {
            let object = try model.prediction(image: cvbuffer!)
            let objInEng = object.classLabel
            let index = languagePicker.selectedSegmentIndex
            if index == 1{
                //in spanish
                for key in translationArray.keys{
                    if key == objInEng{
                        mlpredictiontext = translationArray[key]![0]
                    }
                }
            } else if index == 2{
                //in chinese
                for key in translationArray.keys{
                    if key == objInEng{
                        mlpredictiontext = translationArray[key]![1]
                    }
                }
            } else if index == 0{
                mlpredictiontext = objInEng
            }
        } catch {
            print(error)
        }
    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
