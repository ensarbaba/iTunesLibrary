//
//  APIClient.swift
//  iTunesLibrary
//
//  Created by Ensar Baba on 4.07.2020.
//  Copyright © 2020 Ensar Baba. All rights reserved.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    private init() {}
    
    func search(term: String, mediaType: String = "all", completion: @escaping (_ success: Bool, _ message: String?, _ response: SearchResponse?) -> ()) {
       let path = "term=\(term)&media=\(mediaType)"
        guard let escapedString = path.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) else {return}

        get(request: clientURLRequest(path: "search?\(escapedString)&limit=100")) { (success, object) -> () in
                 if success && object != nil {
                    let decodedResponse = try? JSONDecoder().decode(SearchResponse.self, from: object!)
                    completion(true, nil, decodedResponse)
                 } else {
                     let message = "there was an error"
                    completion(true, message, nil)
                 }
         }

    }
    private func clientURLRequest(path: String, params: Dictionary<String, Any>? = nil) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: URL(string:  "https://itunes.apple.com/"+path)!)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        if (params != nil) {
            let jsonData = try? JSONSerialization.data(withJSONObject: params as Any)
            request.httpBody = jsonData

        }
        
        return request
    }
    private func post(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: Data?) -> ()) {
        dataTask(request: request, method: "POST", completion: completion)
    }

    private func put(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: Data?) -> ()) {
        dataTask(request: request, method: "PUT", completion: completion)
    }

    private func get(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: Data?) -> ()) {
        dataTask(request: request, method: "GET", completion: completion)
    }
    private func dataTask(request: NSMutableURLRequest, method: String, completion: @escaping (_ success: Bool, _ object: Data?) -> ()) {
        request.httpMethod = method
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if let responseData = data {
                completion(true, responseData)
            } else {
                completion(false, nil)
            }
        }.resume()

    }
}
