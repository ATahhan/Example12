//
//  API.swift
//  PinSample
//
//  Created by Ammar AlTahhan on 15/11/2018.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class API {
    
    private static var userInfo = UserInfo()
    private static var sessionId: String?
    
    static func postSession(username: String, password: String, completion: @escaping (String?)->Void) {
        guard let url = URL(string: APIConstants.SESSION) else {
            completion("Supplied url is invalid")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var errString: String?
            if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
                if statusCode >= 200 && statusCode < 300 { //Response is ok
                    
                    let newData = data?.subdata(in: 5..<data!.count)
                    if let json = try? JSONSerialization.jsonObject(with: newData!, options: []),
                        let dict = json as? [String:Any],
                        let sessionDict = dict["session"] as? [String: Any],
                        let accountDict = dict["account"] as? [String: Any]  {
                        
                        self.userInfo.key = accountDict["key"] as? String // This is used in getUserInfo(completion:)
                        self.sessionId = sessionDict["id"] as? String
                        
                        self.getUserInfo(completion: { err in
                            
                        })
                    } else { //Err in parsing data
                        errString = "Couldn't parse response"
                    }
                } else { //Err in given login credintials
                    errString = "Provided login credintials didn't match our records"
                }
            } else { //Request failed to sent
                errString = "Check your internet connection"
            }
            DispatchQueue.main.async {
                completion(errString)
            }
            
        }
        task.resume()
    }
    
    static func getUserInfo(completion: @escaping (Error?)->Void) {
        // This function is called right after the user logs in successfully
        // It uses the user's key to retreive the rest of the information (firstName and lastName) and saves it to be used later on posting a location
        // Hint: print out the retreived data in order to find out how you'll traverse the JSON object to get the firstName and lastName
    }
    
    static func getStudentLocations(limit: Int = 100, skip: Int = 0, orderBy: SLParam = .updatedAt, completion: @escaping (LocationsData?)->Void) {
        guard let url = URL(string: "\(APIConstants.STUDENT_LOCATION)?\(APIConstants.ParameterKeys.LIMIT)=\(limit)&\(APIConstants.ParameterKeys.SKIP)=\(skip)&\(APIConstants.ParameterKeys.ORDER)=-\(orderBy.rawValue)") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue(APIConstants.HeaderValues.PARSE_APP_ID, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_APP_ID)
        request.addValue(APIConstants.HeaderValues.PARSE_API_KEY, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_API_KEY)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var locationsData: LocationsData?
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
                if statusCode >= 200 && statusCode < 300 { //Response is ok
                    
                    do {
                        locationsData = try JSONDecoder().decode(LocationsData.self, from: data!)
                    } catch {
                        debugPrint(error)
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion(locationsData)
            }
            
        }
        task.resume()
    }
    
    static func postLocation(_ location: StudentLocation, completion: @escaping (String?)->Void) {
        // Here you'll implement the logic for posting a student location
        // Please refere to the roadmap file and classroom for more details
        // Note that you'll need to send (uniqueKey, firstName, lastName) along with the post request. These information should be obtained upon logging in and they should be saved somewhere (Ex. AppDelegate or in this class)
    }
    
}
