//
//  data.swift
//  AnsungBarnMon
//
//  Created by 센코 on 10/24/23.
//

import UIKit

struct RegionInfo {
    var regionGroup: String
    var regionName: String
    var regionTime: String
    var regionValue: String
    
    init(regionGroup:String, regionName:String, regionTime:String, regionValue:String) {
        self.regionGroup = regionGroup
        self.regionName = regionName
        self.regionTime = regionTime
        self.regionValue = regionValue
    }
}

struct CurrentInfo {
    let time: String
    let value: String
    
    init(time: String, value: String) {
        self.time = time
        self.value = value
    }
    
}

struct WeekInfo {
    var dailyInfo: [DailyInfo] = []
    
    init(dailyInfo: [DailyInfo]) {
        self.dailyInfo = dailyInfo
    }
}

struct DailyInfo {
    let day: String
    let week: String
    let value: String
    
    init(day: String, week: String, value: String) {
        self.day = day
        self.week = week
        self.value = value
    }
}
