//
//  ContentView.swift
//  BetterRest
//
//  Created by Anthony Candelino on 2024-06-22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var optimalBedtime = ""
    @State private var showingErrorAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?").font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden().onChange(of: wakeUp) {
                        calculateBedtime()}.padding(.top)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep").font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25).onChange(of: sleepAmount) {
                        calculateBedtime()}.padding(.top)
                }
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Daily coffee intake").font(.headline)
                        Picker("", selection: $coffeeAmount) {
                            ForEach(1...8, id: \.self) { number in
                                    Text("^[\(number) cup](inflect: true)")
                            }
                        }.onChange(of: coffeeAmount) {
                            calculateBedtime()
                        }
                    }.padding([.top, .bottom], 5)
                }
                Section {
                    HStack() {
                        Text("Optimal Bedtime:").font(.system(size: 21)).bold()
                        Text(optimalBedtime).font(.system(size: 21))
                    }
                }.padding([.top, .bottom], 5)
            }
            .navigationTitle("BetterRest")
            .alert("Error finding optimal bedtime.", isPresented: $showingErrorAlert) {
                Button("Ok") { }
            } message: {
                Text("Please try again")
            }
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            optimalBedtime = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            showingErrorAlert = true
        }
    }
}

#Preview {
    ContentView()
}
