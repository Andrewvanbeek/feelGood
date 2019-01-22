
import UIKit
import HealthKit
import MaterialComponents.MaterialCards
import MaterialComponents.MaterialFlexibleHeader
import Material
import SCLAlertView
import Alamofire
import SwiftyJSON
import Foundation




class HealthDataViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    fileprivate var calories: String!
    fileprivate var myCollectionView: UICollectionView!
    
    let headerViewController = MDCFlexibleHeaderViewController()
    var userData = [["name": "zzz", "value": "test"], ["name": "burnedcalories", "value": "test"], ["name": "consumedcalories", "value": "test"]]
    var dataBody = ["Exercise_Calories_Burned": 0.0, "Calories_Consumed": 0.0, "Hours_Sleep": 0.0]
    override func viewDidLoad() {
        super.viewDidLoad()
        var bgUIImage = UIImage.init(named: "Maldives.jpg")
        let myInsets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        bgUIImage = bgUIImage?.resizableImage(withCapInsets: myInsets)
        self.view.backgroundColor = UIColor.init(patternImage:bgUIImage!)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getTodaysData()
        var bgUIImage = UIImage.init(named: "Maldives.jpg")
        let myInsets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        bgUIImage = bgUIImage?.resizableImage(withCapInsets: myInsets)
        self.myCollectionView.backgroundColor = UIColor.init(patternImage:bgUIImage!)
        self.myCollectionView.reloadData()
    }
    
    
    @objc func test () {
        print("HCAIUHUODHGSUOGOUGOG")
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 300, height: 300)
        
        self.myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.dataSource = self
        myCollectionView.delegate = self
        myCollectionView.register(MDCCardCollectionCell.self, forCellWithReuseIdentifier: "MyCell")
        myCollectionView.backgroundColor = UIColor.white
        self.view.addSubview(myCollectionView)
        self.getTodaysData()
    }
    
    
    
    
    func getTodaysSteps(label: UILabel, completion: @escaping (Double) -> Void) {
        var identifier = label.text
        let healthStore = HKHealthStore()
        let allTypes = Set([HKObjectType.workoutType(),
                            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
                            HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
                            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                            HKObjectType.quantityType(forIdentifier: .heartRate)!,
                            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                            HKObjectType.quantityType(forIdentifier: .stepCount)!,
                            HKObjectType.quantityType(forIdentifier: .heartRate)!])
        let tHeartRate = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)
        healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
            if !success {
                // Handle the error here.
            }
        }
        var quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        if(label.text == "Consumed Calories") {
            quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
        } else if(label.text == "Burned Calories") {
            quantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        }
        
        if(label.text == "Sleeping Hours"){
            if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
                
                // Use a sortDescriptor to get the recent data first
                let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
                
                // we create our query with a block completion to execute
                let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 30, sortDescriptors: nil) { (query, tmpResult, error) -> Void in
                    
                    if error != nil {
                        
                        // something happened
                        return
                        
                    }
                    
                    if let result = tmpResult {
                        
                        // do something with my data
                        var hours = 0.0
                        for item in result {
                            if let sample = item as? HKCategorySample {
                                let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                                print("sleep: \(sample.startDate) \(sample.endDate) - source: \(sample.source.name) - value: \(value)")
                                let seconds = sample.endDate.timeIntervalSince(sample.startDate)
                                let minutes = seconds/60
                                let addHours = minutes/60
                                hours = hours + addHours
                                label.text = "Sleeping Hours" + ": \(hours)"
                            }
                        }
                    }
                }
                
                // finally, we execute our query
                healthStore.execute(query)
            }
            
            
        } else {
            let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: {
                (query, results, error) in
                if results == nil {
                    print("There was an error running the query: \(error)")
                }
                
                
                if(results?.count ?? 0 > 0){
                    var energy = 0.0
                    for activity in results as! [HKQuantitySample]
                    {
                        
                        
                        
                        var addEnergy = activity.quantity.doubleValue(for: HKUnit.kilocalorie())
                        if(identifier == "Burned Calories") {
                            energy = energy + addEnergy
                            label.text = "Burned Calories" + ": \(energy)"
                        } else {
                            label.text = "Eaten Calories" + ": \(energy + addEnergy)"
                        }
                        
                        
                        
                    }
                } else {
                    label.text = label.text! + ": \(0)"
                }
            })
            
            healthStore.execute(query)
            
            
        }
        
    }
    
    
    func getTodaysData() {
        for (key, value) in self.dataBody {
            
            
            let healthStore = HKHealthStore()
            let allTypes = Set([HKObjectType.workoutType(),
                                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                                HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
                                HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
                                HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                                HKObjectType.quantityType(forIdentifier: .heartRate)!,
                                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                HKObjectType.quantityType(forIdentifier: .stepCount)!,
                                HKObjectType.quantityType(forIdentifier: .heartRate)!])
            let tHeartRate = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                }
            }
            var quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
            
            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
            if(key == "Calories_Consumed") {
                quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
            } else if(key == "Exercise_Calories_Burned") {
                quantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
            }
            
            if(key == "Hours_Sleep"){
                if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
                    
                    // Use a sortDescriptor to get the recent data first
                    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
                    
                    // we create our query with a block completion to execute
                    let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 30, sortDescriptors: nil) { (query, tmpResult, error) -> Void in
                        
                        if error != nil {
                            
                            // something happened
                            return
                            
                        }
                        
                        if let result = tmpResult {
                            print(result)
                            // do something with my data
                            var hours = 0.0
                            for item in result {
                                if let sample = item as? HKCategorySample {
                                    let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                                    print("sleep: \(sample.startDate) \(sample.endDate) - source: \(sample.source.name) - value: \(value)")
                                    let seconds = sample.endDate.timeIntervalSince(sample.startDate)
                                    let minutes = seconds/60
                                    let addHours = minutes/60
                                    hours = hours + addHours
                                    self.dataBody[key] = hours
                                    self.sendHealthData(healthValue: hours, healthType: "sleep")
                                    print("hours")
                                }
                            }
                        }
                    }
                    // finally, we execute our query
                    healthStore.execute(query)
                }
            } else {
                let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: {
                    (query, results, error) in
                    if results == nil {
                        print("There was an error running the query: \(error)")
                    }
                    if(results?.count ?? 0 > 0){
                        var energy = 0.0
                        for activity in results as! [HKQuantitySample]
                        {
                            var addEnergy = activity.quantity.doubleValue(for: HKUnit.kilocalorie())
                            if(key == "Exercise_Calories_Burned") {
                                energy = energy + addEnergy
                                self.dataBody[key] = energy
                                self.sendHealthData(healthValue: energy, healthType: "burned")
                            } else {
                                self.dataBody[key] = energy + addEnergy
                                self.sendHealthData(healthValue: energy, healthType: "consumed")
                            }
                        }
                    }
                })
                healthStore.execute(query)
            }
        }
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! MDCCardCollectionCell
        // If you wanted to have the card show the selected state when tapped
        // then you need to turn isSelectable to true, otherwise the default is false.
        myCell.isSelectable = true
        myCell.isAccessibilityElement = true
        var labels = ["zzz": "Sleeping Hours", "consumedcalories": "Consumed Calories", "burnedcalories": "Burned Calories"]
        var viewRect = CGRect(x: myCell.contentView.frame.minX, y: 200, width: myCell.bounds.width, height: 100)
        var view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(rgb: 0x738BAE)
        var labelRect = CGRect(x: view.center.x, y: view.center.y, width: 100, height: 100)
        var label = UILabel(frame: labelRect)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        var value = self.userData[indexPath.row]["name"]!
        label.text = (labels[value] ?? "still retrieving")
        label.center.y = view.center.y
        label.center.x = view.center.x
        view.addSubview(label)
        myCell.addSubview(view)
        myCell.addSubview(label)
        myCell.cornerRadius = 8
        myCell.isAccessibilityElement = true
        myCell.accessibilityLabel = "test"
        myCell.setShadowElevation(ShadowElevation(rawValue: 6), for: .selected)
        myCell.setShadowColor(UIColor.black, for: .highlighted)
        myCell.setImage(UIImage(named: self.userData[indexPath.row]["name"]!), for: .normal)
        myCell.setImage(UIImage(named: self.userData[indexPath.row]["name"]!), for: .highlighted)
        myCell.setImage(UIImage(named: self.userData[indexPath.row]["name"]!), for: .selected)
        myCell.horizontalImageAlignment(for: .normal)
        myCell.verticalImageAlignment(for: .normal)
        myCell.setVerticalImageAlignment(MDCCardCellVerticalImageAlignment.center, for: .normal)
        myCell.setHorizontalImageAlignment(MDCCardCellHorizontalImageAlignment.center, for: .normal)
        myCell.image
        getTodaysSteps(label: label) { [weak self](sum) in
            print(sum)
            label.text = "\(sum)"
        }
        return myCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        print("User tapped on item \(indexPath.row)")
    }
    
    
    
    
    
    
}



extension UINavigationBar {
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 500)
    }
}


