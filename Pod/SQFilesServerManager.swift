//
//  SQFilesServerManager.swift
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

import Foundation


class SQFilesServerManager: NSObject {
    
    // parameters for files request
    let apiURL: String      = "https://api.sequencing.com"
    let filesPath: String   = "/DataSourceList?all=true";
    
    
    
    // MARK: - Initializer
    static let instance = SQFilesServerManager()
    
    
    
    // MARK: - Genetic files method
    func getForFilesWithToken(accessToken: String, completion: (filesArray: NSArray?, error: NSError?) -> Void ) -> Void {
        
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
                    let jsonData = responseText?.dataUsingEncoding(NSUTF8StringEncoding)
                    do {
                        if let jsonParsed = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: []) as? NSArray {
                            completion(filesArray: jsonParsed, error: nil)
                        }
                    } catch let error as NSError {
                        print("json error" + error.localizedDescription)
                        completion(filesArray: nil, error: error)
                    }
                    
                } else if error != nil {
                    print("json error" + error!.localizedDescription)
                    print("server response: ")
                    print(response)
                    completion(filesArray: nil, error: error)
                }
        }
        
    }
    
    
}
