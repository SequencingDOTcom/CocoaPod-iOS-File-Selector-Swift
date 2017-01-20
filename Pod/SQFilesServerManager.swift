//
//  SQFilesServerManager.swift
//  Copyright © 2017 Sequencing.com. All rights reserved
//


import Foundation


class SQFilesServerManager: NSObject {
    
    // parameters for files request
    let apiURL: String      = "https://api.sequencing.com"
    let filesPath: String   = "/DataSourceList?all=true";
    
    
    
    // MARK: - Initializer
    static let instance = SQFilesServerManager()
    
    
    
    // MARK: - Genetic files method
    func getForFilesWithToken(_ accessToken: String, completion: @escaping (_ filesArray: NSArray?, _ error: NSError?) -> Void ) -> Void {
        
        let apiUrlForFiles: String = self.apiURL + self.filesPath
        
        SQFilesHttpHelper.instance.execHttpRequestWithUrl(
            apiUrlForFiles,
            method: "GET",
            headers: nil,
            username: nil,
            password: nil,
            token: accessToken,
            authScope: "Bearer",
            parameters: nil) { (responseText, response, error) in
                
                if responseText != nil {
                    
                    let tempResponseText = responseText! as NSString
                    
                    if tempResponseText.lowercased.range(of: "exception") != nil ||
                       tempResponseText.lowercased.range(of: "invalid") != nil ||
                       tempResponseText.lowercased.range(of: "error") != nil {
                        
                        print("error: " + (tempResponseText as String!))
                        completion(nil, nil)
                        
                    } else {
                        
                        let jsonData = responseText?.data(using: String.Encoding.utf8.rawValue)
                        do {
                            if let jsonParsed = try JSONSerialization.jsonObject(with: jsonData!, options: []) as? NSArray {
                                completion(jsonParsed, nil)
                            }
                        } catch let error as NSError {
                            print("json error" + error.localizedDescription)
                            completion(nil, error)
                        }
                        
                    }
                } else if error != nil {
                    print("json error" + error!.localizedDescription)
                    completion(nil, error)
                }
        }
    }
    
    
    
}
