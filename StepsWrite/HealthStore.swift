//
//  HealthStore.swift
//  StepsWrite
//
//  Created by Bassem (NextGLabs) on 21/03/2021.
//

import Foundation
import HealthKit

class HealthStore {
    
    var healthStore: HKHealthStore?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    func writeSteps(startDate: Date, stepsToAdd: Double) {
        let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        
        let endDate = startDate + 60 * 60 // add 1h to startDate
        let stepsSample = HKQuantitySample(type: stepType, quantity: HKQuantity.init(unit: HKUnit.count(), doubleValue: stepsToAdd), start: startDate, end: endDate)
        
        // After creating the sample, we call healthStore.save()
        
        if let healthStore = healthStore {
            healthStore.save(stepsSample, withCompletion: { (success, error) -> Void in
                
                if error != nil {
                    // something happened
                    print("error = \(String(describing: error))")
                    return
                }
                
                if success {
                    print("Steps successfully saved in HealthKit")
                    return
                } else {
                    // something happened again
                    print("Unhandled case!")
                }
                
            })
        }
        
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        
        let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        
        guard let healthStore = self.healthStore else { return completion(false) }
        
        healthStore.requestAuthorization(toShare: [stepType], read: [stepType]) { (success, error) in
            completion(success)
        }
        
    }
    
}
