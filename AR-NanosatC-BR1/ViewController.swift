//
//  ViewController.swift
//  AR-NanosatC-BR1
//
//  Created by Fillipi Paiva Suszek on 06/12/22.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!

    let coachingOverlay = ARCoachingOverlayView()
    var configuration: ARWorldTrackingConfiguration?
    private var isAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Prevent the screen from being dimmed to avoid interrupting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true

        setupARViewConfiguration()
        setupCoachingOverlay()
        setupARViewAction()
    }

    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        print("handleTap")

        let location = recognizer.location(in: arView)

        if let hitEntity = self.arView.entity(at: location) {
            print("hitEntity")
            guard let entity = hitEntity as? HasCollision else { return }
            self.arView.installGestures(.all, for: entity)
            print("sucess")
        }

        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        guard !isAdded else { return }

        if let firstResult = results.first {
            // Add an ARAnchor at the touch location with a special name you check later in `session(_:didAdd:)`.
            let anchor = ARAnchor(name: "NanosatctAncor", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
            isAdded = true
        } else {
            print("Can't place object - no surface found.\nLook for flat surfaces.")
            print("Warning: Object placement failed.")
        }
    }

    private func setupARViewConfiguration() {
        arView.session.delegate = self
        // Turn off ARView's automatically-configured session
        // to create and set up your own configuration.
        arView.automaticallyConfigureSession = false

        configuration = ARWorldTrackingConfiguration()

        // Enable a collaborative session.
        configuration?.isCollaborationEnabled = true

        // Enable realistic reflections.
        configuration?.environmentTexturing = .automatic

        // Begin the session.
        arView.session.run(configuration!)
    }

    private func setupARViewAction() {
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if anchor.name == "NanosatcAncor" {
                guard let nanosatc = try? ModelEntity.load(named: "Nanosatc.reality") else { return }
                let anchorEntity = AnchorEntity(anchor: anchor)

                anchorEntity.addChild(nanosatc)

                arView.scene.addAnchor(anchorEntity)
            }
        }
    }
}
