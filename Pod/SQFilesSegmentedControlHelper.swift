//
//  SQFilesSegmentedControlHelper.swift
//  Copyright © 2017 Sequencing.com. All rights reserved
//


import Foundation


class SQFilesSegmentedControlHelper: NSObject {
    
    
    class func prepareSegmentedControlItemsAndCategoryIndexesBasedOnFiles(_ filesArray: NSArray) -> NSDictionary {
        
        let categoryWithItemsAndIndexes = NSMutableDictionary()
        let tempItemsArray = NSMutableArray.init(capacity: filesArray.count)
        let tempIndexesDictionary = NSMutableDictionary()
        
        for index in 0 ..< filesArray.count {
            
            let object = filesArray.object(at: index) as AnyObject
            if object is SQFilesSectionInfo {
                
                let tempSection = object as! SQFilesSectionInfo
                let sectionNumber = NSNumber.init(value: index)
                tempItemsArray.add(tempSection.sectionName)
                tempIndexesDictionary.setObject(sectionNumber, forKey: tempSection.sectionName as NSCopying)
            }
        }
        
        categoryWithItemsAndIndexes.setObject(tempItemsArray, forKey: "items" as NSCopying)
        categoryWithItemsAndIndexes.setObject(tempIndexesDictionary, forKey: "indexes" as NSCopying)
        
        return categoryWithItemsAndIndexes.copy() as! NSDictionary
    }

}
