//
//  ShowPointCloudViewController.swift
//  GLUV-body-scan-native
//
//  Created by Apple on 08/09/22.
//

import UIKit
import SceneKit
import ARKit


// MARK: - App State Management

enum AppState: Int16 {
    case DetectSurface  // Scan surface (Plane Detection On)
    case PointAtSurface // Point at surface to see focus point (Plane Detection Off)
    case TapToStart     // Focus point visible on surface, tap to start
    case Started
}


class ShowPointCloudViewController: UIViewController , SCNSceneRendererDelegate, ARSCNViewDelegate{
    
    @IBOutlet weak var ScenekitView: SCNView!
    @IBOutlet weak var sceneView: SCNView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var getFitResultsButton: UIButton!
    @IBOutlet weak var rescanButton: UIButton!
    
    var tube : SCNNode = SCNNode(geometry: SCNTube(innerRadius: 0.06, outerRadius: 0.1, height: 5))
    var ship : SCNNode = SCNNode(geometry: SCNTube(innerRadius: 0.06, outerRadius: 0.1, height: 5))
    
    // MARK: - Properties
    var trackingStatus: String = ""
    var statusMessage: String = ""
    var appState: AppState = .DetectSurface
    var focusPoint:CGPoint!
    var focusNode: SCNNode!
    var arPortNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        //        self.navigationController?.setStatusBar(backgroundColor: UIColor(red: 24/255, green: 24/255, blue: 30/255, alpha: 0.0))
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.setStatusBar(backgroundColor: UIColor.black)
        self.navigationController?.navigationBar.setNeedsLayout()
        
        // hide backButton
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.setNavigationTitleimage()
        
        //button Configuration
        rescanButton.layer.borderWidth = 1.0
        rescanButton.layer.borderColor = UIColor.white.cgColor
        
        
        //  updateStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateStatus), name: Notification.Name("reloadviewscnuploaded"), object: nil)
        
    }
    
    
//    @IBAction func tapGestureHandler(_ sender: Any) {
//        guard appState == .TapToStart else { return }
//        self.arPortNode.isHidden = false
//        self.focusNode.isHidden = true
//        self.arPortNode.position = self.focusNode.position
//        appState = .Started
//    }
    
    @IBAction func getFitResultsButtonAction(_ sender: Any) {}
    
    @IBAction func rescanButtonAction(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let Vc = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(Vc, animated: true)
    }
}


extension ShowPointCloudViewController {
    
