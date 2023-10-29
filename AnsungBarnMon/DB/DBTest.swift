//
//  DBTest.swift
//  AnsungBarnMon
//
//  Created by 센코 on 10/27/23.
//

import UIKit

class DBTest: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    /**
        Non Body
     */
    func requestGet(type: String, url: String, completionHandler: @escaping (Bool, Any) -> Void) {
        guard let url = URL(string: url) else {
            print("Error: cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            guard error == nil else {
                print("Error: error calling GET")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did Not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            switch type {
            case "current":
                guard let output = try? JSONDecoder().decode(CurrentResponse.self, from: data) else {
                    print("Error: JSON Data Parsing failed")
                    return
                }
                completionHandler(true, output.list)
            case "week":
                guard let output = try? JSONDecoder().decode(WeekResponse.self, from: data) else {
                    print("Error: JSON Data Parsing failed")
                    return
                }
                completionHandler(true, output.list)
            default:
                return
            }
            
        }.resume()
    }

    /**
        With Body
     */
    func requestPost(url: String, method: String, param: [String: Any], completionHandler: @escaping (Bool, Any) -> Void) {
        
    }

    func request(_ type: String, _ url: String, _ method: String, _ param: [String: Any]? = nil, completionHandler: @escaping (Bool, Any) -> Void) {
        
        if method == "GET" {
            requestGet(type: type, url: url) {
                (success, data) in completionHandler(success, data)
            }
        } else {
            requestPost(url: url, method: method, param: param!) {
                (success, data) in completionHandler(success, data)
            }
        }
    }

}
