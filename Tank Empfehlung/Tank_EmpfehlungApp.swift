//
//  Tank_EmpfehlungApp.swift
//  Tank Empfehlung
//
//  Created by Dirk Boller on 07.08.24.
//

import SwiftUI



@main
struct TankEmpfehlungApp: App {
    let viewModel = GasPricesViewModel()
  
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView(viewModel: viewModel)
                    .tabItem {
                        Label("Preise", systemImage: "flame")
                    }
                SettingsView(viewModel: viewModel)
                    .tabItem {
                        Label("Einstellungen", systemImage: "gearshape")
                    }
            }
          //  Text("Made with ❤️ in SwiftUI by Dirk v \(VERSION) (\(BUILD))").font(.footnote).padding(4)
        }
    }
}

