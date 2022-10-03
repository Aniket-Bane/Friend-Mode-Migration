//
//  StartScanViewController.swift
//  FX
//
//  Created by Apple on 07/09/22.
//

import UIKit
import ARKit
import Metal
import MetalKit
import Combine
import RealityKit
import simd
import SwiftUI

class StartScanViewController: UIViewController,ARSCNViewDelegate, ARSessionDelegate {
    
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var centerPopupConstraints: NSLayoutConstraint!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var targetPointImageView: UIImageView!
    @IBOutlet weak var popupTitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    var counter = 3
    
    private let isUIEnabled = true
    private let session = ARSession()
    private var renderer: Renderer!
    
    // MARK: - Properties
    var trackingStatus: String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.setNavigationBarHidden(false, animated: true)
//        self.navigationController?.setStatusBar(backgroundColor: UIColor(red: 24/255, green: 24/255, blue: 30/255, alpha: 0.0))
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.setStatusBar(backgroundColor: UIColor.black)
        self.navigationController?.navigationBar.setNeedsLayout()

        //back button
        let backBarButton = createNavBarButtonWithText(label: "Back", action: #selector(backButtonPressed), vc: self)
        self.navigationItem.leftBarButtonItem = backBarButton

        self.setNavigationTitleimage()
        
        
//        sceneView.delegate = self
//        sceneView.session.delegate = self
//        let scene = SCNScene()
//        sceneView.scene = scene
        
        targetPointImageView.isHidden = true
        countDownLabel.isHidden = true
        popupTitleLabel.isHidden = true
        popupView.isHidden = false
        countDownLabel.isHidden = true
        startButton.isEnabled = false
        
        
    }
    
    @objc func backButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
        centerPopupConstraints.constant = 0.0
                
    }
           
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    
    @IBAction func onStartButtonTap(_ sender: Any) {
        
            countDownLabel.isHidden = false
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
           
    }
    
    
    @objc func updateCounter() {
        //example functionality
        if counter > 0 {
            print("\(counter) seconds to the end of the world")
            self.countDownLabel.text = String(counter)
            counter -= 1
            
        }
        
        switch counter {
        case 1:
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
               // Code you want to be delayed
                self.targetPointImageView.isHidden = true
                self.countDownLabel.isHidden = true
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let Vc = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                self.navigationController?.pushViewController(Vc, animated: false)
            }
            

        case 2:
            print("case 2")
        case 3:
            print("case 3")
        default:
            break
        }
        
    }

    
    @IBAction func onPopupSubmitButtonTap(_ sender: Any) {
        
        if emailTextField.text!.isValidEmail {
            print("u have entered correct mail format")
            targetPointImageView.isHidden = false
            centerPopupConstraints.constant = -400
            popupView.isHidden = true
            self.view.endEditing(true)
            startButton.isEnabled = true
        } else {
            popupTitleLabel.isHidden = false
            popupTitleLabel.text = "Invalid Email. Try again !"
        }
    }
}



extension StartScanViewController {
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            self.trackingStatus = "Tracking:  Not available!"
        case .normal:
            self.trackingStatus = ""
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                self.trackingStatus = "Tracking: Limited due to excessive motion!"
            case .insufficientFeatures:
                self.trackingStatus = "Tracking: Limited due to insufficient features!"
            case .relocalizing:
                self.trackingStatus = "Tracking: Relocalizing..."
            case .initializing:
                self.trackingStatus = "Tracking: Initializing..."
            @unknown default:
                self.trackingStatus = "Tracking: Unknown..."
            }
        }
    }
}

