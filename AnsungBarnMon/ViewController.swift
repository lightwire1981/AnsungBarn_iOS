//
//  ViewController.swift
//  AnsungBarnMon
//
//  Created by 센코 on 2023/10/10.
//

import UIKit
import SideMenu
import FadingEdgesCollectionView


var currentRegion = UIApplication.shared.delegate as? AppDelegate
var CurrentDataList: [CurrentData] = []
var WeekDataList: [WeekData] = []

class ViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var todayListView: FadingEdgesCollectionView!
    @IBOutlet weak var weekListView: UICollectionView!
    @IBOutlet weak var weekListPageControl: UIPageControl!
    @IBOutlet weak var lBlCurrentRegionTime: UILabel!
    @IBOutlet weak var lBlCurrentRegionValue: UILabel!
    @IBOutlet weak var lBlCurrentRegionName: UILabel!
    @IBOutlet weak var iVwCurrentRegionStatus: UIImageView!
    
    let blurEffect = UIBlurEffect(style: .dark)
    var currentModel = CurrentViewModel()
    var weekModel = DailyViewModel()
    
    var updateTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        todayListView.tag = 1
        todayListView.showArrows = false
        todayListView.showGradients = true
        todayListView.gradientLength = 100.0
        
        weekListView.tag = 2
        
//        setMainPage()
        
        setCurrentData()
        setWeekData()
        
        updateTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateInfo), userInfo: nil, repeats: true)
    }
    
    func setMainPage() {

    }

    func setCurrentData() {
        let _: () = request("current", "https://livestock.kr/be/appRealList.do?sys_op_group_id="+(currentRegion?.CurrentRegion.regionGroup)!, "GET", completionHandler: {(success, data) in
            CurrentDataList = data as! [CurrentData]
            print("Current Data : ",CurrentDataList)
            print("Current Data Count : ", CurrentDataList.count)
            DispatchQueue.main.async {
                self.lBlCurrentRegionName.text = CurrentDataList[0].group_name
                self.lBlCurrentRegionTime.text = Util().convertDate(value: CurrentDataList[0].real_timestamp)
                self.lBlCurrentRegionValue.text = Util().convertStatus(value: CurrentDataList[0].real_level)
                self.iVwCurrentRegionStatus.image = UIImage(named: Util().convertImage(value: CurrentDataList[0].real_level))
                
                currentRegion?.CurrentRegion.regionGroup = CurrentDataList[0].sys_op_group_id
                currentRegion?.CurrentRegion.regionName = CurrentDataList[0].group_name
                currentRegion?.CurrentRegion.regionTime = CurrentDataList[0].real_timestamp
                currentRegion?.CurrentRegion.regionValue = CurrentDataList[0].real_level
                
                self.currentModel = CurrentViewModel()
                self.todayListView.reloadData()
            }
        })
    }
    
    func setWeekData() {
        let _: () = request("week", "https://livestock.kr/be/appWeekList.do?sys_op_group_id="+(currentRegion?.CurrentRegion.regionGroup)!, "GET", completionHandler: {(success, data) in
            WeekDataList = data as! [WeekData]
            print("Week Data : ",WeekDataList)
            print("Week Data Count : ", WeekDataList.count)
            DispatchQueue.main.async {
                self.weekModel = DailyViewModel()
                self.weekListView.reloadData()
            }
        })
    }
    
    @objc func updateInfo() {
        print("<<<<<< Data Updated")
        setCurrentData()
        setWeekData()
    }
    

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.tag == 2 {
            let page = Int(targetContentOffset.pointee.x / self.weekListView.frame.width)
            weekListPageControl.currentPage = page
        }
    }
    
    
    @IBOutlet weak var valueLabel: UILabel!
    
//    @IBOutlet weak var inputField: UITextField!
    
    @IBAction func showValue(_ sender: Any) {
//        let name = inputField.text!
//        valueLabel.text = "Hello, \(name)"
    }
    
    @IBOutlet var mainView: UIView!
    func addBlur() {
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = mainView.bounds
        blurredEffectView.alpha = 0.8
        blurredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainView.addSubview(blurredEffectView)
    }
    func removeBlur() {
        for subview in mainView.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView.tag {
        case 1:
            return currentModel.countInfoList
        case 2:
            weekListPageControl.numberOfPages = weekModel.countOfInfoList
            return weekModel.countOfInfoList
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            switch collectionView.tag {
            case 1:
                guard let cellTodayItem = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CellCurrentItem else {
                    return UICollectionViewCell()
                }
                let currentInfo = currentModel.currentInfo(at: indexPath.item)
                cellTodayItem.update(info: currentInfo)
                return cellTodayItem
            case 2:
                guard let cellWeekItem = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekListCell", for: indexPath) as? CellWeekItem else {
                    return UICollectionViewCell()
                }
                let weekInfo = weekModel.dailyInfoRow(at: indexPath.item)
//                print("????????", indexPath.item)
                cellWeekItem.update(info: weekInfo)
                return cellWeekItem
                
            default:
                guard let cellTodayItem = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CellCurrentItem else {
                    return UICollectionViewCell()
                }
                let imageInfo = currentModel.currentInfo(at: indexPath.item)
                cellTodayItem.update(info: imageInfo)
                return cellTodayItem
            }
        
    }
}

