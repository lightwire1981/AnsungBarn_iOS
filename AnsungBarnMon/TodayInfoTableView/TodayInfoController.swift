//
//  TodayInfoController.swift
//  AnsungBarnMon
//
//  Created by 센코 on 10/15/23.
//

import UIKit

class TodayInfoController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: <#T##String#>, for: <#T##IndexPath#>) as? UICollectionViewCell else {
            return UICollectionViewCell()
        }
        return cell
    }
    
    
    override func viewDidLoad() {
        <#code#>
    }
}
