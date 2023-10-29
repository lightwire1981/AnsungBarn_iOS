//
//  SideMenuController.swift
//  AnsungBarnMon
//
//  Created by 센코 on 10/25/23.
//

import UIKit

var RegionDataList: [CurrentData] = []
class SideMenuController: UIViewController {
    
    @IBOutlet weak var tBlRegionListView: UITableView!
    @IBOutlet weak var CurrentRegionView: UIView!
    @IBOutlet weak var lBlCurrentRegionValue: UILabel!
    @IBOutlet weak var lBlCurrentRegionName: UILabel!
    @IBOutlet weak var iVwCurrentRegionStatus: UIImageView!
    
    var regionModel = RegionViewModel()
    
    let currentRegion = UIApplication.shared.delegate as? AppDelegate
    
    var selectedRegion: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMainView()
    }
    
    func setRegionData() {
        let _: () = request("current", "https://livestock.kr/be/appRealList.do", "GET", completionHandler: {(success, data) in
            RegionDataList = data as! [CurrentData]
            print("Region Data : ",RegionDataList)
            print("Region Data Count : ", RegionDataList.count)
            DispatchQueue.main.async {
                self.regionModel = RegionViewModel()
                self.tBlRegionListView.reloadData()
            }
        })
    }
}

extension SideMenuController : UITableViewDelegate, UITableViewDataSource {
    
    func setMainView() {
        lBlCurrentRegionName.text = currentRegion?.CurrentRegion.regionName
        lBlCurrentRegionValue.text = Util().convertStatus(value: currentRegion?.CurrentRegion.regionValue ?? "")
        iVwCurrentRegionStatus.image = UIImage(named: Util().convertImage(value: currentRegion?.CurrentRegion.regionValue ?? ""))
        setRegionData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regionModel.countRegionList
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellRegionItem = tableView.dequeueReusableCell(withIdentifier: "cellRegionItem", for: indexPath) as? CellRegionItem else {
            return UITableViewCell()
        }
        let regionInfo = regionModel.regionInfo(at: indexPath.item)
        cellRegionItem.update(info: regionInfo)
        return cellRegionItem
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedRegionGroup = regionModel.regionInfo(at: indexPath.item).regionGroup
        let selectedRegionName = regionModel.regionInfo(at:indexPath.item).regionName
        let selectedRegionTime = regionModel.regionInfo(at: indexPath.item).regionTime
        let selectedRegionValue = regionModel.regionInfo(at: indexPath.item).regionValue
        print("Click Cell Number: " + String(indexPath.row))
        print("Click Cell Group: " + selectedRegionGroup)
        selectedRegion = selectedRegionName
        Util().saveRegion(regionID: selectedRegionGroup)
        currentRegion?.CurrentRegion.regionGroup = selectedRegionGroup
        currentRegion?.CurrentRegion.regionName = selectedRegionName
        currentRegion?.CurrentRegion.regionTime = selectedRegionTime
        currentRegion?.CurrentRegion.regionValue = selectedRegionValue
        setMainView()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
            self.dismiss(animated: true)
        }
    }
    
    public func getRegion() -> String {
        return selectedRegion
    }
}

class CellRegionItem: UITableViewCell {
    
    @IBOutlet weak var lBlRegionValue: UILabel!
    @IBOutlet weak var iVwRegionStatus: UIImageView!
    @IBOutlet weak var lBlRegionName: UILabel!
    
    func update(info: RegionInfo) {
        lBlRegionName.text = info.regionName
        lBlRegionValue.text = Util().convertStatus(value: info.regionValue)
        iVwRegionStatus.image = UIImage(named: Util().convertImage(value: info.regionValue)) 
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top:5, left:0, bottom:5, right:0))
    }
}

var regionInfoList: [RegionInfo] = []
class RegionViewModel {
    
    init() {
        if RegionDataList.count > 0 {
            regionInfoList.removeAll()
            
            for index in 0...RegionDataList.count-1 {
                let record = RegionInfo(regionGroup: RegionDataList[index].sys_op_group_id, regionName: RegionDataList[index].group_name, regionTime: RegionDataList[index].real_timestamp, regionValue: RegionDataList[index].real_level)
                regionInfoList.append(record)
            }
        }
    }
    
    var countRegionList: Int {
        return regionInfoList.count
    }
    
    func regionInfo(at index: Int) -> RegionInfo {
        return regionInfoList[index]
    }
}
