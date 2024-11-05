//
//  ContentView.swift
//  Tank Empfehlung
//
//  Created by Dirk Boller on 07.08.24.
//

import SwiftUI
import Charts
import AVFoundation

struct ContentView: View {
    @ObservedObject var viewModel: GasPricesViewModel
    @Environment(\.modelContext) var modelContext
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "€"
        formatter.maximumFractionDigits = 3
        return formatter
    }()
    @State private var showingMap = false
    @State private var showingHistory = false
    @State var stationAddress: String = "Weinstraße 112a, 67147 Forst"
    @Environment(\.scenePhase) var scenePhase
    let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack {
            VStack {
                Text("Preisempfehlung").font(.largeTitle).foregroundColor(self.viewModel.getOverallColor())
                HStack {
                    Text(numberFormatter.string(from: NSNumber(value: viewModel.minPrice)) ?? "")
                    Text(" / ")
                    Text(numberFormatter.string(from: NSNumber(value: viewModel.maxPrice)) ?? "")
                }
                Text("Stationspreise (\(viewModel.selectedFuelType))").font(.subheadline)
                List(viewModel.stationPrices, id: \.name) { currentPrice in
                    HStack {
                        Image(systemName: currentPrice.getSystemIconName(gasType: GasTypes(rawValue: self.viewModel.selectedFuelType) ?? .e5, comparePrice: viewModel.minPrice)
                              , variableValue: 1.00)
                        .symbolRenderingMode(.monochrome)
                        .foregroundColor(currentPrice.getIconColor(gasType: GasTypes(rawValue: self.viewModel.selectedFuelType) ?? .e5, comparePrice: viewModel.minPrice))
                        .font(.system(size: 16, weight: .regular))
                        VStack(alignment: .leading) {
                            Text("\(currentPrice.name)")
                            // Text("Location: \(currentPrice.stationgroup)")
                            HStack(alignment: .bottom) {
                                Text(numberFormatter.string(from: NSNumber(value: currentPrice.getSelectedFuelPrice(gasType: GasTypes(rawValue: self.viewModel.selectedFuelType) ?? .e5))) ?? "")
                                Text(currentPrice.datum.prefix(19)).font(.caption)
                            }
                            
                        }
                    }.onTapGesture {
                        print(currentPrice)
                        let station = self.viewModel.getStationFromName(name: currentPrice.name)
                        print(station)
                        self.stationAddress = "\(station.street) \(station.housenumber! ), \(station.postcode) \(station.place)"
                        stationAddressSelected = "\(station.street) \(station.housenumber! ), \(station.postcode) \(station.place)"
                        self.showingMap = true
                    }
                }.refreshable {
                    viewModel.refresh()
                }
                Text("Historie").font(.subheadline)
                List(viewModel.locationHistory, id: \.day) { historyElement in
                    HStack(alignment: .center) {
                        Text("\(historyElement.day.prefix(10))")
                        Spacer()
                        HStack(alignment: .center) {
                            Text(numberFormatter.string(from: NSNumber(value: historyElement.getSelectedFuelMaxPrice(gasType: GasTypes(rawValue: self.viewModel.selectedFuelType) ?? .e5))) ?? "")
                            Text(" / ")
                            Text(numberFormatter.string(from: NSNumber(value: historyElement.getSelectedFuelMinPrice(gasType: GasTypes(rawValue: self.viewModel.selectedFuelType) ?? .e5))) ?? "")
                        }
                    }.onTapGesture {
                        self.showingHistory = true
                    }
                }
                Text("Made with ❤️ in SwiftUI by Dirk v \(VERSION) (\(BUILD))").font(.footnote).padding(4)
            }.onAppear {
                viewModel.refresh()
            }.sheet(isPresented: $showingMap, content: {
                MapView(address: stationAddressSelected).presentationDetents([.medium, .large])
            }).sheet(isPresented: $showingHistory, content: {
                Chart {
                    ForEach(self.viewModel.historyChart) { record in
                        LineMark(
                            x: .value("Datum", String(record.day.prefix(10))),
                            y: .value("Preis", Double(record.value))
                        ).foregroundStyle(by: .value("Art", record.kind))
                    }
                }.chartForegroundStyleScale([
                    "min Diesel": .green, "max Diesel": .yellow, "min E5": .pink, "max E5": .purple, "min E10": .black, "max E10": .brown
                ]).chartYScale(domain: [self.viewModel.overallMinPrice,self.viewModel.overallMaxPrice])
                    .padding()
                    .presentationDetents([.medium, .large])
            })
        }.onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.refresh()
                speakText()
            }
        }
    }
    
    func speakText() {
        if viewModel.stationPrices.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.speakText()
            }
            return
        }
       
        let overAllColor = viewModel.getOverallColor()
        var textToSpeak = "Kein eindeutiger Vorschlag."
       
        if overAllColor == .red {
            textToSpeak = "Tanken lohnt nicht."
        }
        
        if overAllColor == .green {
            textToSpeak = "Tanken lohnt."
        }
        
        if overAllColor == .red || overAllColor == .orange {
            var last4DaysMin = 9.9
            var last4DaysMax = 0.0
            var days = 0
            for historyElement in viewModel.locationHistory {
                if days == 4 {
                    break
                }
                let price = historyElement.getSelectedFuelMinPrice(gasType: GasTypes(rawValue: self.viewModel.selectedFuelType) ?? .e5)
                if price > last4DaysMax {
                    last4DaysMax = price
                }
                
                if price < last4DaysMin {
                    last4DaysMin = price
                    
                }
                
                days += 1
            }
           
            var stationName: [String] = []
            var stationPrices: [Double] = []
            for currentPrice in viewModel.stationPrices {
                if currentPrice.getSelectedFuelPrice(gasType: GasTypes(rawValue: self.viewModel.selectedFuelType) ?? .e5) <= last4DaysMin + 0.03 {
                    stationName.append(currentPrice.name)
                    stationPrices.append(currentPrice.getSelectedFuelPrice(gasType: GasTypes(rawValue: self.viewModel.selectedFuelType) ?? .e5))
                }
            }
            
            if !stationName.isEmpty {
                for (index, station) in stationName.enumerated() {
                    let formattedPrice = String(format: "%.3f", stationPrices[index])
                    if index == stationName.count - 1 {
                        textToSpeak += " oder \(station) für \(formattedPrice.replacingOccurrences(of: ".", with: ","))€"
                    } else {
                        textToSpeak = "Tanken in \(station) für \(formattedPrice.replacingOccurrences(of: ".", with: ","))€, "
                    }
                }
                let formattedPrice = String(format: "%.3f", last4DaysMin)
                textToSpeak += " lohnt sich eventuell da der Minimalpreis der letzten 4 Tage \(formattedPrice.replacingOccurrences(of: ".", with: ",")) war."
            }
        }
        
        let utterance = AVSpeechUtterance(string: textToSpeak)
        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
        synthesizer.speak(utterance)
    }
   
}


