//
//  DeviceDisconnectedLabelView.swift
//  Mood
//
//  Created by Anthony Contreras on 2/20/24.
//

import Foundation
import SwiftUI
import CoreBluetooth

struct DeviceDisconnectedLabelView: View {
    
    @Environment(\.colorScheme) var color
//    let name : String
 
    let bluetoothDevice : BluetoothDeviceModel
    @StateObject var colorViewModel = ColorPickerViewModel() // Initialize with CoreData context

    @State private var turnOnLights : Bool = false
    @State private var turnOnSun : Bool = false
    @State private var turnOnHeart : Bool = false
    
    @State private var showSearchDeviceView = false
    @State private var showDeletionActionSheet = false
    @State private var selectedCollectionIDForDeletion: UUID?


    var body: some View {
        

            VStack{
                VStack{
                    HStack{
                        Text(bluetoothDevice.entity?.name ?? "Unknown Device")
                        Spacer()
                    }
                    HStack{
                        Text(bluetoothDevice.isConnected ? "Connected" : "Disconnected").font(.caption)
                        Spacer()
                    }
                }
                .padding()

                

                
                
                
                
            }
            .padding(10)
            .onAppear(perform: {
//                colorViewModel.fetchColorCollections()
                
                if let bluetoothDeviceEntity = bluetoothDevice.entity {
                    if let bluetoothId = bluetoothDeviceEntity.id {
                        colorViewModel.fetchColorCollections(bluetoothId)

                    }
                }
           
            })
            
            
        .background(LabelBackgroundView())
        .padding(10)
        
    }
    
}

//#Preview {
//    DeviceLabelView(name:"Ring")
//}
