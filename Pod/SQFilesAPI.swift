//
//  SQAPI.swift
//  Copyright © 2017 Sequencing.com. All rights reserved
//


import Foundation


// file selector protocol
@objc public protocol SQFileSelectorProtocol: class {
    func handleFileSelected(_ file: NSDictionary)
    
    @objc optional func closeButtonPressed()
}



// file selector api class
open class SQFilesAPI: NSObject {
    
    open weak var delegate: SQFileSelectorProtocol?
    
    open var closeButton: Bool = false
    open var selectedFileID: NSString?
    open var videoFileName: NSString?
    open var accessToken = NSString()
    
    
    // MARK: - Initializer
    open static let instance = SQFilesAPI()
    
    
    
    // MARK: - API methods
    open func loadFilesWithToken(_ accessToken: NSString, closeButton: Bool, selectedFileDelegate: SQFileSelectorProtocol, result: @escaping (_ success: Bool) -> Void) -> Void {
        
        self.delegate = selectedFileDelegate
        self.closeButton = closeButton
        self.accessToken = accessToken
        
        self.loadFilesFromServer { (files) in
            if files != nil {
                SQFilesHelper.instance.parseFilesMainArray(files!, WithCompletion: { (mySectionsArray, sampleSectionsArray) in
                    if mySectionsArray != nil || sampleSectionsArray != nil  {
                        SQFilesContainer.instance.mySectionsArray = mySectionsArray
                        SQFilesContainer.instance.sampleSectionsArray = sampleSectionsArray
                        result(true)
                        
                    } else {
                        result(false)
                    }
                })
            } else {
                result(false)
            }
        }
    }
    
    
    
    func loadFilesFromServer(_ files: @escaping (_ files: NSArray?) -> Void) -> Void {
        SQFilesServerManager.instance.getForFilesWithToken(self.accessToken as String) { (filesArray, error) in
            if filesArray != nil {
                print(filesArray as NSArray!)
                files(filesArray)
                
            } else if error != nil {
                print(error!.localizedDescription)
                files(nil)
            }
        }
    }

    
    
    
}
