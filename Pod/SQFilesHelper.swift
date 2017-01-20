//
//  SQFilesHelper.swift
//  Copyright © 2017 Sequencing.com. All rights reserved
//


import Foundation
import UIKit


typealias FilesCallback = (_ mySectionsArray: NSMutableArray?, _ sampleSectionsArray: NSMutableArray?) -> Void


let kSAMPLE_ALL_FILES_CATEGORY_NAME: String     = "All"
let kSAMPLE_MEN_FILES_CATEGORY_NAME: String     = "Men"
let kSAMPLE_WOMEN_FILES_CATEGORY_NAME: String   = "Women"

let kUPLOADED_FILES_CATEGORY_NAME: String       = "Uploaded"
let kSHARED_FILES_CATEGORY_NAME: String         = "Shared"
let kAPPLICATION_FILES_CATEGORY_NAME: String    = "From Apps"
let kALTRUIST_FILES_CATEGORY_NAME: String       = "Altruist"

// fileCategory name in response
let kSAMPLE_FILES_CATEGORY_TAG: String          = "Community"
let kUPLOADED_FILES_CATEGORY_TAG: String        = "Uploaded"
let kSHARED_FILES_CATEGORY_TAG: String          = "SharedToMe"
let kAPPLICATION_FILES_CATEGORY_TAG: String     = "FromApps"
let kALTRUIST_FILES_CATEGORY_TAG: String        = "AllWithAltruist"



class SQFilesHelper: NSObject {
    
    // MARK: - Initializer
    static let instance = SQFilesHelper()
    
    
    
    // MARK: - Parse Files Array
    func parseFilesMainArray(_ filesMainArray:NSArray, WithCompletion completion:FilesCallback) -> Void {
        // For each category/section, set up a corresponding SectionInfo object to contain the category name
        // also list of files and height for each row
        let sampleInfoArray = NSMutableArray()  // array for section info for sample files
        let myInfoArray = NSMutableArray()      // array for section info for my files
        
        let sectionSampleAll    = SQFilesSectionInfo.init(name: kSAMPLE_ALL_FILES_CATEGORY_NAME)
        let sectionSampleMen    = SQFilesSectionInfo.init(name: kSAMPLE_MEN_FILES_CATEGORY_NAME)
        let sectionSampleWomen  = SQFilesSectionInfo.init(name: kSAMPLE_WOMEN_FILES_CATEGORY_NAME)
        
        let sectionUploaded     = SQFilesSectionInfo.init(name: kUPLOADED_FILES_CATEGORY_NAME)
        let sectionShared       = SQFilesSectionInfo.init(name: kSHARED_FILES_CATEGORY_NAME)
        let sectionFromApps     = SQFilesSectionInfo.init(name: kAPPLICATION_FILES_CATEGORY_NAME)
        let sectionAltruist     = SQFilesSectionInfo.init(name: kALTRUIST_FILES_CATEGORY_NAME)
        
        let categories: NSArray = [kSAMPLE_FILES_CATEGORY_TAG,
                                   kUPLOADED_FILES_CATEGORY_TAG,
                                   kSHARED_FILES_CATEGORY_TAG,
                                   kAPPLICATION_FILES_CATEGORY_TAG,
                                   kALTRUIST_FILES_CATEGORY_TAG]
        
        for object in filesMainArray {
            if object is NSDictionary {
                
                let tempFile = object as! NSDictionary
                let tempCategoryName = tempFile.object(forKey: "FileCategory") as! String
                let category: Int = categories.index(of: tempCategoryName)
                
                switch category {
                    
                case 0:     // Sample Files Category
                    if tempFile.allKeys.contains(where: { $0 as! String == "Sex"}) {
                        
                        let sex = tempFile.object(forKey: "Sex") as! NSString?
                        if sex != nil {
                            
                            self.addFile(tempFile, IntoSection: sectionSampleAll)
                            if sex!.lowercased.range(of: "female") != nil  {
                                self.addFile(tempFile, IntoSection: sectionSampleWomen)
                                
                            } else if sex!.lowercased.range(of: "male") != nil {
                                self.addFile(tempFile, IntoSection: sectionSampleMen)
                            }
                        }
                    }
                    
                    
                case 1:     // Uploaded Files Category
                    self.addFile(tempFile, IntoSection: sectionUploaded)
                    
                case 2:     // Shared Files Category
                    self.addFile(tempFile, IntoSection: sectionShared)
                    
                case 3:     // From Apps Files Category
                    self.addFile(tempFile, IntoSection: sectionFromApps)
                    
                case 4:     // Altruist Files Category
                    self.addFile(tempFile, IntoSection: sectionAltruist)
                    
                default:    print("file category not found")
                } // end of switch
            }
        } // end of cycle
        
        // saving sections/categories to main Sample Array
        if sectionSampleAll.filesArray.count > 0 {
            sampleInfoArray.add(sectionSampleAll)
        }
        if sectionSampleMen.filesArray.count > 0 {
            sampleInfoArray.add(sectionSampleMen)
        }
        if sectionSampleWomen.filesArray.count > 0 {
            sampleInfoArray.add(sectionSampleWomen)
        }
        
        // saving sections/categories to main My Files Array
        if sectionUploaded.filesArray.count > 0 {
            myInfoArray.add(sectionUploaded)
        }
        if sectionShared.filesArray.count > 0 {
            myInfoArray.add(sectionShared)
        }
        if sectionFromApps.filesArray.count > 0 {
            myInfoArray.add(sectionFromApps)
        }
        if sectionAltruist.filesArray.count > 0 {
            myInfoArray.add(sectionAltruist)
        }
        
        // return back the result
        completion(myInfoArray, sampleInfoArray)
    }
    
    
    
