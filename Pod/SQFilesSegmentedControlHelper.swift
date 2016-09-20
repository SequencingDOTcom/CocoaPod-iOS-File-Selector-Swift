//
//  SQFilesSegmentedControlHelper.swift
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

import Foundation


class SQFilesSegmentedControlHelper: NSObject {
    
    
    class func prepareSegmentedControlItemsAndCategoryIndexesBasedOnFiles(filesArray: NSArray) -> NSDictionary {
        
        let categoryWithItemsAndIndexes = NSMutableDictionary()
        let tempItemsArray = NSMutableArray.init(capacity: filesArray.count)
        let tempIndexesDictionary = NSMutableDictionary()
        
        for index in 0 ..< filesArray.count {
            let object: AnyObject = filesArray.objectAtIndex(index)
            
            if object.isKindOfClass(SQFilesSectionInfo) {
                let tempSection = object as! SQFilesSectionInfo
                let sectionNumber: NSNumber = index
                tempItemsArray.addObject(tempSection.sectionName)
                tempIndexesDictionary.setObject(sectionNumber, forKey: tempSection.sectionName)
            }
        }
        
        categoryWithItemsAndIndexes.setObject(tempItemsArray, forKey: "items")
        categoryWithItemsAndIndexes.setObject(tempIndexesDictionary, forKey: "indexes")
        
        return categoryWithItemsAndIndexes.copy() as! NSDictionary
    }

}
