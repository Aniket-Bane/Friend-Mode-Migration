//
//  ShareMenuViewController.swift
//  FX
//
//  Created by Apple on 06/09/22.
//

import UIKit

class ShareMenuViewController: UIViewController {
    
    
    @IBOutlet weak var shareMenuTableView: UITableView!
    
    var titleNameArray = ["20-30-200_abc","30-30-201_abc","40-30-202_abc","50-30-203_abc"]
    var selectedArray = [String]()
    private var isItemSelected: Bool = false

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
        
//        self.shareMenuTableView.isEditing = true
//        self.shareMenuTableView.allowsMultipleSelectionDuringEditing = true
    }
    
    @objc func backButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func onSelectAllButtonTap(_ sender: Any) {
        //        let indexPath = IndexPath(row: 0, section: 0)
        //        let cell = shareMenuTableView.cellForRow(at: indexPath) as! ShareMenueTableViewCell
        //
        //        cell.checkBoxButton.setImage(UIImage(named: "checked-checkbox"), for: .selected)
        //
        //
        //        let cellArray =  shareMenuTableView.visibleCells
        //        print("cell Arry is : \(cellArray)")
        
//        for row in 0..<titleNameArray.count {
//            self.shareMenuTableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
//
//        }
        
        setValue(true)
        
        self.selectedArray = self.titleNameArray
        print("selectedArray is :\(selectedArray)")
    
    
  
    }
    
    @IBAction func onDeselectAllButtonTap(_ sender: Any) {
        
//        for row in 0..<titleNameArray.count {
//            self.shareMenuTableView.deselectRow(at: IndexPath(row: row, section: 0), animated: false)
//        }
        
        setValue(false)
        
        self.selectedArray.removeAll()
        print("DeSelectedArray is :\(selectedArray)")
        
    }
    
    private func setValue(_ value: Bool) {
        isItemSelected = value
        shareMenuTableView.reloadData()
    }
    
    @IBAction func onShareButtonTap(_ sender: UIButton) {
        
        //        // set up activity view controller
        //        let shareAll = self.selectedArray
        //        // Make the activityViewContoller which shows the share-view
        //        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        //        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        //
        //        // exclude some activity types from the list (optional)
        //        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        //
        //        // present the view controller
        //        self.present(activityViewController, animated: true, completion: nil)
        
        
        // Your String including the text you want share in a file
        let text = "yourText"
        
        // Convert the String into Data
        let textData = text.data(using: .utf8)
        
        // Write the text into a filepath and return the filepath in NSURL
        // Specify the file type you want the file be by changing the end of the filename (.txt, .json, .pdf...)
        let textURL = textData?.dataToFile(fileName: "nameOfYourFile.txt")
        
        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()
        
        // Add the path of the text file to the Array
        filesToShare.append(textURL!)
        
        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        
        // Show the share-view
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
}


extension ShareMenuViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShareMenueCell", for: indexPath) as? ShareMenueTableViewCell else { return UITableViewCell() }
        cell.configure(titleNameArray[indexPath.row], selected: isItemSelected)
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareMenueCell", for: indexPath) as! ShareMenueTableViewCell
        
        cell.titleLabel.text = titleNameArray[indexPath.row]
        cell.checkBoxButton.tag = indexPath.row
        cell.checkBoxButton.addTarget(self, action: #selector(onCheckBoxTaped), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectDeselectCell(tableView: tableView, indexPath: indexPath)
        print("Select")
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectDeselectCell(tableView: tableView, indexPath: indexPath)
        print("Deselect")
    }
    
    @objc func onCheckBoxTaped (sender:UIButton) {
        
        let button  = sender as! UIButton
        let index = button.tag
        print("index is :\(index)")
    
        if sender.isSelected{
            sender.isSelected = false
            print("deSelected")
            
        } else {
            sender.isSelected = true
            print("Selected")
            
        }
    }
}

extension ShareMenuViewController {
    // Select And Deselect TableView
    
    func selectDeselectCell (tableView:UITableView,indexPath: IndexPath){
        self.selectedArray.removeAll()
        
        if let array = tableView.indexPathsForSelectedRows{
            print(array)
            for index in array{
                selectedArray.append(titleNameArray[index.row])
            }
        }
        print(selectedArray)
    }
}


/// Get the current directory
///
/// - Returns: the Current directory in NSURL
func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory as NSString
}


extension Data {
    
    /// Data into file
    ///
    /// - Parameters:
    ///   - fileName: the Name of the file you want to write
    /// - Returns: Returns the URL where the new file is located in NSURL
    func dataToFile(fileName: String) -> NSURL? {
        
        // Make a constant from the data
        let data = self
        
        // Make the file path (with the filename) where the file will be loacated after it is created
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            // Write the file from data into the filepath (if there will be an error, the code jumps to the catch block below)
            try data.write(to: URL(fileURLWithPath: filePath))
            
            // Returns the URL where the new file is located in NSURL
            return NSURL(fileURLWithPath: filePath)
            
        } catch {
            // Prints the localized description of the error from the do block
            print("Error writing the file: \(error.localizedDescription)")
        }
        
        // Returns nil if there was an error in the do-catch -block
        return nil
        
    }
    
    
}
