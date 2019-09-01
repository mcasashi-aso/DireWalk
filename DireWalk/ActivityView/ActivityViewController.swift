//
//  ActivityViewController.swift
//  DireWalk
//
//  Created by 麻生昌志 on 2019/02/27.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import HealthKit
import CoreMotion
import GoogleMobileAds


// 直す気すら起こらないクソコードの塊()
class ActivityViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate {
    
    var healthStore = HKHealthStore()
    
    var datas: [CellData] = [
        CellData(about:  "walkingDistance".localized,
                 number: "error".localized,
                 unit:   "pleaseAllow".localized),
        CellData(about:  "steps".localized,
                 number: "error".localized,
                 unit:   "pleaseAllow".localized),
        CellData(about:  "flightsClimbed".localized,
                 number: "error".localized,
                 unit:   "pleaseAllow".localized),
        CellData(about:  "DireWalk".localized,
                 number: "error".localized,
                 unit:   "pleaseAllow".localized)
    ]
    
    func checkUpdateHealth() {
        if checkAuthorization(type: [HKObjectType.quantityType(forIdentifier: .stepCount)!]) {
            guard let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else { return }
            let observerQuery: HKObserverQuery = HKObserverQuery(sampleType: type, predicate: nil, updateHandler: {
                (query, completionHandler, error) in
                self.getStepCount()
            })
            healthStore.execute(observerQuery)
        }
        if checkAuthorization(type: [HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!]) {
            guard let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning) else { return }
            let observerQuery: HKObserverQuery = HKObserverQuery(sampleType: type, predicate: nil, updateHandler: { query, completionHandler, error in
                self.getWalkingDistance()
            })
            healthStore.execute(observerQuery)
        }
        if checkAuthorization(type: [HKObjectType.quantityType(forIdentifier: .flightsClimbed)!]) {
            guard let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed) else { return }
            let observerQuery: HKObserverQuery = HKObserverQuery(sampleType: type, predicate: nil, updateHandler: { query, completionHandler, error in
                self.getFlightsClimbed()
            })
            healthStore.execute(observerQuery)
        }
        getDireWalkUsingTimes()
    }
    
    func getStepCount() {
        let now = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year, .month, .day], from: now)
        guard let startDate = calender.date(from: components) else { return }
        guard let endDate = calender.date(byAdding: .day, value: 1, to: startDate) else { return }
        
        guard let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        var steps = 0
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil, resultsHandler: { query, results, error in
            guard let samples = results as? [HKQuantitySample] else { return }
            DispatchQueue.main.async {
                for sample in samples {
                    steps += Int(sample.quantity.doubleValue(for: HKUnit.count()))
                }
                var unit: String!
                if steps == 1 || steps == 0 {
                    unit = "stepsUnit".localized
                }else {
                    unit = "stepsUnits".localized
                }
                let cellData = CellData(about: "steps".localized,
                                        number: String(steps),
                                        unit: unit)
                self.datas[1] = cellData
                self.collectionView.reloadData()
            }
        })
        healthStore.execute(query)
        
    }
    func getWalkingDistance() {
        let now = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year, .month, .day], from: now)
        guard let startDate = calender.date(from: components) else { return }
        guard let endDate = calender.date(byAdding: .day, value: 1, to: startDate) else { return }
        
        guard let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        var distance = 0.0
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil, resultsHandler: { query, results, error in
            guard let samples = results as? [HKQuantitySample] else { return }
            DispatchQueue.main.sync {
                for sample in samples {
                    distance += sample.quantity.doubleValue(for: HKUnit.meter())
                }
                let cellData = CellData(about: "walkingDistance".localized,
                                        number: String(ceil(distance / 100.0) / 10.0),
                                        unit: "walkingDistanceUnit".localized)
                self.datas[0] = cellData
                self.collectionView.reloadData()
            }
        })
        healthStore.execute(query)
    }
    func getFlightsClimbed() {
        let now = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year, .month, .day], from: now)
        guard let startDate = calender.date(from: components) else { return }
        guard let endDate = calender.date(byAdding: .day, value: 1, to: startDate) else { return }
        
        guard let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        var climbed = 0
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil, resultsHandler: { query, results, error in
            guard let samples = results as? [HKQuantitySample] else { return }
            DispatchQueue.main.async {
                for sample in samples {
                    climbed += Int(sample.quantity.doubleValue(for: HKUnit.count()))
                }
                var unit: String!
                if climbed == 1 || climbed == 0 {
                    unit = "flightsClimbedUnit".localized
                }else {
                    unit = "flightsClimbedUnits".localized
                }
                let cellData = CellData(about: "flightsClimbed".localized,
                                        number: String(climbed),
                                        unit: unit)
                self.datas[2] = cellData
                self.collectionView.reloadData()
            }
        })
        healthStore.execute(query)
    }
    func getDireWalkUsingTimes() {
        guard let usingTimes = UserDefaults.standard.get(.usingTimes) else { return }
        var unit: String!
        let usingTimesMinutes = Int(ceil(Double(usingTimes) / 60.0))
        if usingTimesMinutes == 1 || usingTimes == 0 {
            unit = "DireWalkUnit".localized
        }else {
            unit = "DireWalkUnits".localized
        }
        
        let cellData = CellData(about: "DireWalk".localized,
                                number: String(usingTimesMinutes),
                                unit: unit)
        datas[3] = cellData
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
        // (datas.count / 2) * (1 + 3) + 1 + 1 + (4 + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0, 6, 12, 1, 3, 5, 7, 9, 11, 13:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BlankCell", for: indexPath)
            return cell
        case 2, 4, 8, 10:
            var dataNumber: Int!
            switch indexPath.row {
            case 2: dataNumber = 0
            case 4: dataNumber = 1
            case 8: dataNumber = 2
            case 10: dataNumber = 3
            default: break
            }
            let cell: ActivityCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ActivityCollectionViewCell
            cell.layer.cornerRadius = cell.bounds.height / 6
            cell.setInset(constant: cell.bounds.height / 8)
            cell.layer.masksToBounds = true
            cell.numberLabel.font = cell.numberLabel.font.withSize(cell.numberLabel.bounds.height)
            cell.setData(cellData: datas[dataNumber])
            return cell
        case 14:
            let cell: AdCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdCell", for: indexPath) as! AdCollectionViewCell
            cell.adView.adUnitID = "ca-app-pub-7482106968377175/6483821918"
            cell.adView.rootViewController = self
            let request = GADRequest()
            request.testDevices = ["08414f421dd5519a221bf0414a3ec95e"]
            cell.adView.load(request)
            cell.adView.delegate = self
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BlankCell", for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let activityWidth = CGFloat((screenWidth - 24*2 - 24) / 2)
        switch indexPath.row {
        case 0, 6, 12:
            // 横に細長いBlank
            return CGSize(width: screenWidth, height: 24)
        case 1, 3, 5, 7, 9, 11:
            // 縦に細長いActivity用のBlank
            return CGSize(width: 24, height: 24)
        case 2, 4, 8, 10:
            // Activity
            return CGSize(width: activityWidth, height: activityWidth * 4/5)
        case 13:
            // BannerAdの横
            return CGSize(width: ((screenWidth - 320) / 2), height: 24)
        case 14:
            // BannerAd
            return CGSize(width: 320, height: 100)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        checkUpdateHealth()
    }

    func checkAuthorization(type: Set<HKObjectType>) -> Bool {
        var isEnabled = true
        
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: nil, read: type, completion: { success, error in
                isEnabled = success
            })
        }else {
            isEnabled = false
        }
        return isEnabled
    }
    
}
