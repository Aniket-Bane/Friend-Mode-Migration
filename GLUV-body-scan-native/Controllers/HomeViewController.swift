//
//  HomeViewController.swift
//  FX
//
//  Created by Apple on 06/09/22.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide NavigationBar
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.setNavigationBarHidden(true, animated: true)
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide NavigationBar 
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }


    @IBAction func onScanTorsoButtonClicked(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let Vc = storyBoard.instantiateViewController(withIdentifier: "InstructionsViewController") as! InstructionsViewController
        self.navigationController?.pushViewController(Vc, animated: true)
    }
    
    @IBAction func onShowPointCloudButtonClicked(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let Vc = storyBoard.instantiateViewController(withIdentifier: "ShowPointCloudViewController") as! ShowPointCloudViewController
        self.navigationController?.pushViewController(Vc, animated: true)
    }
    
    @IBAction func onShareMenuButtonClicked(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let Vc = storyBoard.instantiateViewController(withIdentifier: "ShareMenuViewController") as! ShareMenuViewController
        self.navigationController?.pushViewController(Vc, animated: true)
    }
    
}
