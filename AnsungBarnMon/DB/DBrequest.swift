//
//  DBrequest.swift
//  AnsungBarnMon
//
//  Created by 센코 on 10/26/23.
//

import UIKit

struct CurrentResponse: Codable {
    let msg: String
    let list: [CurrentData]
}

struct CurrentData: Codable {
    let sys_op_group_id: String
    let group_name: String
    let real_timestamp: String
    let real_level: String
    let real_level_hour_before_01: String
    let real_level_hour_before_02: String
    let real_level_hour_before_03: String
    let real_level_hour_before_04: String
    let real_level_hour_before_05: String
    let real_level_hour_before_06: String
    let real_level_hour_before_07: String
    let real_level_hour_before_08: String
    let real_level_hour_before_09: String
    let real_level_hour_before_10: String
    let real_level_hour_before_11: String
    let real_level_hour_before_12: String
    let real_level_hour_before_13: String
    let real_level_hour_before_14: String
    let real_level_hour_before_15: String
    let real_level_hour_before_16: String
    let real_level_hour_before_17: String
    let real_level_hour_before_18: String
    let real_level_hour_before_19: String
    let real_level_hour_before_20: String
    let real_level_hour_before_21: String
    let real_level_hour_before_22: String
    let real_level_hour_before_23: String
}

struct WeekResponse: Codable {
    let msg: String
    let list: [WeekData]
}

struct WeekData: Codable {
    let sys_op_group_id: String
    let group_name: String
    let week_level_day_before_1: String
    let week_level_day_before_2: String
    let week_level_day_before_3: String
    let week_level_day_before_4: String
    let week_level_day_before_5: String
    let week_level_day_before_6: String
    let week_level_day_before_7: String
}

struct PhoneResponse: Codable {
    let msg: String
    let result: UserID?
}

struct UserID: Codable {
    let dt_op_user_id: String
}
struct NotID: Codable {
    let msg: String
}

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
        case "user":
            
            guard let output = try? JSONDecoder().decode(PhoneResponse.self, from: data) else {
                print("Error: JSON Data Parsing failed")
                return
            }
            completionHandler(true, output)
            
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
