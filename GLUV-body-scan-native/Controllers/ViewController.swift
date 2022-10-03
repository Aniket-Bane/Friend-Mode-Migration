//
//  ViewController.swift
//  GLUV-body-scan-native
//
//  Created by Apple on 15/09/22.
//

import UIKit
import Metal
import MetalKit
import ARKit
import Combine
import RealityKit
import simd
import SwiftUI
import AVFoundation
                              

//import Alamofire

final class ViewController: UIViewController,ARSessionDelegate {
    
    var framespPerSecond : Int = 60
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var validationsView: UIView!
    @IBOutlet weak var validationsLabel: UILabel!
    
    private let isUIEnabled = true
    private let session = ARSession()
    private var renderer: Renderer!
    
    
    // MARK: - Properties
    var trackingStatus: String = ""
    var timer = Timer()
    var arrayofpointcloud = [0,1,2,3]
    var i = 0
    var player = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide NavigationBar
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        validationsView.isHidden = true
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        
        session.delegate = self
        
        // Set the view to use the default device
        if let view = view as? MTKView {
            view.device = device
            
            view.backgroundColor = UIColor.clear
            // we need this to enable depth test
            view.depthStencilPixelFormat = .depth32Float
            view.contentScaleFactor = 1
            view.delegate = self
            
            
            // Configure the renderer to draw to the view
            renderer = Renderer(session: session, metalDevice: device, renderDestination: view)
            renderer.drawRectResized(size: view.bounds.size)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a world-tracking configuration, and
        // enable the scene depth frame-semantic.
        let configuration = ARWorldTrackingConfiguration()
        configuration.frameSemantics = .sceneDepth
        //        print("depth data is \( configuration.frameSemantics)")
                
        
        // Run the view's session
        session.run(configuration)
        
        // The screen shouldn't dim during AR experiences.
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
//    call function here in DispatchQueue
    func session(_ session2: ARSession, didUpdate frame: ARFrame) {
        if (framespPerSecond == 210 ) {
            print ("Checking frame rate 210 ")
            DispatchQueue.global().async{
                self.deviceShake(session2)}
//            renderer.checkDeviceRangeNear()
//            renderer.checkDeviceRangeFar()
                self.deviceShakeUI(session2)
//            DispatchQueue.global().async {
//                self.renderer.returnDistance()
//
//            }
            framespPerSecond = 0
        }
        else {
            framespPerSecond += 1
        }
        
    }
    
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        let transform = frame.camera.transform
//               let position = transform.columns.3
//               print(position.x, position.y, position.z)
//    }
   
    @IBAction func onCompleteButtonTap(_ sender: Any) {
        
        showSimpleHUDWithoutBackground(in: self.view)
        print("save action")
        DispatchQueue.main.async {
            self.renderer.changeoriginnew()
            self.renderer.savePointsToFilenew()
            self.renderer.particleBufferIn()
            self.renderer.isSavingFile = true
            self.session.pause()
            
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let secondViewController = mainStoryBoard.instantiateViewController(withIdentifier: "ShowPointCloudViewController") as! ShowPointCloudViewController
            dismissHUDWithoutBackground()
            self.navigationController?.pushViewController(secondViewController, animated: true)
            
        }
    }

    // Auto-hide the home indicator to maximize immersion in AR experiences.
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // Hide the status bar to maximize immersion in AR experiences.
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - MTKViewDelegate

extension ViewController: MTKViewDelegate {
    // Called whenever view changes orientation or layout is changed
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.drawRectResized(size: size)
    }
    
    // Called whenever the view needs to render
    func draw(in view: MTKView) {
//        print("Inside draw12 ::: \(self.renderer.issessioninitilize)")
        
        renderer.draw()
    }
    
}       //extension ViewController



// MARK: - RenderDestinationProvider

protocol RenderDestinationProvider {
    var currentRenderPassDescriptor: MTLRenderPassDescriptor? { get }
    var currentDrawable: CAMetalDrawable? { get }
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
    var sampleCount: Int { get set }
}

extension MTKView: RenderDestinationProvider {
    
}

// MARK: - AR Session Management (ARSCNViewDelegate)

extension ViewController {
    
