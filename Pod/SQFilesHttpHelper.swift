//
//  SQFilesHttpHelper.swift
//  Copyright © 2017 Sequencing.com. All rights reserved
//


import Foundation


typealias FilesHttpCallback = (_ responseText: NSString?, _ response: URLResponse?, _ error: NSError?) -> Void


class SQFilesHttpHelper: NSObject {
    
    // MARK: - Initializer
    static let instance = SQFilesHttpHelper()
    
    
    // MARK: - execHttpRequestWithUrl
    func execHttpRequestWithUrl(
        _ url: String,
        method: String,
        headers: NSDictionary?,
        username: String?,
        password: String?,
        token: String?,
        authScope: String,
        parameters: Dictionary<String, String>?,
        callback: @escaping FilesHttpCallback) -> Void {
        
        // create request by url
        let urlRequest = URL(string: url)
        let request = NSMutableURLRequest(url: urlRequest!)
        
        // set request method
        request.httpMethod = method
        
        // add headers (if any) to request HTTPHeader
        if headers != nil {
            for key in headers!.allKeys {
                let headerKey = key as! String
                if let headerValue = headers?.value(forKey: headerKey) as! String? {
                    request.addValue(headerValue, forHTTPHeaderField: headerKey)
                }
            }
        }
        
        // setting request authscope (for Authorization httpHeaderField) - either for Basic or for Bearer
        if authScope == "Basic" && username != nil && password != nil {
            
            let stringUsernameAndPassword = (username! + ":" + password!) as String
            let authData = stringUsernameAndPassword.data(using: .utf8)
            
            if authData != nil {
                if let authDataEncoded = authData?.base64EncodedString(options: []) {
                    let authValue = String(format: "%@ %@", authScope, authDataEncoded)
                    request.setValue(authValue, forHTTPHeaderField: "Authorization")
                }
            }
            
        } else if authScope == "Bearer" {
            if token != nil {
                let authValue = String(format: "%@ %@", authScope, token!)
                request.setValue(authValue, forHTTPHeaderField: "Authorization")
            }
        }
        
        // adding parameters to request HTTPBody
        if parameters != nil {
            let parametersString = self.urlEncodedString(parameters!)
            request.httpBody = parametersString.data(using: String.Encoding.utf8)
        }
        
        request.timeoutInterval = 15
        request.httpShouldHandleCookies = false
        
        let dataTask: URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, serverResponse, serverError) -> Void in
            
            if data != nil {
                if let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                    // callback(responseText: dataString, response: nil, error: nil)
                    callback(dataString, nil, nil)
                }
            }
            if serverError != nil {
                // callback(responseText: nil, response: serverResponse, error: serverError)
                callback(nil, serverResponse, serverError as NSError!)
            }
        }) 
        dataTask.resume()
    }
    
    
    func urlEncodedString(_ dict: Dictionary<String, String>) -> String {
        var parts = [String]()
        for key in dict.keys {
            if let value = dict[key] {
                let part = self.urlEncode(key) + "=" + self.urlEncode(value)
                parts.append(part)
            }
        }
        let joinedString: String = parts.joined(separator: "&")
        return joinedString
    }
    
    
    func urlEncode(_ string: String) -> String {
        if let encodedString = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return encodedString
        } else {
            return ""
        }
        // deprecated method:  .stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    }

    
}
