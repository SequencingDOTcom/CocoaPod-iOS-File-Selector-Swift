//
//  SQFilesHelper.swift
//  oauthdemoapp-swift
//
//  Created by Bogdan Laukhin on 9/12/16.
//  Copyright © 2016 ua.org. All rights reserved.
//

import Foundation
import UIKit


typealias FilesCallback = (mySectionsArray: NSMutableArray?, sampleSectionsArray: NSMutableArray?) -> Void


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
    func parseFilesMainArray(filesMainArray:NSArray, WithCompletion completion:FilesCallback) -> Void {
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
            if object.isKindOfClass(NSDictionary) {
                let tempFile = object as! NSDictionary
                let tempCategoryName = tempFile.objectForKey("FileCategory") as! String
                let category: Int = categories.indexOfObject(tempCategoryName)
                
                switch category {
                    case 0:     // Sample Files Category
                        self.addFile(tempFile, IntoSection: sectionSampleAll)
                        let sex = tempFile.objectForKey("Sex") as! NSString?
                        if sex != nil {
                            if sex!.lowercaseString.rangeOfString("female") != nil  {
                                self.addFile(tempFile, IntoSection: sectionSampleWomen)
                            } else if sex!.lowercaseString.rangeOfString("male") != nil {
                                self.addFile(tempFile, IntoSection: sectionSampleMen)
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
                    
                    default:
                        print("file category not found")
                } // end of switch
            }
        } // end of cycle
        
        // saving sections/categories to main Sample Array
        if sectionSampleAll.filesArray.count > 0 {
            sampleInfoArray.addObject(sectionSampleAll)
        }
        if sectionSampleMen.filesArray.count > 0 {
            sampleInfoArray.addObject(sectionSampleMen)
        }
        if sectionSampleWomen.filesArray.count > 0 {
            sampleInfoArray.addObject(sectionSampleWomen)
        }
        
        // saving sections/categories to main My Files Array
        if sectionUploaded.filesArray.count > 0 {
            myInfoArray.addObject(sectionUploaded)
        }
        if sectionShared.filesArray.count > 0 {
            myInfoArray.addObject(sectionShared)
        }
        if sectionFromApps.filesArray.count > 0 {
            myInfoArray.addObject(sectionFromApps)
        }
        if sectionAltruist.filesArray.count > 0 {
            myInfoArray.addObject(sectionAltruist)
        }
        
        // return back the result
        completion(mySectionsArray: myInfoArray, sampleSectionsArray: sampleInfoArray)
    }
    
    
    
    // MARK: - Add file into Section
    func addFile(file: NSDictionary, IntoSection section:SQFilesSectionInfo) -> Void {
        var tempHeight: CGFloat = 44
        
        if section.sectionName.rangeOfString("Sample") != nil || section.sectionName.rangeOfString("All") != nil || section.sectionName.rangeOfString("Men") != nil || section.sectionName.rangeOfString("Women") != nil {
            
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
    func heightForRow(text: NSString) -> CGFloat {
        let font = UIFont.systemFontOfSize(13)
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: -1)
        shadow.shadowBlurRadius = 0.5
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraph.alignment = NSTextAlignment.Left
        
        let size = CGSize(width: 270, height:CGFloat.max)
        let options: NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]
        
        let rect: CGRect = text.boundingRectWithSize(size,
                                                     options: options,
                                                     attributes: [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraph, NSShadowAttributeName: shadow],
                                                     context: nil)
        
        if CGRectGetHeight(rect) < 42.960938 {
            return 44
        } else {
            return CGRectGetHeight(rect) + 10
        }
    }
    
    
    func heightForRowSampleFile(text: NSAttributedString) -> CGFloat {
        let size = CGSize(width: 260, height:CGFloat.max)
        let options: NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]
        
        let rect: CGRect = text.boundingRectWithSize(size, options: options, context: nil)
        
        if CGRectGetHeight(rect) < 40 {
            return 44
        } else {
            return CGRectGetHeight(rect) + 15
        }
    }
    
    
    
    // MARK: - Prepare text form files
    func prepareTextFromMyFile(file: NSDictionary) -> NSString {
        let preparedText = NSMutableString()
        let fileName = file.objectForKey("Name") as! String
        preparedText.appendString(fileName)
        
        return preparedText
    }
    
    
    func prepareTextFromSampleFile(file: NSDictionary) -> NSAttributedString {
        var friendlyDesk1 = file.objectForKey("FriendlyDesc1") as! NSString
        var friendlyDesk2 = file.objectForKey("FriendlyDesc2") as! NSString
        
        if friendlyDesk1 == NSNull() || friendlyDesk1.length == 0 {
            friendlyDesk1 = "noname1"
        }
        if friendlyDesk2 == NSNull() || friendlyDesk2.length == 0 {
            friendlyDesk2 = "noname2"
        }
        
        let tempString = String(format: "%@\n%@", friendlyDesk1, friendlyDesk2)
        let attrString = NSMutableAttributedString.init(string: tempString)
        
        attrString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(13), range: NSMakeRange(0, friendlyDesk1.length))
        attrString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(10), range: NSMakeRange(friendlyDesk1.length + 1, friendlyDesk2.length))
        
        return attrString
    }
    
    
    
    // MARK: - Search for fileID in Section
    func searchForFileID(fileID: NSString, InMyFilesSectionsArray sectionsArray:NSArray) -> NSDictionary? {
        var sectionIndexNumber: NSNumber?
        var fileIndexNumber: NSNumber?
        
        for arrayIndex in 0 ..< sectionsArray.count   {
            if let section = sectionsArray.objectAtIndex(arrayIndex) as? SQFilesSectionInfo {
                let arrayWithFilesFromSection: NSArray = section.filesArray
                
                for fileIndex in 0 ..< arrayWithFilesFromSection.count {
                    if let file = arrayWithFilesFromSection.objectAtIndex(fileIndex) as? NSDictionary  {
                        let fileIDFromSection = file.objectForKey("Id") as! NSString
                        if fileIDFromSection == fileID {
                            fileIndexNumber = NSNumber(integer: fileIndex)
                            break
                        }
                    }
                }
                
                if fileIndexNumber != nil {
                    sectionIndexNumber = NSNumber(integer: arrayIndex)
                    break
                }
            }
        }
        
        if sectionIndexNumber != nil && fileIndexNumber != nil {
            let indexesDict: NSDictionary = ["sectionIndex": sectionIndexNumber!, "fileIndex": fileIndexNumber!]
            return indexesDict

        } else {
            return nil
        }
    }
    
    
    func searchForFileID(fileID: NSString, InSampleFilesSectionsArray sectionsArray:NSArray) -> NSDictionary? {
        var sectionIndexNumber: NSNumber?
        var fileIndexNumber: NSNumber?
        
        if let section = sectionsArray.objectAtIndex(0) as? SQFilesSectionInfo {
            let arrayWithFilesFromSection: NSArray = section.filesArray
            
            for fileIndex in 0 ..< arrayWithFilesFromSection.count {
                if let file = arrayWithFilesFromSection.objectAtIndex(fileIndex) as? NSDictionary  {
                    let fileIDFromSection = file.objectForKey("Id") as! NSString
                    if fileIDFromSection == fileID {
                        fileIndexNumber = NSNumber(integer: fileIndex)
                        break
                    }
                }
            }
            
            if fileIndexNumber != nil {
                sectionIndexNumber = NSNumber(integer: 0)
            }
            
            if sectionIndexNumber != nil && fileIndexNumber != nil {
                let indexesDict: NSDictionary = ["sectionIndex": sectionIndexNumber!, "fileIndex": fileIndexNumber!]
                return indexesDict
                
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    
    // MARK: - Check if file is present in section
    func checkIfSelectedFileID(fileID: NSString, IsPresentInSection sectionNumber:Int, ForCategory category:String) -> NSNumber? {
        var indexOfSelectedFile = NSNumber()
        let filesContainer = SQFilesContainer.instance
        var section = SQFilesSectionInfo.init(name: kSAMPLE_ALL_FILES_CATEGORY_NAME)
        
        if category.rangeOfString("sample") != nil {
            if filesContainer.sampleSectionsArray != nil {
                section = filesContainer.sampleSectionsArray!.objectAtIndex(sectionNumber) as! SQFilesSectionInfo
            }
        } else {
            if filesContainer.mySectionsArray != nil {
                section = filesContainer.mySectionsArray!.objectAtIndex(sectionNumber) as! SQFilesSectionInfo
            }
        }
        
        let arrayWithFilesFromSection = section.filesArray
        for index in 0 ..< arrayWithFilesFromSection.count {
            if let file = arrayWithFilesFromSection.objectAtIndex(index) as? NSDictionary {
                
                let fileIDFromSection = file.objectForKey("Id") as! NSString
                if fileIDFromSection == fileID {
                    indexOfSelectedFile = NSNumber(integer: index)
                    break
                }
            }
        }
        return indexOfSelectedFile
    }
    
    

}
