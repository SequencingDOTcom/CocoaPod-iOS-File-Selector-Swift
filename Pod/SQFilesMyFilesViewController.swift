//
//  SQFilesMyFilesViewController.swift
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
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
    var nowSelectedFileIndexPath: NSIndexPath?
    var categoryIndexes = NSDictionary()
    
    var fileTypeSelect = UISegmentedControl()
    
    let kMainQueue = dispatch_get_main_queue()
    
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filesAPI = SQFilesAPI.instance
        
        // prepare navigation bar
        self.title = "My Files"
        self.navigationItem.title = "Select a file"
        
        // setup extended navigation bar
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage.init(named: "nav_clear_pixel")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "nav_pixel"), forBarMetrics: UIBarMetrics.Default)
        
        // set up icons for TabBar
        let tabBarItem_MyFiles = self.tabBarController?.tabBar.items![0] as UITabBarItem?
        tabBarItem_MyFiles?.image = UIImage.init(named: "icon_myfiles")
        
        var myFiles_SelectedImage = UIImage.init(named: "icon_myfiles_color")
        myFiles_SelectedImage = myFiles_SelectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        tabBarItem_MyFiles?.selectedImage = myFiles_SelectedImage
        
        let tabBarItem_SampleFiles = self.tabBarController?.tabBar.items![1] as UITabBarItem?
        tabBarItem_SampleFiles?.image = UIImage.init(named: "icon_samplefiles")
        
        // continueButton
        continueButton = UIBarButtonItem.init(title: "Continue", style: UIBarButtonItemStyle.Done, target: self, action: #selector(self.fileIsSelected))
        continueButton.enabled = false
        self.navigationItem.rightBarButtonItem = continueButton
        
        // closeButton
        if filesAPI.closeButton {
            let closeButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(self.closeButtonPressed))
            self.navigationItem.leftBarButtonItem = closeButton
        }
        
        // prepare tableView
        tableView.dataSource = self
        tableView.delegate = self
        
        // allow using extra "native" radioButton for selectin rows
        tableView.setEditing(true, animated: true)
        
        // prepare array with segmented control items and indexes in source
        let filesContainer = SQFilesContainer.instance
        
        if filesContainer.mySectionsArray?.count > 0 {
            let itemsAndIndexes = SQFilesSegmentedControlHelper.prepareSegmentedControlItemsAndCategoryIndexesBasedOnFiles(filesContainer.mySectionsArray!)
            let segmentedControlItems = itemsAndIndexes.objectForKey("items") as! NSArray
            categoryIndexes = itemsAndIndexes.objectForKey("indexes") as! NSDictionary
            
            // segmented control init
            fileTypeSelect = UISegmentedControl(items: segmentedControlItems as [AnyObject])
            fileTypeSelect.addTarget(self, action: #selector(self.segmentControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
            fileTypeSelect.sizeToFit()
            fileTypeSelect.translatesAutoresizingMaskIntoConstraints = false
            extendedNavBarView.addSubview(fileTypeSelect)
            
            // adding constraints for segmented control
            let xCenter = NSLayoutConstraint.init(item: fileTypeSelect,
                                                  attribute: NSLayoutAttribute.CenterX,
                                                  relatedBy: NSLayoutRelation.Equal,
                                                  toItem: extendedNavBarView,
                                                  attribute: NSLayoutAttribute.CenterX,
                                                  multiplier: 1,
                                                  constant: 0)
            let yCenter = NSLayoutConstraint.init(item: fileTypeSelect,
                                                  attribute: NSLayoutAttribute.CenterY,
                                                  relatedBy: NSLayoutRelation.Equal,
                                                  toItem: extendedNavBarView,
                                                  attribute: NSLayoutAttribute.CenterY,
                                                  multiplier: 1,
                                                  constant: 0)
            extendedNavBarView.addConstraint(xCenter)
            extendedNavBarView.addConstraint(yCenter)
            
            // preselect file if any, and open related tab and related segmented item
            var sectionIndex: NSNumber?
            var fileIndex: NSNumber?
            
            if filesAPI.selectedFileID != nil {
                
                // try to find selected file among my files
                let myFileLocation = SQFilesHelper.instance.searchForFileID(filesAPI.selectedFileID!, InMyFilesSectionsArray: filesContainer.mySectionsArray!)
                if myFileLocation != nil {
                    sectionIndex = myFileLocation?.objectForKey("sectionIndex") as? NSNumber
                    fileIndex = myFileLocation?.objectForKey("fileIndex") as? NSNumber
                    
                    if sectionIndex != nil && fileIndex != nil {    // preselect file and preselect segment item
                        fileTypeSelect.selectedSegmentIndex = sectionIndex!.integerValue
                        let section = filesContainer.mySectionsArray?.objectAtIndex(sectionIndex!.integerValue) as! SQFilesSectionInfo
                        filesArray = section.filesArray
                        filesHeightsArray = section.rowHeights
                        nowSelectedFileIndexPath = NSIndexPath(forRow: fileIndex!.integerValue, inSection: 0)
                        
                    } else {    // select first item in segmentedControl and assign related source
                        fileTypeSelect.selectedSegmentIndex = 0
                        let section = filesContainer.mySectionsArray?.objectAtIndex(0) as! SQFilesSectionInfo
                        filesArray = section.filesArray
                        filesHeightsArray = section.rowHeights
                        nowSelectedFileIndexPath = nil
                    }
                    
                } else {    // try to find selected file among sample files
                    let sampleFileLocation = SQFilesHelper.instance.searchForFileID(filesAPI.selectedFileID!, InSampleFilesSectionsArray: filesContainer.sampleSectionsArray!)
                    if sampleFileLocation != nil {
                        tabBarController?.selectedIndex = 1
                        // select first item in segmentedControl and assign related source
                        fileTypeSelect.selectedSegmentIndex = 0
                        let section = filesContainer.mySectionsArray?.objectAtIndex(0) as! SQFilesSectionInfo
                        filesArray = section.filesArray
                        filesHeightsArray = section.rowHeights
                        nowSelectedFileIndexPath = nil
                        
                    } else {    // select first item in segmentedControl and assign related source
                        fileTypeSelect.selectedSegmentIndex = 0
                        let section = filesContainer.mySectionsArray?.objectAtIndex(0) as! SQFilesSectionInfo
                        filesArray = section.filesArray
                        filesHeightsArray = section.rowHeights
                        nowSelectedFileIndexPath = nil
                    }
                }
                
            } else {    // we don't have saved selected file > open default segment item
                // select first item in segmentedControl and assign related source
                fileTypeSelect.selectedSegmentIndex = 0
                let section = filesContainer.mySectionsArray?.objectAtIndex(0) as! SQFilesSectionInfo
                filesArray = section.filesArray
                filesHeightsArray = section.rowHeights
                nowSelectedFileIndexPath = nil
            }
            
        } else {    // switch to Sample files if my files are absent
            tabBarController?.selectedIndex = 1
            tabBarController?.tabBar.items![1].enabled = false
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var fileIndexInArray: NSNumber?
        let filesAPI = SQFilesAPI.instance
        
        if let selectedSegmentItem = fileTypeSelect.titleForSegmentAtIndex(fileTypeSelect.selectedSegmentIndex) {
            if let indexOfSectionInArray = categoryIndexes.objectForKey(selectedSegmentItem)!.integerValue {
                
                if filesAPI.selectedFileID != nil {
                    fileIndexInArray = SQFilesHelper.instance.checkIfSelectedFileID(filesAPI.selectedFileID!, IsPresentInSection: indexOfSectionInArray, ForCategory: "myfiles")
                    
                    if fileIndexInArray != nil {
                        nowSelectedFileIndexPath = NSIndexPath.init(forRow: fileIndexInArray!.integerValue, inSection: 0)
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
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            continueButton.enabled = false
        }
    }
    
    
    
    // MARK: - Actions
    func segmentControlAction(sender: UISegmentedControl) -> Void {
        nowSelectedFileIndexPath = nil
        continueButton.enabled = false
        
        filesArray = NSArray()
        filesHeightsArray = NSArray()
        tableView.reloadData()
        
        let filesContainer = SQFilesContainer.instance
        var section: SQFilesSectionInfo
        
        if let selectedSegmentItem = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex) {
            if let indexOfSectionInArray = categoryIndexes.objectForKey(selectedSegmentItem)!.integerValue {
                
                if filesContainer.mySectionsArray != nil {
                    section = filesContainer.mySectionsArray!.objectAtIndex(indexOfSectionInArray) as! SQFilesSectionInfo
                    filesArray = section.filesArray
                    filesHeightsArray = section.rowHeights
                    tableView.reloadData()
                }
                
                // preselect file if there is one in current section selected
                var fileIndexInArray: NSNumber?
                let filesAPI = SQFilesAPI.instance
                
                if filesAPI.selectedFileID != nil {
                    fileIndexInArray = SQFilesHelper.instance.checkIfSelectedFileID(filesAPI.selectedFileID!, IsPresentInSection: indexOfSectionInArray, ForCategory: "myfiles")
                }
                
                if fileIndexInArray != nil {
                    nowSelectedFileIndexPath = NSIndexPath.init(forRow: fileIndexInArray!.integerValue, inSection: 0)
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
        let selectedFile = filesArray.objectAtIndex(nowSelectedFileIndexPath!.row)
        if selectedFile.isKindOfClass(NSDictionary) {
            SQFilesAPI.instance.selectedFileDelegate?.handleFileSelected(selectedFile as! NSDictionary)
        }
    }
    
    
    func closeButtonPressed() -> Void {
        SQFilesAPI.instance.selectedFileID = nil
        SQFilesAPI.instance.selectedFileDelegate?.closeButtonPressed?()
    }
    
    
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesArray.count
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return filesHeightsArray.objectAtIndex(indexPath.row) as! CGFloat
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SQFilesTableCell
        
        let tempFile = filesArray.objectAtIndex(indexPath.row) as! NSDictionary
        let fileName = SQFilesHelper.instance.prepareTextFromMyFile(tempFile)
        
        cell.cellLabel.text = fileName as String
        cell.cellLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.tintColor = UIColor.blueColor()
        
        return cell
    }
    
    
    
    // MARK: - Cells selection
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        // return UITableViewCellEditingStyle.Insert
        return unsafeBitCast(3, UITableViewCellEditingStyle.self)
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if nowSelectedFileIndexPath == nil {
            nowSelectedFileIndexPath = indexPath
            
        } else if nowSelectedFileIndexPath != indexPath {
            self.tableView.deselectRowAtIndexPath(nowSelectedFileIndexPath!, animated: true)
            nowSelectedFileIndexPath = indexPath
        }
        continueButton.enabled = true
        
        // note selected file, in order to be preselected when get back to current section
        let filesAPI = SQFilesAPI.instance
        let selecteFile = filesArray.objectAtIndex(nowSelectedFileIndexPath!.row) as! NSDictionary
        let fileID = selecteFile.objectForKey("Id") as! NSString?
        
        if fileID != 0 {
            filesAPI.selectedFileID = fileID
        }
    }
    
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        nowSelectedFileIndexPath = nil
        continueButton.enabled = false
        
        let filesAPI = SQFilesAPI.instance
        filesAPI.selectedFileID = nil
    }
    
    
    func preselectFileInCurrentSection() -> Void {
        if nowSelectedFileIndexPath != 0 {
            if nowSelectedFileIndexPath!.row >= 0 && nowSelectedFileIndexPath!.row < filesArray.count {
                dispatch_async(kMainQueue, {
                    self.tableView.selectRowAtIndexPath(self.nowSelectedFileIndexPath!, animated: false, scrollPosition: UITableViewScrollPosition.None)
                    self.tableView.scrollToRowAtIndexPath(self.nowSelectedFileIndexPath!, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
                    self.continueButton.enabled = true
                })
            }
        }
    }
    
    
    func reloadTableViewWithAnimation() {
        var indexPath:[NSIndexPath] = [NSIndexPath]()
        for i in 0 ..< self.filesArray.count {
            indexPath.append(NSIndexPath(forRow: i, inSection: 0))
        }
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths(indexPath, withRowAnimation: UITableViewRowAnimation.Top)
        self.tableView.endUpdates()
    }
    
    
    
    // MARK: - Memory method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
