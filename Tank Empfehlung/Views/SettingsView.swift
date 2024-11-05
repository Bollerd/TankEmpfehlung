//
//  SettingsView.swift
//  Tank Empfehlung
//
//  Created by Dirk Boller on 08.08.24.
//

import SwiftUI
import SwiftData
import MapKit

var stationAddressSelected = ""

struct SettingsView: View {
    @State private var selectedEnumCase: GasTypes = .e10
    @ObservedObject var viewModel: GasPricesViewModel
    @State private var showingMap = false
    @State var selectedStation: GasStationElement?
    @State var stationAddress: String = "Weinstraße 112a, 67147 Forst"
    
    var body: some View {
        
            VStack {
                Text("Einstellungen").font(.largeTitle)
                Toggle(isOn: $viewModel.activeSpeedAnnouncement) {
                    Text("Sprachansage:")
                }.padding(.horizontal)
                Text("Spritart:")
                Picker("Select Enum Case", selection: $viewModel.selectedFuelType) {
                    ForEach(GasTypes.allCases) { enumCase in
                        Text(enumCase.rawValue).tag(enumCase)
                    }
                }
                Text("Standort:")
                Picker("Select Enum Case", selection: $viewModel.selectedLocation) {
                    ForEach(LocationGroups.allCases) { enumCase in
                        Text(enumCase.rawValue).tag(enumCase)
                    }
                }
                List(viewModel.locationStations, id: \.id) { station in
                    VStack(alignment: .leading) {
                        HStack(alignment: .center) {
                            Text("\(station.name)")
                            Text("\(station.brand)")
                        }
                       
                        HStack(alignment: .center) {
                            Text("\(station.postcode)").font(.footnote)
                            Text("\(station.place)").font(.footnote)
                            Text("\(station.street)").font(.footnote)
                            Text("\(station.housenumber! )").font(.footnote)
                        }
                        
                    }.onTapGesture {
                    //    print(station)
                        self.selectedStation = station
                        self.stationAddress = "\(station.street) \(station.housenumber!), \(station.postcode) \(station.place)"
                        stationAddressSelected = "\(station.street) \(station.housenumber!), \(station.postcode) \(station.place)"
                        self.showingMap = true
                    }
                }
            }.sheet(isPresented: $showingMap, content: {
              //  if let station = selectedStation {
                //    MapView(station: station)
              //  } else {
                    MapView(address: stationAddressSelected).presentationDetents([.medium, .large])
             //   }
            })
       
    }
}

struct MapView: View {
  //  let station: GasStationElement
    let address: String // = "Weinstraße 112a, 67147 Forst"
    var body: some View {
        // Hier können Sie die Logik implementieren, um die Karten-App zu öffnen und die Adresse anhand von Postleitzahl und Straße zu öffnen
        // Zum Beispiel können Sie hier die MapKit-Frameworks verwenden, um die Kartenansicht zu implementieren und die Adresse zu öffnen
        // Beachten Sie, dass dies nur ein Platzhalter ist und die genaue Implementierung von Ihren Anforderungen und der Verwendung von MapKit abhängt
        VStack {
            MapViewWrapper(address: address)
                        .edgesIgnoringSafeArea(.all)
         //   Map()
   //         Text("Kartenansicht für \(station.street) \(station.postcode) öffnen")
        }
        
    }
}

struct MapViewWrapper: UIViewRepresentable {
    let address: String

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Geocodierung der Adresse, um die Koordinaten zu erhalten
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                // Adresse gefunden, Karte zentrieren und anzeigen
                let coordinate = location.coordinate
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                uiView.setRegion(region, animated: true)

                // Optional: Pin an der Adresse anzeigen
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = address
                uiView.addAnnotation(annotation)
            } else {
                // Adresse nicht gefunden, Fehlerbehandlung hier implementieren
                print("Adresse konnte nicht gefunden werden: \(error?.localizedDescription ?? "Unbekannter Fehler")")
            }
        }
    }
}

#Preview {
   SettingsView(viewModel: GasPricesViewModel())
}
