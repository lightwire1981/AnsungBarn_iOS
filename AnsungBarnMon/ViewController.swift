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
var btnPosition = false

class ViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var todayListView: FadingEdgesCollectionView!
    @IBOutlet weak var weekListView: UICollectionView!
    @IBOutlet weak var weekListPageControl: UIPageControl!
    @IBOutlet weak var lBlCurrentRegionTime: UILabel!
    @IBOutlet weak var lBlCurrentRegionValue: UILabel!
    @IBOutlet weak var lBlCurrentRegionName: UILabel!
    @IBOutlet weak var iVwCurrentRegionStatus: UIImageView!
    
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var btnHiddenLogin: UIButton!
    
    let blurEffect = UIBlurEffect(style: .dark)
    var currentModel = CurrentViewModel()
    var weekModel = DailyViewModel()
    
    
    var updateTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard Reachability.networkConnected() else {
                    let alert = UIAlertController(title: "NetworkError", message: "네트워크가 연결되어있지 않습니다.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "종료", style: .default) { (action) in
                        exit(0)
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }

        todayListView.tag = 1
        todayListView.showArrows = false
        todayListView.showGradients = true
        todayListView.gradientLength = 100.0
        
        weekListView.tag = 2
        
        setMainPage()
        self.navigationController?.navigationBar.isHidden = true
        
        setCurrentData()
        setWeekData()
        
        updateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateInfo), userInfo: nil, repeats: true)
        
        btnHiddenLogin.addTarget(self, action: #selector(hiddenLogin(_:event:)), for: UIControl.Event.touchDownRepeat)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    @IBOutlet weak var btnPrivacy: UIButton!
    
    func setMainPage() {
        let id = Util().loadUserID()
        if id == "" {
            
        } else {
            setLoginButton()
        }
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
    
    func setLoginButton() {
        if !btnPosition {
            btnPosition = true
            btnPrivacy.layer.position.x -= 120
        }
        
        let btnLogin = UIButton(frame: CGRect(x: self.view.frame.size.width-130, y: self.view.frame.size.height-self.footerView.frame.height, width: 130, height: self.footerView.frame.height))
        btnLogin.setTitleColor(.white, for: .normal)
        btnLogin.setTitleColor(.gray, for: .highlighted)
        btnLogin.setTitle("농장주 로그인", for: .normal)
        btnLogin.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .bold)
        btnLogin.backgroundColor = UIColor(hexCode: "EA5F3C", alpha: 1.0)
        btnLogin.addTarget(self, action: #selector(login), for: .touchUpInside)

        self.view.addSubview(btnLogin)
    }
    
    @objc func updateInfo() {
        print("<<<<<< Data Updated")
        setCurrentData()
        setWeekData()
        Toast(message: "정보가 업데이트 되었습니다")
    }
    
    @objc func hiddenLogin(_ sender: UIButton, event: UIEvent) {
        let touch: UITouch = event.allTouches!.first!
        if (touch.tapCount == 5) {
            
            let id = Util().loadUserID()

            if id == "" {
                let storyBoard = UIStoryboard.init(name: "Popup", bundle: nil)    // Popup 스토리보드를 가져옴
                let popupVC = storyBoard.instantiateViewController(identifier: "PopupVC")as! PopupViewController  // identifier는 뷰컨트롤러의 storyboard ID.
                
                popupVC.modalPresentationStyle = .overCurrentContext    //  투명도가 있으면 투명도에 맞춰서 나오게 해주는 코드(뒤에있는 배경이 보일 수 있게)
                
                popupVC.temp = {
                    let id = Util().loadUserID()
                    if id == "" {
                        let alert = UIAlertController(title:"아이디 확인 불가", message: "해당하는 아이디가 없습니다", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "확인", style: .default)
                        alert.addAction(okAction)
                        self.present(alert, animated: false, completion: nil)
                    } else {
                        self.setLoginButton()
                        if self.navigationController != nil {
                            if !(self.navigationController?.topViewController?.description.contains("webViewController"))! {
                                let _: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                guard let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "webViewController") as? WebViewController else { return }
                                // 화면 전환 애니메이션 설정
                                webViewController.userID = id
                                webViewController.type = "login"
                                self.navigationController?.pushViewController(webViewController, animated: true)
                                
                            }
                        }
                    }
                    
                }
                self.present(popupVC, animated: false, completion: nil)
            }
//            } else {
//                
//                if let navigationController = self.navigationController {
//                    if !(self.navigationController?.topViewController?.description.contains("webViewController"))! {
//                        let _: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                        guard let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "webViewController") as? WebViewController else { return }
//                        // 화면 전환 애니메이션 설정
//                        webViewController.userID = id
//                        webViewController.type = "login"
//                        self.navigationController?.pushViewController(webViewController, animated: true)
//                        
//                    }
//                }
//            }
        }
    }
    @objc func login() {
        let id = Util().loadUserID()
        if self.navigationController != nil {
            if !(self.navigationController?.topViewController?.description.contains("webViewController"))! {
                let _: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                guard let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "webViewController") as? WebViewController else { return }
                // 화면 전환 애니메이션 설정
                webViewController.userID = id
                webViewController.type = "login"
                self.navigationController?.pushViewController(webViewController, animated: true)
                
            }
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.tag == 2 {
            let page = Int(targetContentOffset.pointee.x / self.weekListView.frame.width)
            weekListPageControl.currentPage = page
        }
    }
    
    @IBAction func btnPrivacy(_ sender: Any) {
        
        if let navigationController = self.navigationController {
            if !(navigationController.topViewController?.description.contains("webViewController"))! {
                let _: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                guard let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "webViewController") as? WebViewController else { return }
                        // 화면 전환 애니메이션 설정
                webViewController.type = "privacy"
//                webViewController.modalTransitionStyle = .crossDissolve
//                // 전환된 화면이 보여지는 방법 설정 (fullScreen)
//                webViewController.modalPresentationStyle = .fullScreen
                navigationController.pushViewController(webViewController, animated: true)
                updateTimer.invalidate()
            }
        }
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

extension ViewController {
    func Toast(message: String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height-100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension UIColor {
    
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}