    func initARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: AR World Tracking Not Supported")
            return
        }
        
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravity
        config.providesAudioData = false
        config.isLightEstimationEnabled = true
        config.environmentTexturing = .automatic
        session.run(config)
        
    }
    
    func resetARSession() {
        let config = session.configuration as!
        ARWorldTrackingConfiguration
        config.planeDetection = .horizontal
        session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        
    }
    
    
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
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        self.trackingStatus = "AR Session Failure: \(error)"
        guard error is ARError else { return }
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion]
        
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                if let configuration = self.session.configuration {
                    self.session.run(configuration, options: .resetSceneReconstruction)
                }
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //PlaySound
    func playSound(name: String) {
        
        
                DispatchQueue.global().async {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        
        do {
            
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            
            self.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            
            self.player.play()
            
        } catch let error {
            
            print(error.localizedDescription)
            
        }
                }       //DispatchQueue

        
    }               //play Sound
    
    
    
    
    func sessionWasInterrupted(_ session: ARSession) {
        self.trackingStatus = "AR Session Was Interrupted!"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        self.trackingStatus = "AR Session Interruption Ended"
    }
    
    
    
    
  func deviceShake( _ session2: ARSession) -> Bool{
        if (session2.currentFrame != nil) {
        print ("device shake checked")
            if (session2.currentFrame?.camera.eulerAngles.y ?? 0.0 > 0.35 && session2.currentFrame?.camera.eulerAngles.y ?? 0.0 < 6.10) {
                playSound(name: "PleaseDoNotTiltTheDevice")
                return true
            }                           // device Tilt
        
            else if (session2.currentFrame?.camera.eulerAngles.z ?? 0.0 > 0.523599 && session2.currentFrame?.camera.eulerAngles.z ?? 0.0 < 6.10) {
                playSound(name: "PleaseDoNotRotateTheDevice")
                return true
            }                           //device Rotate
        
            else if (session2.currentFrame?.camera.transform.columns.3.x ?? 0.0 >= 0.20 ) {
                playSound(name: "ScanSpeedTooFastPleaseSlowDown")
                return true
            }                           //Movement
        
            else if (session2.currentFrame?.camera.transform.columns.3.x ?? 0.0 >= 0.35 ) {
                playSound(name: "ScanSpeedTooFastPleaseSlowDown")
                return true
            }                           //excessive Movement
        
        
            else if (renderer.checkDeviceRangeNear()){
                print("range Check")
                playSound(name: "TooClosePleaseStepBack")
                return true
            }

//            else if (renderer.checkDeviceRangeFar()){
//                print("range Check")
//                playSound(name: "TooFarPleaseStepCloser")
//                return true
//            }
        
        }
      
        else {
            
            return false
            
        }
      
        return false
      
    }       //CheckForDeviceShake
    
    
    func deviceShakeUI( _ session2: ARSession) -> Bool{
        
        if (session2.currentFrame != nil) {
            print ("UI shake checked")
            if (session2.currentFrame?.camera.eulerAngles.x ?? 0.0 > 0.35 && session2.currentFrame?.camera.eulerAngles.x ?? 0.0 < 6.10) {
                validationsView.isHidden = false
                validationsLabel.text = "Please do not Tilt the device"
                validationsView.isHidden = true
               
                return true
            }                           // device Tilt
            
            else if (session2.currentFrame?.camera.eulerAngles.z ?? 0.0 > 0.523599 && session2.currentFrame?.camera.eulerAngles.z ?? 0.0 < 6.10) {
                validationsView.isHidden = false
                validationsLabel.text = "Please Do Not Rotate The Device"
                validationsView.isHidden = true
                
                return true
            }                           //device Rotate
            
            else if (session2.currentFrame?.camera.transform.columns.3.x ?? 0.0 >= 0.35 ){
                validationsView.isHidden = false
                validationsLabel.text = "Expeditious Movement detected please slow down"
               
                return true
            }                           //Movement
            
            else if (session2.currentFrame?.camera.transform.columns.3.x ?? 0.0 >= 0.20 ){
                validationsView.isHidden = false
                validationsLabel.text = "Scan Speed Too Fast Please Slow Down"
               
                return true
            }               //moment
            
            
            else if (renderer.checkDeviceRangeNear()){
                validationsView.isHidden = false
                validationsLabel.text = "Please step back"
               
                return true
            }               //checkDeviceRangeNear

//            else if (renderer.checkDeviceRangeFar()){
//                validationsView.isHidden = false
//                validationsLabel.text = "Please come forward"
//
//                return true
//            }           //excessive Movement
        }
        else {
            
            return false
        }
        
        return false
        
    }
    
}         //class end
    
