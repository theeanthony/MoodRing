//
//  MoodApp.swift
//  Mood
//
//  Created by Anthony Contreras on 2/3/24.
//

import SwiftUI

@main
struct MoodApp: App {
    let persistenceController = PersistenceController.shared

    @StateObject private var bluetoothConnectionViewModel : BluetoothConnectionViewModel = BluetoothConnectionViewModel()
    var body: some Scene {
        WindowGroup {
            ZStack{
                BackgroundView()
                    
                ConnectDeviceView()
                    .environmentObject(bluetoothConnectionViewModel)
            }

        }
    }
}
