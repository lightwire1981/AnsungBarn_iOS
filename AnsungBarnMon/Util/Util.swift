//
//  Util.swift
//  AnsungBarnMon
//
//  Created by 센코 on 10/27/23.
//

import UIKit
import Foundation

class Util {
    func saveRegion(regionID : String) {
        UserDefaults.standard.set(regionID, forKey: "REGION_ID")
    }
    
    func loadRegion() -> String {
        if let value = UserDefaults.standard.string(forKey: "REGION_ID") {
            return value
        }
        return ""
    }
    
    
    func convertStatus(value: String) -> String {
        var status = "알수없음"
        switch value {
        case "0":
            status = "좋음"
        case "1":
            status = "보통"
        case "2":
            status = "나쁨"
        case "3":
            status = "매우나쁨"
        default:
            status = "알수없음"
        }
        return status
    }
    
    func convertDate(value: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let convertDate = dateFormatter.date(from: value)
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.locale = Locale(identifier: "ko_KR")
        myDateFormatter.dateFormat = "MM.dd(E) a hh:mm"
        
//        beforeHours(baseTime: value, hour: 2)
        
        let result = myDateFormatter.string(from: convertDate!)
        
        return result
    }
    
    func beforeHours(baseTime: String, hour: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let convertDate = dateFormatter.date(from: baseTime)
        
        let interval = -hour*60*60
        let beforeHour = convertDate?.addingTimeInterval(TimeInterval(interval))
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.locale = Locale(identifier: "ko_KR")
        myDateFormatter.dateFormat = "a h시"
//        print(myDateFormatter.string(from: beforeHour!))
        return myDateFormatter.string(from: beforeHour!)
    }
    
    func beforeDays(interval: Int) -> String {
        let now = Date()
        
        let interval = -interval*60*60*24
        let beforeDay = now.addingTimeInterval(TimeInterval(interval))
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.locale = Locale(identifier: "ko_KR")
        myDateFormatter.dateFormat = "MM월 dd일"
        return myDateFormatter.string(from: beforeDay)
    }
    
    func beforeWeekName(interval: Int) -> String {
        let now = Date()
        
        let interval = -interval*60*60*24
        let beforeWeekName = now.addingTimeInterval(TimeInterval(interval))
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.locale = Locale(identifier: "ko_KR")
        myDateFormatter.dateFormat = "EEEE"
        return myDateFormatter.string(from: beforeWeekName)
    }
    
    func convertImage(value: String) -> String {
        var imgUrl = ""
        switch value {
        case "0":
            imgUrl = "emoticon1.png"
        case "1":
            imgUrl = "emoticon2.png"
        case "2":
            imgUrl = "emoticon3.png"
        case "3":
            imgUrl = "emoticon4.png"
        default:
            imgUrl = ""
        }
        
        return imgUrl
    }
}
