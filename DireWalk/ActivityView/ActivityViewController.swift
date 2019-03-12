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

class ActivityViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var healthStore = HKHealthStore()
    
    var datas: [CellData] = [
        CellData(about: NSLocalizedString("walkingDistance", comment: ""),
                 number: NSLocalizedString("error", comment: ""),
                 unit: NSLocalizedString("pleaseAllow", comment: "")),
        CellData(about: NSLocalizedString("steps", comment: ""),
                 number: NSLocalizedString("error", comment: ""),
                 unit: NSLocalizedString("pleaseAllow", comment: "")),
        CellData(about: NSLocalizedString("flightsClimbed", comment: ""),
                 number: NSLocalizedString("error", comment: ""),
                 unit: NSLocalizedString("pleaseAllow", comment: "")),
        CellData(about: NSLocalizedString("DireWalk", comment: ""),
                 number: NSLocalizedString("error", comment: ""),
                 unit: NSLocalizedString("pleaseAllow", comment: "")),
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
                    unit = NSLocalizedString("stepsUnit", comment: "")
                }else {
                    unit = NSLocalizedString("stepsUnits", comment: "")
                }
                let cellData = CellData(about: NSLocalizedString("steps", comment: ""),
                                        number: String(steps),
                                        unit: unit)
                print("置き換え")
                self.datas[1] = cellData
                print("reload")
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
                let cellData = CellData(about: NSLocalizedString("walkingDistance", comment: ""),
                                        number: String(ceil(distance / 100.0) / 10.0),
                                        unit: NSLocalizedString("walkingDistanceUnit", comment: ""))
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
                    unit = NSLocalizedString("flightsClimbedUnit", comment: "")
                }else {
                    unit = NSLocalizedString("flightsClimbedUnits", comment: "")
                }
                let cellData = CellData(about: NSLocalizedString("flightsClimbed", comment: ""),
                                        number: String(climbed),
                                        unit: unit)
                self.datas[2] = cellData
                self.collectionView.reloadData()
            }
        })
        healthStore.execute(query)
    }
    func getDireWalkUsingTimes() {
        let usingTimes = UserDefaults.standard.integer(forKey: ud.key.usingTimes.rawValue)
        var unit: String!
        if usingTimes == 1 || usingTimes == 0 {
            unit = NSLocalizedString("DireWalkUnit", comment: "")
        }else {
            unit = NSLocalizedString("DireWalkUnits", comment: "")
        }
        
        let cellData = CellData(about: NSLocalizedString("DireWalk", comment: ""),
                                number: String(usingTimes),
                                unit: unit)
        datas[3] = cellData
        collectionView.reloadData()
    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
