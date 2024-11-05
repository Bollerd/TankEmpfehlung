//
//  Model.swift
//  Tank Empfehlung
//
//  Created by Dirk Boller on 08.08.24.
//

import SwiftUI
import Combine

class GasPricesViewModel: ObservableObject {
    @Published var gasStations: GasStation = []
    @AppStorage("selectedGasStation") var selectedGasStation: String = "JET BAD DÜRKHEIM GUTLEUTSTR. 10"
    @AppStorage("selectedFuelType") var selectedFuelType: String = "e10"
    @AppStorage("selectedLocation") var selectedLocation: String = "Forst"
    @AppStorage("activeSpeechAnnouncement") var activeSpeedAnnouncement: Bool = true
    @Published var currentGasPrice: CurrentGasPrice = []
    @Published var gasPriceHistory: GasPriceHistory = []
    @Published var historyChart: GasHistoryChart = []
    
    var stationPrices: [CurrentGasPriceElement] {
        get {
            let filteredGasPrices = self.currentGasPrice.filter { $0.stationgroup == self.selectedLocation }
            return filteredGasPrices
        }
    }
    var locationHistory: GasPriceHistory {
        get {
            let filteredHistory = self.gasPriceHistory.filter { $0.locationgroup == self.selectedLocation }
            return filteredHistory
        }
    }
    var locationStations: GasStation {
        get {
            let filteredStations = self.gasStations.filter { $0.group == self.selectedLocation }
            return filteredStations
        }
    }
    var minPrice: Double {
        var minPrice = 9.999
        var currentPrice = 9.999
        locationHistory.forEach { GasPriceHistoryElement in
            currentPrice = Double(GasPriceHistoryElement.getSelectedFuelMinPrice(gasType: GasTypes(rawValue: self.selectedFuelType) ?? .e5))
            if currentPrice < minPrice {
                minPrice = currentPrice
            }
        }
        return minPrice
    }
    var overallMinPrice: Double {
        var minPrice = 9.999
        var currentPrice = 9.999
        locationHistory.forEach { GasPriceHistoryElement in
            currentPrice = Double(GasPriceHistoryElement.getSelectedFuelMinPrice(gasType: .e5))
            if currentPrice < minPrice {
                minPrice = currentPrice
            }
            currentPrice = Double(GasPriceHistoryElement.getSelectedFuelMinPrice(gasType: .e10))
            if currentPrice < minPrice {
                minPrice = currentPrice
            }
            currentPrice = Double(GasPriceHistoryElement.getSelectedFuelMinPrice(gasType: .diesel))
            if currentPrice < minPrice {
                minPrice = currentPrice
            }
        }
        return minPrice - 0.1
    }
    var maxPrice: Double {
        var maxPrice = 0.009
        var currentPrice = 9.999
        locationHistory.forEach { GasPriceHistoryElement in
            currentPrice = Double(GasPriceHistoryElement.getSelectedFuelMaxPrice(gasType: GasTypes(rawValue: self.selectedFuelType) ?? .e5))
            if currentPrice > maxPrice {
                maxPrice = currentPrice
            }
        }
        return maxPrice
    }
    var overallMaxPrice: Double {
        var maxPrice = 0.009
        var currentPrice = 9.999
        locationHistory.forEach { GasPriceHistoryElement in
            currentPrice = Double(GasPriceHistoryElement.getSelectedFuelMaxPrice(gasType: .e5))
            if currentPrice > maxPrice {
                maxPrice = currentPrice
            }
            currentPrice = Double(GasPriceHistoryElement.getSelectedFuelMaxPrice(gasType: .e10))
            if currentPrice > maxPrice {
                maxPrice = currentPrice
            }
            currentPrice = Double(GasPriceHistoryElement.getSelectedFuelMaxPrice(gasType: .diesel))
            if currentPrice > maxPrice {
                maxPrice = currentPrice
            }
        }
        
        return maxPrice + 0.1
    }
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        Task {
            await fetchGasPriceHistory()
            await fetchCurrentGasPrice()
            await fetchGasStations()
        }
    }
    
    func refresh() {
        Task {
            await fetchGasPriceHistory()
            await fetchCurrentGasPrice()
            await fetchGasStations()
        }
    }
    
    func fetchGasStations() async {
        /*
         guard let url = URL(string: "\(REMOTE_HOST)getGasStations") else { return }
         
         URLSession.shared.dataTaskPublisher(for: url)
         .map { $0.data }
         .decode(type: [GasStation].self, decoder: JSONDecoder())
         .replaceError(with: [])
         .receive(on: DispatchQueue.main)
         .assign(to: \.gasStations, on: self)
         .store(in: &cancellables)
         */
        let url = URL(string: "\(REMOTE_HOST)getGasStations.json")!
        let urlSession = URLSession.shared
        URLCache.shared.removeAllCachedResponses()
        do {
            let (data, _) = try await urlSession.data(from: url)
            if let string = String(data: data, encoding: .utf8) {
                //     print(string) // Output: Hello, World!
            } else {
                print("Unable to convert data to string.")
            }
            let stations = try JSONDecoder().decode(GasStation.self, from: data)
            
            DispatchQueue.main.async {
                self.gasStations = stations
            }
        }
        catch {
            print("run into error")
            print(error)
        }
    }
    
    func fetchCurrentGasPrice() async {
        let url = URL(string: "\(REMOTE_HOST)getCurrentGasPrices.json")!
        let urlSession = URLSession.shared
        URLCache.shared.removeAllCachedResponses()
        do {
            let (data, _) = try await urlSession.data(from: url)
            let current = try JSONDecoder().decode(CurrentGasPrice.self, from: data)
            
            DispatchQueue.main.async {
                self.currentGasPrice = current
            }
        }
        catch {
            print("run into error")
            print(error)
        }
    }
    
    func fetchGasPriceHistory() async {
        let url = URL(string: "\(REMOTE_HOST)getGasPricesHistory.json")!
        let urlSession = URLSession.shared
        URLCache.shared.removeAllCachedResponses()
        do {
            let (data, _) = try await urlSession.data(from: url)
            if let string = String(data: data, encoding: .utf8) {
                //    print(string) // Output: Hello, World!
            } else {
                print("Unable to convert data to string.")
            }
            let history = try JSONDecoder().decode(GasPriceHistory.self, from: data)
            
            DispatchQueue.main.async {
                self.gasPriceHistory = history
                self.historyChart.removeAll()
                self.locationHistory.forEach { GasHistoryElement
                    in
                    var appendItem = GasHistoryChartElement(value: GasHistoryElement.minE5, type: "E5", kind: "min E5", color: .blue, day: GasHistoryElement.day)
                    self.historyChart.insert(appendItem, at: 0)
                    appendItem = GasHistoryChartElement(value: GasHistoryElement.maxE5, type: "E5", kind: "max E5", color: .green, day: GasHistoryElement.day)
                    self.historyChart.insert(appendItem, at: 0)
                    appendItem = GasHistoryChartElement(value: GasHistoryElement.minE10, type: "E10", kind: "min E10", color: .red, day: GasHistoryElement.day)
                    self.historyChart.insert(appendItem, at:0)
                    appendItem = GasHistoryChartElement(value: GasHistoryElement.maxE10, type: "E10", kind: "max E10", color: .green, day: GasHistoryElement.day)
                    self.historyChart.insert(appendItem, at:0)
                    appendItem = GasHistoryChartElement(value: GasHistoryElement.maxDiesel, type: "Diesel", kind: "max Diesel", color: .red, day: GasHistoryElement.day)
                    self.historyChart.insert(appendItem,at:0)
                    appendItem = GasHistoryChartElement(value: GasHistoryElement.minDiesel, type: "Diesel", kind: "min Diesel", color: .red, day: GasHistoryElement.day)
                    self.historyChart.insert(appendItem,at:0)
                    
                }
            }
        }
        
        catch {
            print("run into error")
            print(error)
        }
    }
    
    func getStationFromName(name: String) -> GasStationElement {
        let nameStation = self.locationStations.filter { $0.name == name }
        
        if nameStation.count > 0 {
            return nameStation[0]
        } else {
            return GasStationElement()
        }
    }
    
    func getOverallColor() -> Color {
        let total = self.stationPrices.count
        var green = 0
        var orange = 0
        var red = 0
        var returnColor = Color.orange
        
        self.stationPrices.forEach { currentPrice in
            let currentColor = currentPrice.getIconColor(gasType: GasTypes(rawValue: self.selectedFuelType) ?? .e5, comparePrice: self.minPrice)
                
            switch currentColor {
            case .green:
                green += 1
            case .red:
                red += 1
            default:
                orange += 1
            }
        }
        
        if green == 0 {
            returnColor = .red
        }
        
        if green == total {
            returnColor = .green
        }
        
        if orange == total {
            returnColor = .orange
        }
        
        if Double(green) > Double(total) * 0.6 {
            returnColor = .green
        }
        
        return returnColor
    }
}
