//
//  SQFilesSectionInfo.swift
//  Copyright © 2017 Sequencing.com. All rights reserved
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
    func addFile(_ file: NSDictionary, WithHeight height:CGFloat) -> Void {
        filesArray.add(file)
        self.insertObject(height as AnyObject, InRowHeightsAtIndex: filesArray.count - 1)
    }
    
    
    func insertObject(_ object: AnyObject, InRowHeightsAtIndex index: Int) -> Void {
        rowHeights.insert(object, at: index)
    }
    
    
    
    // MARK: - Return row height
    func objectInRowHeightsAtIndex(_ index: Int) -> AnyObject {
        return rowHeights.object(at: index) as AnyObject
    }
    

}
