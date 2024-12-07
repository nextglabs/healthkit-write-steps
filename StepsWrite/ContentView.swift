//
//  ContentView.swift
//  StepsWrite
//
//  Created by Bassem (NextGLabs) on 21/03/2021.
//
import SwiftUI
import HealthKit

struct ContentView: View {
    let healthStore = HealthStore()
    
    @State private var valueToAdd: String = ""
    @State private var startDate: Date = Date()
    @State private var alertPresented = false
    @State private var distance: String = ""
    
    @State private var workoutLogMessage: String = ""
    @State private var authorizationErrorMessage: String = ""
    
    var body: some View {
        let isDisabled = valueToAdd == ""
        
        NavigationView{
            Form{
                Section{
                    TextField("Enter Steps/Distance To Add...", text: $valueToAdd)
                        .keyboardType(.decimalPad)
                    DatePicker("Start Date", selection: $startDate)
                }
                
                Section{
                    HStack{
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(isDisabled ? .gray : .blue)
                        Button("ADD STEPS", action: {
                            logSteps()
                            
                            
                        })
                        .disabled(isDisabled)
                        .alert(isPresented: $alertPresented, content: {
                            Alert(title: Text("Success"), message: Text("Successfully added \(valueToAdd) steps to Health data"), dismissButton: .default(Text("Dismiss")))
                        })
                        
                    }
                }
                
                
                
                HStack{
                    Image(systemName: "figure.outdoor.cycle.circle.fill")
                        .foregroundColor(isDisabled ? .gray : .blue)
                    Button("ADD CYCLING", action: {
                        logWorkout(type: .outdoorCycling, duration: 120.0)
                    })
                    .disabled(isDisabled)
                    .alert(isPresented: $alertPresented, content: {
                        Alert(title: Text("Success"), message: Text(workoutLogMessage), dismissButton: .default(Text("Dismiss")))
                    })
                    
                }
                
                HStack{
                    Image(systemName: "figure.run.circle.fill")
                        .foregroundColor(isDisabled ? .gray : .blue)
                    Button("ADD RUNNING", action: {
                        logWorkout(type: .outdoorRunning, duration: 90.0)
                    })
                    .disabled(isDisabled)
                    .alert(isPresented: $alertPresented, content: {
                        Alert(title: Text("Success"), message: Text(workoutLogMessage), dismissButton: .default(Text("Dismiss")))
                    })
                    
                }
                
                
                if !authorizationErrorMessage.isEmpty {
                    Section {
                        // Status Message
                        Text(workoutLogMessage)
                            .foregroundColor(workoutLogMessage.contains("Error") ? .red : .green)
                    }
                }
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        }
        .navigationBarTitle(Text("StepsWrite"))
        .onAppear {
            // Request HealthKit authorization when view appears
            requestHealthKitAuthorization()
        }
    }
    
    private func requestHealthKitAuthorization() {
        healthStore.requestAuthorization { (success, error) in
            DispatchQueue.main.async {
                if !success {
                    self.authorizationErrorMessage = "Authorization Failed: \(error?.localizedDescription ?? "Unknown error")"
                }
            }
        }
    }
    
    private func logSteps() {
        // Validate inputs
        guard let stepsValue = Double(valueToAdd) else {
            workoutLogMessage = "Error: Invalid input"
            return
        }
        
        self.alertPresented.toggle()
        
        // Log the steps
        healthStore.writeSteps(startDate: startDate, stepsToAdd: stepsValue)
        
        // Update feedback message
        workoutLogMessage = "Steps logged successfully: \(valueToAdd) steps."
        
        // Clear inputs after logging
        valueToAdd = ""
    }
    
    
    private func logWorkout(type: WorkoutType, duration: Double) {
        // Validate inputs
        guard let distanceValue = Double(valueToAdd) else {
            workoutLogMessage = "Error: Invalid input"
            return
        }
        self.alertPresented.toggle()
        
        Task {
            do {
                try await healthStore.addWorkout(type: type, date: startDate, distance: distanceValue, duration: duration)
                workoutLogMessage = "\(type) Workout logged successfully: \(distanceValue) km in \(duration) minutes."
                
            } catch {
                workoutLogMessage = error.localizedDescription
            }
        }
        
        valueToAdd = ""
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
