//
//  DataDefinitions.swift
//  Tank Empfehlung
//
//  Created by Dirk Boller on 08.08.24.
//

import Foundation
import SwiftUI

enum GasTypes: String , CaseIterable, Identifiable {
    case e5 = "E5"
    case e10 = "E10"
    case diesel = "Diesel"
    
    var id: String { self.rawValue }
}

enum LocationGroups: String , CaseIterable, Identifiable {
    case Forst = "Forst"
    case Maxdorf = "Maxdorf"
    case Heidelberg = "Heidelberg"
    case Woerth = "Woerth"
    
    var id: String { self.rawValue }
}

import Foundation

// MARK: - GasStationElement
class GasStationElement: Codable, Sendable {
    let id, name, group, street: String
    let housenumber: String?
    let postcode, place, brand: String

    init(id: String = "\(UUID())", name: String = "Station", group: String = "Forst", street: String = "Street", housenumber: String? = "1", postcode: String = "4711", place: String = "City", brand: String = "Brand") {
        self.id = id
        self.name = name
        self.group = group
        self.street = street
        self.housenumber = housenumber
        self.postcode = postcode
        self.place = place
        self.brand = brand
    }
}

typealias GasStation = [GasStationElement]

// MARK: - CurrentGasPriceElement
class CurrentGasPriceElement: Codable, Sendable {
    let name, stationgroup, datum: String
    let diesel, e5, e10: String?
    
    init(name: String = "Name", stationgroup: String = "Forst", datum: String = "2024-08-11", e5: String = "9.999", e10: String = "9.999", diesel: String = "9.999") {
        self.name = name
        self.stationgroup = stationgroup
        self.datum = datum
        self.e5 = e5
        self.e10 = e10
        self.diesel = diesel
    }
    
    func getSelectedFuelPrice(gasType: GasTypes) -> Double {
        switch gasType {
        case .e5:
            return Double(self.e5 ?? "9.999") ?? 9.999
        case .e10:
            return Double(self.e10 ?? "9.999") ?? 9.999
        case .diesel:
            return Double(self.diesel ?? "9.999") ?? 9.999
        }
    }
    
    func getSystemIconName(gasType: GasTypes, comparePrice: Double) -> String {
        var iconName =  "checkmark.circle.fill"
        
        let currentPrice = self.getSelectedFuelPrice(gasType: gasType)
        
        let upperPrice = comparePrice + 0.05
        let lowerPrice = comparePrice + 0.02
        if  currentPrice > lowerPrice && currentPrice <= upperPrice  {
            iconName = "questionmark.circle.fill"
        }
        
        if currentPrice > upperPrice {
            iconName = "x.circle.fill"
        }
        return iconName
    }
    
    func getIconColor(gasType: GasTypes, comparePrice: Double) -> Color {
        var color =  Color.green
        
        let currentPrice = self.getSelectedFuelPrice(gasType: gasType)
        
        let upperPrice = comparePrice + 0.05
        let lowerPrice = comparePrice + 0.02
        if  currentPrice > lowerPrice && currentPrice <= upperPrice  {
            color = Color.orange
        }
        
        if currentPrice > upperPrice {
            color = Color.red
        }
        return color
    }
}

typealias CurrentGasPrice = [CurrentGasPriceElement]

// MARK: - GasPriceHistoryElement
struct GasPriceHistoryElement: Codable {
 //   let id: UUID = UUID()
    let day, locationgroup, maxE10, minE10, maxE5: String
    let minE5, maxDiesel, minDiesel: String

    enum CodingKeys: String, CodingKey {
        case day
        case locationgroup
        case maxE10 = "max_e10"
        case minE10 = "min_e10"
        case maxE5 = "max_e5"
        case minE5 = "min_e5"
        case maxDiesel = "max_diesel"
        case minDiesel = "min_diesel"
    }

    init(day: String, locationgroup: String, maxE10: String, minE10: String, maxE5: String, minE5: String, maxDiesel: String, minDiesel: String) {
        self.day = day
        self.locationgroup = locationgroup
        self.maxE10 = maxE10
        self.minE10 = minE10
        self.maxE5 = maxE5
        self.minE5 = minE5
        self.maxDiesel = maxDiesel
        self.minDiesel = minDiesel
    }
    
    func getSelectedFuelMaxPrice(gasType: GasTypes) -> Double {
        switch gasType {
        case .e5:
            return Double(self.maxE5) ?? 0.009
        case .e10:
            return Double(self.maxE10) ?? 0.009
        case .diesel:
            return Double(self.maxDiesel) ?? 0.009
        }
    }
    
    func getSelectedFuelMinPrice(gasType: GasTypes) -> Double {
        switch gasType {
        case .e5:
            return Double(self.minE5) ?? 0.009
        case .e10:
            return Double(self.minE10) ?? 0.009
        case .diesel:
            return Double(self.minDiesel) ?? 0.009
        }
    }
}

typealias GasPriceHistory = [GasPriceHistoryElement]

struct GasHistoryChartElement: Identifiable {
    let id: UUID = UUID()
    let value: Double
    let day: String
    let type: String
    let kind: String
    let color: Color

    init(value: String = "0.0", type: String = "E5", kind: String = "min E5", color: Color = .blue, day: String ) {
        self.color = color
        self.value = Double(value) ?? 0.0
        self.type = type
        self.kind = kind
        self.day = String(String(day.prefix(10)).suffix(2   ) )
    }
}

typealias GasHistoryChart = [GasHistoryChartElement]
