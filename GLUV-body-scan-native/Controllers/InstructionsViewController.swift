//
//  InstructionsViewController.swift
//  FX
//
//  Created by Apple on 06/09/22.
//

import UIKit

class InstructionsViewController: UIViewController {

    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var instructionsCollectionView: UICollectionView!
    
    var itemNameArray = ["Wear an Unlined Bra","Pull Hair Up","Remove Outerwear","Avoid Loose Garments","Don’t Wear Sports Bras","Remove Accessories"]
    var itemImageArray = [UIImage(named: "Vector"),UIImage(named: "Hair"),UIImage(named: "jacket"),UIImage(named: "T-shirt"),UIImage(named: "Sports"),UIImage(named: "Group 10700")]

    var numberOfItemsPerRow :Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //navbar
        navigationController?.setNavigationBarHidden(false, animated: true)
//        self.navigationController?.setStatusBar(backgroundColor: UIColor(red: 24/255, green: 24/255, blue: 30/255, alpha: 0.0))
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.setStatusBar(backgroundColor: UIColor.black)
        self.navigationController?.navigationBar.setNeedsLayout()
        
        //change statusbar backgroundColor
//        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
//        let statusBarColor = UIColor(red: 24/255, green: 24/255, blue: 30/255, alpha: 1.0)
//        statusBarView.backgroundColor = statusBarColor
//        view.addSubview(statusBarView)
        
        
        //back button
        let backBarButton = createNavBarButtonWithText(label: "Back", action: #selector(backButtonPressed), vc: self)
        self.navigationItem.leftBarButtonItem = backBarButton
        
        self.setNavigationTitleimage()
    }
    
    @objc func backButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    @IBAction func onContinueButtonClicked(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let Vc = storyBoard.instantiateViewController(withIdentifier: "StartScanViewController") as! StartScanViewController
        self.navigationController?.pushViewController(Vc, animated: true)
    }
    
}

extension InstructionsViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemNameArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InstructionsCell", for: indexPath) as! InstructionsCollectionViewCell
        
        cell.itemsNameLabel.text = itemNameArray[indexPath.item]
        cell.itemsImageView.image = itemImageArray[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        let size = Int(((collectionView.bounds.width - 20) - totalSpace) / CGFloat(numberOfItemsPerRow))

        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
        
    }
 
}

