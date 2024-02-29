//
//  HeaderView.swift
//  Mood
//
//  Created by Anthony Contreras on 2/21/24.
//

import Foundation
import SwiftUI

struct HeaderView : View{
    
    @ObservedObject var headerViewModel : HeaderViewModel
    @Environment (\.colorScheme) var color
    var body: some View {
        
        VStack{
            switch (headerViewModel.heartCondition) {
            case .NoPulseDetected:
                HStack{
                    Spacer()
                    Image(systemName:"heart.slash")
                    Spacer()
                }
                
            case .PulseDetected:
                if let heartRate = headerViewModel.heartRate {
                    HStack{
                        Spacer()
                        Image(systemName:"heart.fill")
                        Text("\(heartRate)")
                        Spacer()
                    }


                }
                else{
                    HStack{
                        Spacer()
                        Image(systemName:"heart.slash")
                        Spacer()
                    }
                }
            case .Searching:
                HeartBeatView()
                     .frame(width:100,height: 100)
                     .padding()

                     .conditionalBackground(shape: Circle())
            }
        }
        .frame(width:100,height: 100)
        .padding()

        .conditionalBackground(shape: Circle())
  
            

            
     
        
    }
    
    
    
}
