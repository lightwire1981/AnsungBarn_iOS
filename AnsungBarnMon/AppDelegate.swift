//
//  AppDelegate.swift
//  AnsungBarnMon
//
//  Created by 센코 on 2023/10/10.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var CurrentRegion = RegionInfo(regionGroup: "11", regionName: "", regionTime: "", regionValue: "0")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if Util().loadRegion() == "" {
            let _: () = request("current", "https://livestock.kr/be/appRealList.do", "GET", completionHandler: {(success, data) in
                RegionDataList = data as! [CurrentData]
                
                print("Region Data : ",RegionDataList)
                print("Region Data Count : ", RegionDataList.count)
                Util().saveRegion(regionID: RegionDataList[0].sys_op_group_id)
                self.CurrentRegion.regionGroup = RegionDataList[0].sys_op_group_id
                self.CurrentRegion.regionName = RegionDataList[0].group_name
                self.CurrentRegion.regionTime = RegionDataList[0].real_timestamp
                self.CurrentRegion.regionValue = RegionDataList[0].real_level
            })
        } else {
            CurrentRegion.regionGroup = Util().loadRegion()
        }
        sleep(1)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

