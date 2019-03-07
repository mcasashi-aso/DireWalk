//
//  ActivityViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/02/27.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import HealthKit

class ActivityViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var healthStore = HKHealthStore()
    
    let datas: [CellData] = [CellData.init(about: "アクティビティ", number: 20, unit: "分"),
                             CellData.init(about: "歩数", number: 8672, unit: "歩")]
    
//    func getStepCount() -> CellData{
//        let now = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyyMMdd"
//        let todayAtO = dateFormatter.string(from: now)
//        let startDate = dateFormatter.date(from: todayAtO)
//        let endDate = now
//
//        let typeOfStepCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
//
//        let
//
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ActivityCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ActivityCollectionViewCell
        cell.layer.cornerRadius = cell.bounds.height / 6
        cell.layer.masksToBounds = true
        cell.setData(cellData: datas[indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let width = CGFloat((screenWidth - 24*2 - 24) / 2)
        let size = CGSize(width: width, height: width)
        return size
    }
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
