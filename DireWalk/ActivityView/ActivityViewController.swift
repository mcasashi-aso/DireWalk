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

// TODO: CollectionViewで組み立てる方式以外にしたい
// TODO: Activity以外のコンテンツにしないとiPadには対応できないぞ
final class ActivityViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate {
    
    static func create() -> ActivityViewController {
        let sb = UIStoryboard(name: "Activity", bundle: nil)
        return sb.instantiateInitialViewController() as! ActivityViewController
    }
    
    var healthStore = HKHealthStore()
    
    var datas: [ActivityData] = [
        ActivityData(about:  "walkingDistance".localized,
                     number: "error".localized,
                     unit:   "pleaseAllow".localized),
        ActivityData(about:  "steps".localized,
                     number: "error".localized,
                     unit:   "pleaseAllow".localized),
        ActivityData(about:  "flightsClimbed".localized,
                     number: "error".localized,
                     unit:   "pleaseAllow".localized),
        ActivityData(about:  "DireWalk".localized,
                     number: "error".localized,
                     unit:   "pleaseAllow".localized)
    ]
    
    func setQueries() {
        func check(identifier: HKQuantityTypeIdentifier, updateHandler: @escaping () -> Void) {
            guard let type = HKObjectType.quantityType(forIdentifier: identifier) else { return }
            if checkAuthorization(type: [type]) {
                let observerQuery = HKObserverQuery(sampleType: type, predicate: nil) { _,_,_  in
                    updateHandler()
                }
                healthStore.execute(observerQuery)
            }
        }
        check(identifier: .stepCount) { self.updateStepCount() }
        check(identifier: .distanceWalkingRunning) { self.updateWalkingDistance() }
        check(identifier: .flightsClimbed) { self.updateFlightsClimbed() }
        updateDireWalkUsingTimes()
    }
    
    func getPredicate() -> NSPredicate? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        guard let startDate = calendar.date(from: components) else { return nil }
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return nil }
        return HKQuery.predicateForSamples(withStart: startDate, end: endDate)
    }
    
    func getHealthData(_ identifier: HKQuantityTypeIdentifier, unit: HKUnit, completion: @escaping (Double) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: identifier) else { return }
        var count = 0.0
        let query = HKSampleQuery(sampleType: type, predicate: getPredicate(), limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { query, results, error in
            guard let samples = results as? [HKQuantitySample] else { return }
            DispatchQueue.main.async {
                count += samples.map { $0.quantity.doubleValue(for: unit) }.reduce(0, +)
                completion(count)
            }
        }
        healthStore.execute(query)
    }
    
    func updateStepCount() {
        getHealthData(.stepCount, unit: .count()) { count in
            let steps = Int(count)
            let unit = (steps == 1 || steps == 0) ? "stepsUnit" : "stepsUnits"
            let cellData = ActivityData(about: "steps".localized,
                                        number: String(steps),
                                        unit: unit.localized)
            self.datas[1] = cellData
            self.collectionView.reloadData()
        }
    }
    func updateWalkingDistance() {
        getHealthData(.distanceWalkingRunning, unit: .meter()) { distance in
            let cellData = ActivityData(about: "walkingDistance".localized,
                                        number: String(ceil(distance / 100.0) / 10.0),
                                        unit: "walkingDistanceUnit".localized)
            self.datas[0] = cellData
            self.collectionView.reloadData()
        }
    }
    func updateFlightsClimbed() {
        getHealthData(.flightsClimbed, unit: .count()) { count in
            let climbed = Int(count)
            let unit = (climbed == 1 || climbed == 0) ? "flightsClimbedUnit" : "flightsClimbedUnits"
            let cellData = ActivityData(about: "flightsClimbed".localized,
                                        number: String(climbed),
                                        unit: unit.localized)
            self.datas[2] = cellData
            self.collectionView.reloadData()
        }
    }
    func updateDireWalkUsingTimes() {
        guard let usingTimes = UserDefaults.standard.get(.usingTimes) else { return }
        let usingTimesMinutes = Int(ceil(Double(usingTimes) / 60.0))
        let unit = (usingTimesMinutes == 1 || usingTimes == 0) ? "DireWalkUnit" : "DireWalkUnits"
        let cellData = ActivityData(about: "DireWalk".localized,
                                    number: String(usingTimesMinutes),
                                    unit: unit.localized)
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
            if #available(iOS 13, *) {
                cell.layer.cornerCurve = .continuous
            }
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
        setQueries()
    }

    func checkAuthorization(type: Set<HKObjectType>) -> Bool {
        var isEnabled = true
        
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: nil, read: type) { success, error in
                isEnabled = success
            }
        } else {
            isEnabled = false
        }
        return isEnabled
    }
    
}
