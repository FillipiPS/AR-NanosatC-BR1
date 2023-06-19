//
//  ViewController.swift
//  AR-NanosatC-BR1
//
//  Created by Fillipi Paiva Suszek on 06/12/22.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Completed Nanosatc-BR1" scene from the "Nanosatc" Reality File
        let boxAnchor = try! Nanosatc.loadCompleto()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
    }
}
