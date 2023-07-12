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
    let blurView: UIView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()
    let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Carregando NanosatC-BR1"
        return label
    }()

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
        setupLoading()
        hideLoading()
    }

    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        print("handleTap")

        let location = recognizer.location(in: arView)

        if let hitEntity = self.arView.entity(at: location) {
            print("hitEntity")
            guard let entity = hitEntity as? HasCollision else { return }
            self.arView.installGestures(.all, for: entity)
            print("success")
        }

        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        guard !isAdded else { return }
        showLoading()

        if let firstResult = results.first {
            // Add an ARAnchor at the touch location with a special name you check later in `session(_:didAdd:)`.
            let anchor = ARAnchor(name: "NanosatcAnchor", transform: firstResult.worldTransform)
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

    private func setupLoading() {
        view.addSubview(blurView)
        view.addSubview(activityIndicatorView)
        view.addSubview(label)

        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            label.topAnchor.constraint(equalTo: activityIndicatorView.bottomAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func showLoading() {
        blurView.isHidden = false
        label.isHidden = false
        activityIndicatorView.startAnimating()
    }

    private func hideLoading() {
        blurView.isHidden = true
        label.isHidden = true
        activityIndicatorView.stopAnimating()
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if anchor.name == "NanosatcAnchor" {
                guard let nanosatc = try? ModelEntity.load(named: "Nanosatc.reality") else { return }
                let anchorEntity = AnchorEntity(anchor: anchor)
                anchorEntity.addChild(nanosatc)

                arView.scene.addAnchor(anchorEntity)
                hideLoading()
            }
        }
    }
}
