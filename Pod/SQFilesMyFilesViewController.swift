//
//  SQFilesMyFilesViewController.swift
//  Copyright © 2017 Sequencing.com. All rights reserved
//


import UIKit


class SQFilesMyFilesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {  

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var extendedNavBarView: SQFilesExtendedNavBarView!
    
    let cellIdentifier = "cell"
    
    // file source
    var filesArray = NSArray()
    var filesHeightsArray = NSArray()
    
    // buttons
    var continueButton = UIBarButtonItem()
    
    // selected file details
    var nowSelectedFileIndexPath: IndexPath?
    var categoryIndexes = NSDictionary()
    
    var fileTypeSelect = UISegmentedControl()
    
    let kMainQueue = DispatchQueue.main
    
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filesAPI = SQFilesAPI.instance
        
        // prepare navigation bar
        self.title = "My Files"
        self.navigationItem.title = "Select a file"
        
        // setup extended navigation bar
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage.init(named: "nav_clear_pixel")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "nav_pixel"), for: UIBarMetrics.default)
        
        // set up icons for TabBar
        let tabBarItem_MyFiles = self.tabBarController?.tabBar.items![0] as UITabBarItem?
        tabBarItem_MyFiles?.image = UIImage.init(named: "icon_myfiles")
        
        var myFiles_SelectedImage = UIImage.init(named: "icon_myfiles_color")
        myFiles_SelectedImage = myFiles_SelectedImage?.withRenderingMode(.alwaysOriginal)
        tabBarItem_MyFiles?.selectedImage = myFiles_SelectedImage
        
        let tabBarItem_SampleFiles = self.tabBarController?.tabBar.items![1] as UITabBarItem?
        tabBarItem_SampleFiles?.image = UIImage.init(named: "icon_samplefiles")
        
        // continueButton
        continueButton = UIBarButtonItem.init(title: "Continue",
                                              style: UIBarButtonItemStyle.done,
                                              target: self,
                                              action: #selector(self.fileIsSelected))
        continueButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = continueButton
        
        // closeButton
        if filesAPI.closeButton {
            let closeButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.stop,
                                                   target: self,
                                                   action: #selector(self.closeButtonPressed))
            self.navigationItem.leftBarButtonItem = closeButton
        }
        
        // prepare tableView
        tableView.dataSource = self
        tableView.delegate = self
        
        // allow using extra "native" radioButton for selectin rows
        tableView.setEditing(true, animated: true)
        
        // prepare array with segmented control items and indexes in source
        let filesContainer = SQFilesContainer.instance
        if filesContainer.mySectionsArray != nil {
            
            let itemsAndIndexes = SQFilesSegmentedControlHelper.prepareSegmentedControlItemsAndCategoryIndexesBasedOnFiles(filesContainer.mySectionsArray!)
            let segmentedControlItems = itemsAndIndexes.object(forKey: "items") as! NSArray
            categoryIndexes = itemsAndIndexes.object(forKey: "indexes") as! NSDictionary
            
            // segmented control init
            fileTypeSelect = UISegmentedControl(items: segmentedControlItems as [AnyObject])
            fileTypeSelect.addTarget(self, action: #selector(self.segmentControlAction(_:)), for: UIControlEvents.valueChanged)
            fileTypeSelect.sizeToFit()
            fileTypeSelect.translatesAutoresizingMaskIntoConstraints = false
            extendedNavBarView.addSubview(fileTypeSelect)
            
            // adding constraints for segmented control
            let xCenter = NSLayoutConstraint.init(item: fileTypeSelect,
                                                  attribute: NSLayoutAttribute.centerX,
                                                  relatedBy: NSLayoutRelation.equal,
                                                  toItem: extendedNavBarView,
                                                  attribute: NSLayoutAttribute.centerX,
                                                  multiplier: 1,
                                                  constant: 0)
            let yCenter = NSLayoutConstraint.init(item: fileTypeSelect,
                                                  attribute: NSLayoutAttribute.centerY,
                                                  relatedBy: NSLayoutRelation.equal,
                                                  toItem: extendedNavBarView,
                                                  attribute: NSLayoutAttribute.centerY,
                                                  multiplier: 1,
                                                  constant: 0)
            extendedNavBarView.addConstraint(xCenter)
            extendedNavBarView.addConstraint(yCenter)
            
            // preselect file if any, and open related tab and related segmented item
            var sectionIndex: NSNumber?
            var fileIndex: NSNumber?
            
            
            if filesAPI.selectedFileID != nil {
                
                // try to find selected file among my files
                let myFileLocation = SQFilesHelper.instance.searchForFileID(filesAPI.selectedFileID!,
                                                                            InMyFilesSectionsArray: filesContainer.mySectionsArray!)
                if myFileLocation != nil {
                    sectionIndex = myFileLocation?.object(forKey: "sectionIndex") as? NSNumber
                    fileIndex = myFileLocation?.object(forKey: "fileIndex") as? NSNumber
                    
                    if sectionIndex != nil && fileIndex != nil {    // preselect file and preselect segment item
                        fileTypeSelect.selectedSegmentIndex = sectionIndex!.intValue
                        let section = filesContainer.mySectionsArray?.object(at: sectionIndex!.intValue) as! SQFilesSectionInfo
                        filesArray = section.filesArray
                        filesHeightsArray = section.rowHeights
                        nowSelectedFileIndexPath = IndexPath(row: fileIndex!.intValue, section: 0)
                        
                    } else {    // select first item in segmentedControl and assign related source
                        fileTypeSelect.selectedSegmentIndex = 0
                        let section = filesContainer.mySectionsArray?.object(at: 0) as! SQFilesSectionInfo
                        filesArray = section.filesArray
                        filesHeightsArray = section.rowHeights
                        nowSelectedFileIndexPath = nil
                    }
                    
                } else {    // try to find selected file among sample files
                    let sampleFileLocation = SQFilesHelper.instance.searchForFileID(filesAPI.selectedFileID!,
                                                                                    InSampleFilesSectionsArray: filesContainer.sampleSectionsArray!)
                    if sampleFileLocation != nil {
                        tabBarController?.selectedIndex = 1
                        // select first item in segmentedControl and assign related source
                        fileTypeSelect.selectedSegmentIndex = 0
                        let section = filesContainer.mySectionsArray?.object(at: 0) as! SQFilesSectionInfo
                        filesArray = section.filesArray
                        filesHeightsArray = section.rowHeights
                        nowSelectedFileIndexPath = nil
                        
                    } else {    // select first item in segmentedControl and assign related source
                        fileTypeSelect.selectedSegmentIndex = 0
                        let section = filesContainer.mySectionsArray?.object(at: 0) as! SQFilesSectionInfo
                        filesArray = section.filesArray
                        filesHeightsArray = section.rowHeights
                        nowSelectedFileIndexPath = nil
                    }
                }
                
            } else {    // we don't have saved selected file > open default segment item
                // select first item in segmentedControl and assign related source
                fileTypeSelect.selectedSegmentIndex = 0
                let section = filesContainer.mySectionsArray?.object(at: 0) as! SQFilesSectionInfo
                filesArray = section.filesArray
                filesHeightsArray = section.rowHeights
                nowSelectedFileIndexPath = nil
            }
            
        } else {    // switch to Sample files if my files are absent
            tabBarController?.selectedIndex = 1
            tabBarController?.tabBar.items![1].isEnabled = false
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var fileIndexInArray: NSNumber?
        let filesAPI = SQFilesAPI.instance
        
        if let selectedSegmentItem = fileTypeSelect.titleForSegment(at: fileTypeSelect.selectedSegmentIndex) {
            
            let tempIndex = categoryIndexes.object(forKey: selectedSegmentItem)
            if let indexOfSectionInArray = tempIndex as? Int {
                
                if filesAPI.selectedFileID != nil {
                    fileIndexInArray = SQFilesHelper.instance.checkIfSelectedFileID(filesAPI.selectedFileID!,
                                                                                    IsPresentInSection: indexOfSectionInArray,
                                                                                    ForCategory: "myfiles")
                    
                    if fileIndexInArray != nil {
                        nowSelectedFileIndexPath = IndexPath.init(row: fileIndexInArray!.intValue, section: 0)
                    } else {
                        nowSelectedFileIndexPath = nil
                    }
                    
                    if nowSelectedFileIndexPath != nil {
                        self.preselectFileInCurrentSection()
                    }
                }
                
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
            continueButton.isEnabled = false
        }
    }
    
    
    
    // MARK: - Actions
    func segmentControlAction(_ sender: UISegmentedControl) -> Void {
        nowSelectedFileIndexPath = nil
        continueButton.isEnabled = false
        
        filesArray = NSArray()
        filesHeightsArray = NSArray()
        tableView.reloadData()
        
        let filesContainer = SQFilesContainer.instance
        var section: SQFilesSectionInfo
        
        if let selectedSegmentItem = sender.titleForSegment(at: sender.selectedSegmentIndex) {
            
            let tempIndex = categoryIndexes.object(forKey: selectedSegmentItem)
            if let indexOfSectionInArray = tempIndex as? Int {
                
                if filesContainer.mySectionsArray != nil {
                    section = filesContainer.mySectionsArray!.object(at: indexOfSectionInArray) as! SQFilesSectionInfo
                    filesArray = section.filesArray
                    filesHeightsArray = section.rowHeights
                    tableView.reloadData()
                }
                
                // preselect file if there is one in current section selected
                var fileIndexInArray: NSNumber?
                let filesAPI = SQFilesAPI.instance
                
                if filesAPI.selectedFileID != nil {
                    fileIndexInArray = SQFilesHelper.instance.checkIfSelectedFileID(filesAPI.selectedFileID!,
                                                                                    IsPresentInSection: indexOfSectionInArray,
                                                                                    ForCategory: "myfiles")
                }
                
                if fileIndexInArray != nil {
                    nowSelectedFileIndexPath = IndexPath.init(row: fileIndexInArray!.intValue, section: 0)
                } else {
                    nowSelectedFileIndexPath = nil
                }
                
                if nowSelectedFileIndexPath != nil {
                    self.preselectFileInCurrentSection()
                }
                
            }
        }
    }
    
    
    func fileIsSelected() {
        let selectedFile = filesArray.object(at: nowSelectedFileIndexPath!.row)
        
        if selectedFile is NSDictionary {
            SQFilesAPI.instance.selectedFileDelegate?.handleFileSelected(selectedFile as! NSDictionary)
        }
    }
    
    
    func closeButtonPressed() -> Void {
        SQFilesAPI.instance.selectedFileID = nil
        SQFilesAPI.instance.selectedFileDelegate?.closeButtonPressed?()
    }
    
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesArray.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return filesHeightsArray.object(at: indexPath.row) as! CGFloat
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SQFilesTableCell
        
        let tempFile = filesArray.object(at: indexPath.row) as! NSDictionary
        let fileName = SQFilesHelper.instance.prepareTextFromMyFile(tempFile)
        
        cell.cellLabel.text = fileName as String
        cell.cellLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.tintColor = UIColor.blue
        
        return cell
    }
    
    
    
    // MARK: - Cells selection
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        // return UITableViewCellEditingStyle.Insert
        return unsafeBitCast(3, to: UITableViewCellEditingStyle.self)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if nowSelectedFileIndexPath == nil {
            nowSelectedFileIndexPath = indexPath
            
        } else if nowSelectedFileIndexPath != indexPath {
            self.tableView.deselectRow(at: nowSelectedFileIndexPath!, animated: true)
            nowSelectedFileIndexPath = indexPath
        }
        continueButton.isEnabled = true
        
        // note selected file, in order to be preselected when get back to current section
        let filesAPI = SQFilesAPI.instance
        let selecteFile = filesArray.object(at: nowSelectedFileIndexPath!.row) as! NSDictionary
        
        let fileID = selecteFile.object(forKey: "Id")
        if fileID is NSString {
            if fileID != nil {
                filesAPI.selectedFileID = fileID as! NSString?
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        nowSelectedFileIndexPath = nil
        continueButton.isEnabled = false
        
        let filesAPI = SQFilesAPI.instance
        filesAPI.selectedFileID = nil
    }
    
    
    func preselectFileInCurrentSection() -> Void {
        if nowSelectedFileIndexPath != nil {
            
            if nowSelectedFileIndexPath!.row >= 0 && nowSelectedFileIndexPath!.row < filesArray.count {
                
                kMainQueue.async(execute: {
                    self.tableView.selectRow(at: self.nowSelectedFileIndexPath!, animated: false, scrollPosition: UITableViewScrollPosition.none)
                    self.tableView.scrollToRow(at: self.nowSelectedFileIndexPath!, at: UITableViewScrollPosition.middle, animated: false)
                    self.continueButton.isEnabled = true
                })
            }
        }
    }
    
    
    func reloadTableViewWithAnimation() {
        var indexPath:[IndexPath] = [IndexPath]()
        for i in 0 ..< self.filesArray.count {
            indexPath.append(IndexPath(row: i, section: 0))
        }
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: indexPath, with: UITableViewRowAnimation.top)
        self.tableView.endUpdates()
    }
    
    
    
    // MARK: - Memory method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
