//
//  HealthStore.swift
//  StepsWrite
//
//  Created by Bassem (NextGLabs) on 21/03/2021.
//

import Foundation
import HealthKit

enum WorkoutType {
    case outdoorCycling
    case outdoorRunning
}

enum WorkoutError: Error {
    case invalidDistance
    case workoutLogFailure
}

class HealthStore {
    
    private let healthStore: HKHealthStore
    
    init() {
        guard HKHealthStore.isHealthDataAvailable() else {  fatalError("HealthKit only available in iOS, iPadOS, and watchOS") }
        healthStore = HKHealthStore()
    }
    
    func writeSteps(startDate: Date, stepsToAdd: Double) {
        let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        
        let endDate = startDate + 60 * 60 // add 1h to startDate
        let stepsSample = HKQuantitySample(type: stepType, quantity: HKQuantity.init(unit: HKUnit.count(), doubleValue: stepsToAdd), start: startDate, end: endDate)
        
        // After creating the sample, we call healthStore.save()
        
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
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        
        let healthTypes = Set([
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ])
        
        healthStore.requestAuthorization(toShare: healthTypes, read: healthTypes) { (success, error) in
            
            if !success {
                print(" Error: ", error?.localizedDescription ?? "nil")
            }
        }
        
    }
    
    
    
    /// Adds a  workout to Apple Health
    /// - Parameters:
    ///   - type: The workout type
    ///   - date: The start date of the workout
    ///   - distance: Distance of the cycling workout in kilometers
    ///   - duration: Duration in minutes
    func addWorkout(type: WorkoutType, date: Date, distance: Double, duration: Double) async throws {
        guard let distanceType = HKObjectType.quantityType(forIdentifier: type == WorkoutType.outdoorCycling ? .distanceCycling : .distanceWalkingRunning) else {
            print("Error: Unable to create \(type) workout")
            throw WorkoutError.invalidDistance
        }
        
        
        // Create a workout configuration
        let configuration = HKWorkoutConfiguration()
        
        configuration.activityType = type == WorkoutType.outdoorCycling ? .cycling : .running
        configuration.locationType = .outdoor
        
        // Create a workout builder
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: .local())
        
        // Start the workout builder
        do {
            try await builder.beginCollection(at: date)

            // Create distance quantity
            let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(with: .kilo), doubleValue: distance)
            
            let end = date.addingTimeInterval(duration * 60);
            
            // Create samples
            let samples: [HKSample] = [
                HKQuantitySample(
                    type: distanceType,
                    quantity: distanceQuantity,
                    start: date,
                    end: end
                )
            ]
            
            
            try await builder.addSamples(samples)
            try await builder.endCollection(at: end)
            try await builder.finishWorkout()
            print("\(type) workout successfully saved!")
            
        } catch {
            print("Unable to add \(type) workout: \(error)")
            throw WorkoutError.workoutLogFailure
        }
    }
}