extension ViewController: SideMenuNavigationControllerDelegate {
    
//    blurEffectStyle: UIBlurEffect.Style? = nil
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        addBlur()
    }
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
            self.removeBlur()
        }
    }
//    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
//        removeBlur()
//    }
}

class CellCurrentItem: UICollectionViewCell {
    @IBOutlet weak var iVwCurrentStatus: UIImageView!
    @IBOutlet weak var lBlCurrentValue: UILabel!
    @IBOutlet weak var lBlCurrentTime: UILabel!
    func update(info: CurrentInfo) {
        let util = Util()
        lBlCurrentTime.text = info.time
        iVwCurrentStatus.image = UIImage(named: util.convertImage(value: info.value))
        lBlCurrentValue.text = util.convertStatus(value: info.value)
    }
}

class CellWeekItem: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var dailyListView: UITableView!
    var rowData: [DailyInfo] = []
    
    func update(info: [DailyInfo]) {
        rowData = info
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return (weekModel.weekInfo(at: Int)).dailyInfo.count
        return rowData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let dataList = weekModel.weekInfo(at: indexPath.item)
        
        let cell = dailyListView.dequeueReusableCell(withIdentifier: "DailyListCell", for: indexPath) as! CellDailyItem
        cell.update(info: rowData[indexPath.item])
//        print("%%%",rowData[indexPath.item])
        return cell
    }
    
    
}

class CellDailyItem: UITableViewCell {
    
    @IBOutlet weak var lBlDay: UILabel!
    @IBOutlet weak var lBlWname: UILabel!
    @IBOutlet weak var iVwDayStatus: UIImageView!
    @IBOutlet weak var lBlDayValue: UILabel!
    
    func update(info: DailyInfo) {
        
        lBlDay.text = info.day
        lBlWname.text = info.week
        lBlDayValue.text = Util().convertStatus(value: info.value)
        iVwDayStatus.image = UIImage(named: Util().convertImage(value: info.value))
    }
}







var currentInfoList: [CurrentInfo] = []
class CurrentViewModel {
    
    var valueArray = [String]()
    
    init() {
        if CurrentDataList.count > 0 {
            currentInfoList.removeAll()
            valueArray = [
                CurrentDataList[0].real_level_hour_before_01,CurrentDataList[0].real_level_hour_before_02,
                CurrentDataList[0].real_level_hour_before_03,CurrentDataList[0].real_level_hour_before_04,
                CurrentDataList[0].real_level_hour_before_05,CurrentDataList[0].real_level_hour_before_06,
                CurrentDataList[0].real_level_hour_before_07,CurrentDataList[0].real_level_hour_before_08,
                CurrentDataList[0].real_level_hour_before_09,CurrentDataList[0].real_level_hour_before_10,
                CurrentDataList[0].real_level_hour_before_11,CurrentDataList[0].real_level_hour_before_12,
                CurrentDataList[0].real_level_hour_before_13,CurrentDataList[0].real_level_hour_before_14,
                CurrentDataList[0].real_level_hour_before_15,CurrentDataList[0].real_level_hour_before_16,
                CurrentDataList[0].real_level_hour_before_17,CurrentDataList[0].real_level_hour_before_18,
                CurrentDataList[0].real_level_hour_before_19,CurrentDataList[0].real_level_hour_before_20,
                CurrentDataList[0].real_level_hour_before_21,CurrentDataList[0].real_level_hour_before_22,
                CurrentDataList[0].real_level_hour_before_23
            ]
            for index in 1...23 {
                let record = CurrentInfo(time: Util().beforeHours(baseTime: CurrentDataList[0].real_timestamp, hour: index), value: valueArray[index-1])
                currentInfoList.append(record)
            }
//            print(currentInfoList)
        }
    }
    
    var countInfoList: Int {
        print("Info Count : ",currentInfoList.count)
        return currentInfoList.count
    }
    
    func currentInfo(at index: Int) -> CurrentInfo {
        return currentInfoList[index]
    }
}

var dailyInfoList: [DailyInfo] = []
var weeklyInfoList: [[DailyInfo]] = []
class DailyViewModel {
    
    var valueArray = [[String]]()
    let util = Util()
    
    init() {
        if WeekDataList.count > 0 {
            weeklyInfoList.removeAll()
            for value in WeekDataList {
                valueArray.append([value.week_level_day_before_1, value.week_level_day_before_2,
                                   value.week_level_day_before_3, value.week_level_day_before_4,
                                   value.week_level_day_before_5, value.week_level_day_before_6,
                                   value.week_level_day_before_7])
                
            }
            print("value Array : ", valueArray)
            for index in 0...WeekDataList.count-1 {
                dailyInfoList.removeAll()
                for sudex in 1...valueArray[index].count {
                    let record = DailyInfo(day: util.beforeDays(interval: sudex), week: util.beforeWeekName(interval: sudex), value: valueArray[index][sudex-1])
                    dailyInfoList.append(record)
                }
                weeklyInfoList.append(dailyInfoList)
            }
            print("Week Data", weeklyInfoList)
        }
    }

    var countOfInfoList: Int {
        print("Week Info Count : ", weeklyInfoList.count)
        return weeklyInfoList.count
    }
    
    func dailyInfoRow(at index: Int) -> [DailyInfo] {
        return weeklyInfoList[index]
    }
}
