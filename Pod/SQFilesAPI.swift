//
//  SQFilesAPI.swift
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

import Foundation


@objc public protocol SQFileSelectorProtocolDelegate: class {
    func handleFileSelected(file: NSDictionary)
    
    optional func closeButtonPressed()
}



public class SQFilesAPI: NSObject {
    
    
    public weak var selectedFileDelegate: SQFileSelectorProtocolDelegate?
    
    public var closeButton:    Bool = false
    public var selectedFileID: NSString?
    public var videoFileName:  NSString?
    public var accessToken = NSString()
    
    
    
    // MARK: - Initializer
    public static let instance = SQFilesAPI()
    
    
    
    // MARK: - API methods
    public func loadFilesWithToken(accessToken: NSString, success: (success: Bool) -> Void) -> Void {
        self.accessToken = accessToken
        
        self.loadFilesFromServer { (files) in
            if files != nil {
                SQFilesHelper.instance.parseFilesMainArray(files!, WithCompletion: { (mySectionsArray, sampleSectionsArray) in
                    if mySectionsArray != nil || sampleSectionsArray != nil  {
                        SQFilesContainer.instance.mySectionsArray = mySectionsArray
                        SQFilesContainer.instance.sampleSectionsArray = sampleSectionsArray
                        success(success: true)
                        
                    } else {
                        success(success: false)
                    }
                })
            } else {
                success(success: false)
            }
        }
    }
    
    
    
    func loadFilesFromServer(files: (files: NSArray?) -> Void) -> Void {
        SQFilesServerManager.instance.getForFilesWithToken(self.accessToken as String) { (filesArray, error) in
            if filesArray != nil {
                print(filesArray)
                files(files: filesArray)
                
            } else if error != nil {
                print(error?.localizedDescription)
                files(files: nil)
            }
        }
    }

    
    
    
}