    // MARK: - Add file into Section
    func addFile(_ file: NSDictionary, IntoSection section:SQFilesSectionInfo) -> Void {
        var tempHeight: CGFloat = 44
        
        if section.sectionName.range(of: "Sample") != nil ||
           section.sectionName.range(of: "All") != nil ||
           section.sectionName.range(of: "Men") != nil ||
           section.sectionName.range(of: "Women") != nil {
            
            // calculate height for sample file
            let tempText: NSAttributedString = self.prepareTextFromSampleFile(file)
            tempHeight = self.heightForRowSampleFile(tempText)
            
        } else {
            // otherwise calculate height for my file
            let tempText: NSString = self.prepareTextFromMyFile(file)
            tempHeight = self.heightForRow(tempText)
        }
        section.addFile(file, WithHeight: tempHeight)
    }
    
    
    
    // MARK: - Calculate files height
    func heightForRow(_ text: NSString) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 13)
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: -1)
        shadow.shadowBlurRadius = 0.5
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraph.alignment = NSTextAlignment.left
        
        let size = CGSize(width: 270, height:CGFloat.greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        
        let rect: CGRect = text.boundingRect(with: size,
                                             options: options,
                                             attributes: [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraph, NSShadowAttributeName: shadow],
                                             context: nil)
        
        if rect.height < 42.960938 {
            return 44
        } else {
            return rect.height + 10
        }
    }
    
    
    func heightForRowSampleFile(_ text: NSAttributedString) -> CGFloat {
        let size = CGSize(width: 260, height:CGFloat.greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        
        let rect: CGRect = text.boundingRect(with: size, options: options, context: nil)
        
        if rect.height < 40 {
            return 44
        } else {
            return rect.height + 15
        }
    }
    
    
    
    // MARK: - Prepare text form files
    func prepareTextFromMyFile(_ file: NSDictionary) -> NSString {
        let preparedText = NSMutableString()
        let fileName = file.object(forKey: "Name") as! String
        preparedText.append(fileName)
        
        return preparedText
    }
    
    
    func prepareTextFromSampleFile(_ file: NSDictionary) -> NSAttributedString {
        var friendlyDesk1 = file.object(forKey: "FriendlyDesc1") as! NSString
        var friendlyDesk2 = file.object(forKey: "FriendlyDesc2") as! NSString
        
        if friendlyDesk1 == NSNull() || friendlyDesk1.length == 0 {
            friendlyDesk1 = "noname1"
        }
        if friendlyDesk2 == NSNull() || friendlyDesk2.length == 0 {
            friendlyDesk2 = "noname2"
        }
        
        let tempString = String(format: "%@\n%@", friendlyDesk1, friendlyDesk2)
        let attrString = NSMutableAttributedString.init(string: tempString)
        
        attrString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 13), range: NSMakeRange(0, friendlyDesk1.length - 1))
        attrString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 10), range: NSMakeRange(friendlyDesk1.length + 1, friendlyDesk2.length))
        
        return attrString
    }
    
    
    
    // MARK: - Search for fileID in Section
    func searchForFileID(_ fileID: NSString, InMyFilesSectionsArray sectionsArray:NSArray) -> NSDictionary? {
        var sectionIndexNumber: NSNumber?
        var fileIndexNumber: NSNumber?
        
        for arrayIndex in 0 ..< sectionsArray.count   {
            if let section = sectionsArray.object(at: arrayIndex) as? SQFilesSectionInfo {
                let arrayWithFilesFromSection: NSArray = section.filesArray
                
                for fileIndex in 0 ..< arrayWithFilesFromSection.count {
                    
                    if let file = arrayWithFilesFromSection.object(at: fileIndex) as? NSDictionary  {
                        let fileIDFromSection = file.object(forKey: "Id") as! NSString
                        if fileIDFromSection == fileID {
                            fileIndexNumber = NSNumber(value: fileIndex as Int)
                            break
                        }
                    }
                }
                
                if fileIndexNumber != nil {
                    sectionIndexNumber = NSNumber(value: arrayIndex as Int)
                    break
                }
            }
        }
        
        if sectionIndexNumber != nil && fileIndexNumber != nil {
            let indexesDict: NSDictionary = ["sectionIndex": sectionIndexNumber!,
                                             "fileIndex": fileIndexNumber!]
            return indexesDict

        } else {
            return nil
        }
    }
    
    
    func searchForFileID(_ fileID: NSString, InSampleFilesSectionsArray sectionsArray:NSArray) -> NSDictionary? {
        var sectionIndexNumber: NSNumber?
        var fileIndexNumber: NSNumber?
        
        if let section = sectionsArray.object(at: 0) as? SQFilesSectionInfo {
            let arrayWithFilesFromSection: NSArray = section.filesArray
            
            for fileIndex in 0 ..< arrayWithFilesFromSection.count {
                
                if let file = arrayWithFilesFromSection.object(at: fileIndex) as? NSDictionary  {
                    let fileIDFromSection = file.object(forKey: "Id") as! NSString
                    if fileIDFromSection == fileID {
                        fileIndexNumber = NSNumber(value: fileIndex as Int)
                        break
                    }
                }
            }
            
            if fileIndexNumber != nil {
                sectionIndexNumber = NSNumber(value: 0 as Int)
            }
            
            if sectionIndexNumber != nil && fileIndexNumber != nil {
                let indexesDict: NSDictionary = ["sectionIndex": sectionIndexNumber!,
                                                 "fileIndex": fileIndexNumber!]
                return indexesDict
                
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    
    // MARK: - Check if file is present in section
    func checkIfSelectedFileID(_ fileID: NSString, IsPresentInSection sectionNumber:Int, ForCategory category:String) -> NSNumber? {
        var indexOfSelectedFile = NSNumber()
        let filesContainer = SQFilesContainer.instance
        var section = SQFilesSectionInfo.init(name: kSAMPLE_ALL_FILES_CATEGORY_NAME)
        
        if category.range(of: "sample") != nil {
            if filesContainer.sampleSectionsArray != nil {
                section = filesContainer.sampleSectionsArray!.object(at: sectionNumber) as! SQFilesSectionInfo
            }
        } else {
            if filesContainer.mySectionsArray != nil {
                section = filesContainer.mySectionsArray!.object(at: sectionNumber) as! SQFilesSectionInfo
            }
        }
        
        let arrayWithFilesFromSection = section.filesArray
        
        for index in 0 ..< arrayWithFilesFromSection.count {
            
            if let file = arrayWithFilesFromSection.object(at: index) as? NSDictionary {
                
                let fileIDFromSection = file.object(forKey: "Id") as! NSString
                if fileIDFromSection == fileID {
                    indexOfSelectedFile = NSNumber(value: index as Int)
                    break
                }
            }
        }
        return indexOfSelectedFile
    }
    
    

}
