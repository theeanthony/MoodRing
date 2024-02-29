//
//  AddColorView.swift
//  Mood
//
//  Created by Anthony Contreras on 2/7/24.
//

import SwiftUI
import UIKit // Import UIKit as ChromaColorPicker is a UIKit component

struct AddColorView: View {
    @Environment (\.colorScheme) var colorScheme
    @Environment (\.dismiss) var dismiss
    @State private var selectedColor = UIColor.white // Default color
    @State private var activeHandleId : UUID?
    @ObservedObject var viewModel : ColorPickerViewModel
    let id : UUID 
    let deviceId : UUID 
    @State private var deleteHandleId : UUID = UUID()
    
    
    @State private var showRateOptions : Bool = false
    @State private var selectedOption: TimeOption = TimeOption.options[2] // Default to 1 second


    var body: some View {
        VStack {
            
            VStack{
                ChromaColorPickerWithSlider(selectedColor: $selectedColor, activeHandleId: $activeHandleId, existingPreLoadedColors: viewModel.returnExistingColors(id: id), viewModel: viewModel, deleteHandle: $deleteHandleId)
                    .frame(width: 300, height: 350) // Match the size specified in makeUIView
                    .padding()
                
                // Optionally use the selected color
                VStack{
                    
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            
                            
                            VStack{
                                Button {
                                    self.showRateOptions = true
                                    self.activeHandleId = nil 
                                } label: {
                                    Image(systemName:"clock.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                    
                                    
                                }
                                .buttonStyle(ConditionalPressedButtonStyle(useDarkStyle: colorScheme == .light ? false : true))
                                if  showRateOptions {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(colorScheme == .light ? .black : .white)

                                        .frame(width:30,height:5)
                                }else{
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(.clear)

                                        .frame(width:30,height:5)


                                }
                            }
                                
                            
                            ForEach(viewModel.preSavedColors) { color in
                                
                                VStack{
                                    Button(action: {
//                                        removePresavedColor(color.id)
                                        self.showRateOptions = false 
                                        self.activeHandleId = color.id
                                        viewModel.updateColor(UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha), forId: color.id)
                                        
                                    }) {
                                        VStack {
                                            Circle()
                                                .fill(.clear) // The main circle is transparent and serves as a placeholder
                                                .frame(width: 30, height: 30) // This is the frame for the placeholder circle
                                        }
                                    }
                                    .buttonStyle(ConditionalPressedButtonStyle(useDarkStyle: colorScheme == .light ? false : true))
                                    .overlay(
                                        Circle()
                                            .fill(Color(color.uiColor)) // This is the color fill for the overlay circle
                                        // Making the overlay circle slightly smaller than the main circle
                                            .padding(5)
                                    )
                                    if color.id == activeHandleId {
                                        RoundedRectangle(cornerRadius: 30)
                                            .fill(colorScheme == .light ? .black : .white)

                                            .frame(width:30,height:5)
                                    }else{
                                        RoundedRectangle(cornerRadius: 30)
                                            .fill(.clear)

                                            .frame(width:30,height:5)


                                    }
                                
                                }
                            

                              

                      
    
                                
                                
                                
                            }
                        }
                        .padding()
                        
                        
                    }
                    .padding()
                    
                    if showRateOptions {
                        HStack{
                            Picker("Duration", selection: $selectedOption) {
                                       ForEach(TimeOption.options) { option in
                                           Text(option.label).tag(option)
                                       }
                                   }
                                   .pickerStyle(WheelPickerStyle())
                                   .frame(height: 150)
                            
                                   .conditionalBackground(shape: RoundedRectangle(cornerRadius: 10))
                                   .onChange(of: selectedOption) { newValue in
                                       
                                       
                                       if let seconds = newValue.seconds {
                                           print("Selected duration: \(seconds) seconds")
                                       } else {
                                           print("Selected duration: Infinity")
                                       }
                                   }
                        }
                   

                    }
                    
                }
                .padding()
//                .background(LabelBackgroundView())
                Spacer()

            }

        }
        .background(BackgroundView())
        .onAppear(perform: updateCollection)

        .onDisappear(perform: {
            viewModel.removePreSavedColors()
        })

        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.saveNewPreSavedColors(deviceId: deviceId, id: id, timeOption:selectedOption)
                    dismiss()
                } label: {
                    Text("Save")
                }

            }
        }
    }
    
    func changeTimeRange(){
        
    }
    func updateCollection() {
        viewModel.loadExistingColors(id: id)
        if let index = viewModel.collections.firstIndex(where: { $0.id == id }) {
            
            let seconds = viewModel.collections[index].rateOfChange
            print("seconds in this \(seconds)")
            switch seconds {
            case 1:
                self.selectedOption = TimeOption.options[0]
            case 15:
                self.selectedOption = TimeOption.options[1]

            case 30:
                self.selectedOption = TimeOption.options[2]

            case 60:
                self.selectedOption = TimeOption.options[3]

            default:
                self.selectedOption = TimeOption.options[4]

                
            }
            
        }
        // Use viewModel to update colorCollection in CoreData
        
    }
    func removePresavedColor(_ colorId: UUID){
        self.deleteHandleId = colorId
        viewModel.removedPreSavedColor(colorId)
    }
}




struct TimeOption: Hashable, Equatable, Identifiable {
    let id = UUID()
    let label: String
    let seconds: Int? // Use nil for infinity
    
    static let options: [TimeOption] = [
        TimeOption(label: "1 second", seconds: 1),
        TimeOption(label: "15 seconds", seconds: 15),
        TimeOption(label: "30 seconds", seconds: 30),
        TimeOption(label: "60 seconds", seconds: 60),
        TimeOption(label: "∞", seconds: nil)
    ]
}
