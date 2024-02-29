//
//  HeaderViewModel.swift
//  Mood
//
//  Created by Anthony Contreras on 2/21/24.
//

import Foundation

enum HeartCondition {
    case Searching, NoPulseDetected, PulseDetected
}
class HeaderViewModel: ObservableObject {
    
    @Published var heartCondition : HeartCondition = .Searching
    @Published var heartRate : Int?
    var bluetoothManager: BluetoothManager


//
    init( bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
        setupHeartRateCallback()
//        setUpPulseDetectionCallback()

    }
    
    
    private func setupHeartRateCallback() {
        bluetoothManager.heartRate = { rate in
            DispatchQueue.main.async {
                // Update UI or process the heart rate value
//                print("Heart rate received: \(rate)")
                let components = rate.components(separatedBy: ":")
//                print(components)
                if components.count > 1 {
                    // Trim the \r\n from the heart rate string
                    let heartRateString = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    // Now convert the trimmed string to an integer
                    let heartRateValue = Int(heartRateString)
                    self.heartRate = heartRateValue
                    self.heartCondition = .PulseDetected

                }

//                         if components.count >= 1,{
//                             // Call the heartRate closure with the extracted value
//                             print("Applying heart rate \(rate)")
//                      
//
//                         }
            }
        }
    }
//    private func setUpPulseDetectionCallback() {
//        
//        bluetoothManager.determineHeartState = {  detected in
//            
//                DispatchQueue.main.async {
//                    self.heartCondition = detected
//            }
//            
//        }
//    
//    }
}
