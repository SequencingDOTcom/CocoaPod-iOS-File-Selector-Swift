//
//  SQFilesSectionInfo.swift
//  oauthdemoapp-swift
//
//  Created by Bogdan Laukhin on 9/9/16.
//  Copyright © 2016 ua.org. All rights reserved.
//

import Foundation
import UIKit


class SQFilesSectionInfo: NSObject {
    
    var sectionName: String
    var filesArray: NSMutableArray
    var rowHeights: NSMutableArray
    
    
    // MARK: - Initializer
    init(name: String) {
        self.sectionName = name
        self.filesArray = NSMutableArray()
        self.rowHeights = NSMutableArray()
    }
    
    
    
    // MARK: - Insert objects
    func addFile(file: NSDictionary, WithHeight height:CGFloat) -> Void {
        filesArray.addObject(file)
        self.insertObject(height, InRowHeightsAtIndex: filesArray.count - 1)
    }
    
    
    func insertObject(object: AnyObject, InRowHeightsAtIndex index: Int) -> Void {
        rowHeights.insertObject(object, atIndex: index)
    }
    
    
    
    // MARK: - Return row height
    func objectInRowHeightsAtIndex(index: Int) -> AnyObject {
        return rowHeights.objectAtIndex(index)
    }
    

}
