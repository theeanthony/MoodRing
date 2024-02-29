//
//  DeviceLabelView.swift
//  Mood
//
//  Created by Anthony Contreras on 2/6/24.
//

import SwiftUI
import CoreBluetooth

struct DeviceLabelView: View {
    
    @Environment(\.colorScheme) var color
//    let name : String
 
    let bluetoothDevice : BluetoothDeviceModel
    @ObservedObject var deviceViewModel: DeviceViewModel
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

                
                ScrollView(.horizontal, showsIndicators:false){
                    HStack(spacing:10){
                        Button {
                            
               
                                colorViewModel.chosenCollection = nil
                                
                                deviceViewModel.sendArrayColorCommands([SavedColorModel(id: UUID(), color:  UIColor(red: 0, green: 0, blue: 0, alpha: 1))], rateOfChange: 60)
                                
                        } label: {
                            Image(systemName: "light.beacon.min")
                            
                        }
                        .buttonStyle(color == .light ? ConditionalButtonStyle(useDarkStyle: false) : ConditionalButtonStyle(useDarkStyle: true))
                        
                        
                        Button {
//                            self.turnOnHeart = !turnOnHeart
//                            
//                            if turnOnHeart {
                                colorViewModel.chosenCollection = nil
                                
                                deviceViewModel.sendHeartCommand()
//                            }else{
//                                
//                                deviceViewModel.sendColorCommand(red: 0, green: 0, blue: 0)
//                                
//                            }
                            
                            
                        } label: {
                            Image(systemName: turnOnHeart ? "heart.fill" : "heart")
                            
                        }
                        .buttonStyle(color == .light ? ConditionalButtonStyle(useDarkStyle: false) : ConditionalButtonStyle(useDarkStyle: true))
                        
                        
                        
                        if let deviceId = bluetoothDevice.entity?.id {
                            
                        HStack {
                            ForEach(colorViewModel.collections, id: \.self) { collection in
                                
                                Button {
                                    
                                    
                                    colorViewModel.chosenCollection = collection
                                    deviceViewModel.sendArrayColorCommands(collection.savedColorModels, rateOfChange: collection.rateOfChange)
                                    
                                } label: {
//                                                                        NavigationLink(destination: AddColorView(viewModel: colorViewModel, id: collection.id, deviceId: deviceId)) {
//                                                                        Image(systemName: "paintpalette.fill")
                                    
                                    Image(systemName: collection == colorViewModel.chosenCollection ? "paintpalette.fill" : "paintpalette")
                                        .foregroundStyle(color == .light ? .black : .white )
//                                                                        }
                                    
                                }
                                .contextMenu { // Use ContextMenu for long press options
                                    NavigationLink(destination: AddColorView(viewModel: colorViewModel, id: collection.id, deviceId: deviceId)) {
                                        
                                        Button {
                                            // Delete action
                                            
                                            
                                        } label: {
                                            Label("Edit Collection", systemImage: "pencil")
                                                .foregroundStyle(color == .light ? .black : .white )
                                        }
                                    }
                                    Button {
                                        // Delete action
                                        colorViewModel.deleteCollection(with: collection.id)
                                        print("Deeleting collection please")
                                        
                                    } label: {
                                        Label("Delete Collection", systemImage: "trash")
                                    }
                                }
                                .onLongPressGesture(minimumDuration: 0.5) { // Detect long press, adjust timing as needed
                                    self.selectedCollectionIDForDeletion = collection.id
                                    // You might want to trigger the context menu here, but SwiftUI currently does not support programmatically showing context menus.
                                }
                                
                                
                                .buttonStyle(ConditionalButtonStyle(useDarkStyle: color == .light ? false : true))
                                
                                
                                
                            }
                            
                            // Button to add a new color collection
                            Button {
                                // Navigate to AddColorView for a new collection
                            } label: {
                                                                NavigationLink(destination: AddColorView(viewModel: colorViewModel, id: UUID(), deviceId: deviceId)) {
                                
                                
                                                                    Image(systemName: "plus")
                                                                        .foregroundStyle(color == .light ? .black : .white )
                                
                                                                }
                            }
                            
                            .buttonStyle(ConditionalButtonStyle(useDarkStyle: color == .light ? false : true))
                        }
                        
                        
                    }
                        Spacer()
                        
                    }
                    .padding()
                }
                
          
                
                
                
                
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
