//
//  ContentView.swift
//  StepsWrite
//
//  Created by Bassem (NextGLabs) on 21/03/2021.
//
import SwiftUI
import HealthKit

struct ContentView: View {
    
    private var healthStore: HealthStore?
    @State private var stepsToAdd: String = ""
    @State private var startDate: Date = Date()
    @State private var alertPresented = false
    
    init() {
        healthStore = HealthStore()
    }
    
    var body: some View {
        let convertedSteps = Double(stepsToAdd) ?? 0.0
        let isDisabled = stepsToAdd == "" || convertedSteps == 0.0
        
        NavigationView{
            Form{
                Section{
                    TextField("Enter Steps To Add...", text: $stepsToAdd)
                        .keyboardType(.decimalPad)
                    DatePicker("Start Date", selection: $startDate)
                }
                HStack{
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(isDisabled ? .gray : .blue)
                    Button("ADD STEPS", action: {
                        if let healthStore = healthStore {
                            healthStore.requestAuthorization { success in
                                if success {
                                    healthStore.writeSteps(startDate: startDate, stepsToAdd: convertedSteps)
                                    self.alertPresented.toggle()
                                    self.stepsToAdd = ""
                                }
                            }
                            
                        }
                    })
                    .disabled(isDisabled)
                    .alert(isPresented: $alertPresented, content: {
                        Alert(title: Text("Success"), message: Text("Successfully added \(stepsToAdd) steps to Health data"), dismissButton: .default(Text("Dismiss")))
                    })
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            }
            .navigationBarTitle(Text("StepsWrite"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