    func initScene() {
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
        //sceneView.showsStatistics = true
        sceneView.debugOptions = [
            //ARSCNDebugOptions.showFeaturePoints,
            //ARSCNDebugOptions.showWorldOrigin,
            //SCNDebugOptions.showBoundingBoxes,
            //SCNDebugOptions.showWireframe
        ]
        
        let arPortScene = SCNScene(named: "art.scnassets/Scenes/ARPortScene.scn")!
        arPortNode = arPortScene.rootNode.childNode(
            withName: "ARPort", recursively: false)!
        arPortNode.isHidden = true
        sceneView.scene?.rootNode.addChildNode(arPortNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateStatus()
            print("called")
        }
    }
    
    
    @objc internal  func  updateStatus(){
        print("call update status")
        
        do {
            
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            let fileManager = FileManager.default
            
            // var pathname =  Helper().retrievePathnameFromKeychain() ?? "ply_sancfile.scn"
            var pathname =  Helper().retrievePathnameFromKeychain() ?? "ply_sancfile.scn"
            let completepath = Helper().retrievePathnameFromKeychain() ?? "/var/mobile/Containers/Data/Application/36569A96-F982-4023-A826-D2288FE9CC9B/Documents/"
            var  path = completepath.deletingPrefix("/var/mobile/Containers/Data/Application/36569A96-F982-4023-A826-D2288FE9CC9B/Documents/")
            
            let imagePAth = (documentsDirectory as NSString).appendingPathComponent(completepath)
            Logger.shared().log(message: "name of file \(pathname) image path \(imagePAth)")
            if fileManager.fileExists(atPath: imagePAth){
                
                print("imagePAth:\(imagePAth)")
                let myURL = URL(fileURLWithPath : imagePAth)
                let scene = try SCNScene(url: myURL as URL, options: nil)
                //setup the camera
                //        let scene = SCNScene(named: "ply_color.scn")!
                let camera = SCNCamera();
                camera.usesOrthographicProjection = true
                camera.orthographicScale = 1
                camera.zNear = 0
                camera.zFar = 100;
                // create and add a camera to the scene
                let cameraNode = SCNNode()
                cameraNode.camera = camera
                scene.rootNode.addChildNode(cameraNode)
                cameraNode.position = SCNVector3(x: 0, y: 10, z: 35)

                ship = scene.rootNode.childNode(withName: "cloud", recursively: true)!
                // scene.rootNode.addChildNode(ship)
                ship.position = SCNVector3(x: 0, y: 0, z: 0)
                ship.eulerAngles = SCNVector3Make(0, 0, 0)
                //tube = scene.rootNode.childNode(withName: "tube", recursively: true)!
                let tubes = SCNTube(innerRadius: 0.06, outerRadius: 0.1, height: 5)
                let tubesnode = SCNNode(geometry: tubes)
                // scene.rootNode.addChildNode(tubesnode)
                tubesnode.position = SCNVector3(x: 0, y: 0, z: 0.23)
                // tubesnode.c
                //  newAngleY * ( 180 / Double.pi)
                tubesnode.eulerAngles = SCNVector3Make(0, 0, 0)
                print("position of tube node \(tubesnode.position)")
                //tube.rotation = SCNVector4(x: 0, y: 1, z: 1, w: 45)
                // put a constraint on the camera1
                let constraint = SCNLookAtConstraint(target: ship)
                
                cameraNode.constraints = [constraint]
                //        let targetNode = SCNLookAtConstraint(target: ship);
                //        //targetNode.gimbalLockEnabled = YES;
                //        cameraNode.constraints = [targetNode];
                
                // create and add a light to the scene
                let lightNode = SCNNode()
                lightNode.light = SCNLight()
                lightNode.light!.type = .omni
                lightNode.position = SCNVector3(x: 0, y: 0, z: 0)
                scene.rootNode.addChildNode(lightNode)
                
                // create and add an ambient light to the scene
                let ambientLightNode = SCNNode()
                ambientLightNode.light = SCNLight()
                ambientLightNode.light!.type = .ambient
                ambientLightNode.light!.color = UIColor.darkGray
                ambientLightNode.position = SCNVector3(x: 0, y: 0, z: 0)
                scene.rootNode.addChildNode(ambientLightNode)
                
                // animate the 3d object
                //ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
                
                // retrieve the SCNView
                //let scnView = SCNView()
                
                
                
                // put a constraint on the camera
                //        let cameraOrbit = SCNNode()
                //        cameraOrbit.addChildNode(cameraNode)
                //        scene.rootNode.addChildNode(cameraOrbit)
                //
                //        // rotate it (I've left out some animation code here to show just the rotation)
                //        cameraOrbit.eulerAngles.x -= Float(CGFloat(M_PI_4))
                //        cameraOrbit.eulerAngles.y -= Float(CGFloat(M_PI_4*3))
                
                // Allow user to manipulate camera
                ScenekitView.allowsCameraControl = true
                
                // Show FPS logs and timming
                // sceneView.showsStatistics = true
                
                // Set background color
                //            ScenekitView.backgroundColor = UIColor.white
                
                // Allow user translate image
                ScenekitView.autoenablesDefaultLighting = true
                ScenekitView.cameraControlConfiguration.allowsTranslation = false
                // ScenekitView.backgroundColor = UIColor(red: 41, green: 42, blue: 51, alpha: 1.0)
//                ScenekitView.backgroundColor = UIColor(red: 32/255, green: 32/255, blue: 39/255, alpha: 1.0)
                ScenekitView.backgroundColor = .black
                // Set scene settings
                ScenekitView.scene = scene
                ScenekitView.defaultCameraController.maximumVerticalAngle = 0.001
                
                //                SCNTransaction.begin()
                //                SCNTransaction.animationDuration = 5
                //                scnView.defaultCameraController.translateInCameraSpaceBy(x: 10, y: 10, z: 10)
                //                SCNTransaction.commit()
                
                
                // show statistics such as fps and timing information
                ScenekitView.showsStatistics = false
                
                // configure the view
                //            ScenekitView.backgroundColor = UIColor.white
                
                // Allow user translate image
                ScenekitView.cameraControlConfiguration.allowsTranslation = false
                
                // scnView.cameraControlConfiguration.rotationSensitivity = true
                let cameraNodes = ScenekitView.pointOfView
                print("cameraNodes:\(String(describing: cameraNodes))")
                
                
            } else{
                print("No Image")
            }
        } catch {
            print("error")
//            let scnView = SCNView()
        }
        
    }
    
}
