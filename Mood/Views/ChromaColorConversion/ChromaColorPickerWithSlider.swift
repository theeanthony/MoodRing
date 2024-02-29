//
//  ChromaColorPickerWithSlider.swift
//  Mood
//
//  Created by Anthony Contreras on 2/7/24.
//

import Foundation
import UIKit
import SwiftUI

struct ChromaColorPickerWithSlider: UIViewRepresentable {
    @Binding var selectedColor: UIColor
    @Binding var activeHandleId: UUID?

    var existingPreLoadedColors : [SavedColorModel]
    @ObservedObject var viewModel: ColorPickerViewModel
    @Binding var deleteHandle: UUID

    func makeUIView(context: Context) -> UIView {
        // Container view for color picker and brightness slider
        let hostingView = UIView()
        
        // Create the color picker
//        let colorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        let colorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300))

        colorPicker.delegate = context.coordinator
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        
        hostingView.addSubview(colorPicker)

        // Constraints for colorPicker
        NSLayoutConstraint.activate([
            colorPicker.topAnchor.constraint(equalTo: hostingView.topAnchor),
            colorPicker.leadingAnchor.constraint(equalTo: hostingView.leadingAnchor),
            colorPicker.trailingAnchor.constraint(equalTo: hostingView.trailingAnchor),
            colorPicker.heightAnchor.constraint(equalToConstant: 300)
        ])
        

        let brightnessSlider = ChromaBrightnessSlider()
        brightnessSlider.translatesAutoresizingMaskIntoConstraints = false
        hostingView.addSubview(brightnessSlider)
        
        // Constraints for brightnessSlider
        NSLayoutConstraint.activate([
            brightnessSlider.topAnchor.constraint(equalTo: colorPicker.bottomAnchor, constant: 10),
            brightnessSlider.leadingAnchor.constraint(equalTo: hostingView.leadingAnchor, constant: 10),
            brightnessSlider.trailingAnchor.constraint(equalTo: hostingView.trailingAnchor, constant: -10),
            brightnessSlider.heightAnchor.constraint(equalToConstant: 32)
        ])
//        for savedColorModel in existingPreLoadedColors {
//            let handle = ChromaColorHandle()
//            handle.handleId = savedColorModel.id
//            handle.color = savedColorModel.uiColor // Assuming SavedColorModel has a uiColor property
//            colorPicker.addHandle(handle)
//            
//        }
        
        // Connect the color picker and brightness slider
        colorPicker.connect(brightnessSlider)
        colorPicker.layoutIfNeeded()
        colorPicker.setNeedsLayout()

        
        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
            colorPicker.addGestureRecognizer(tapRecognizer)

        return hostingView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let colorPicker = uiView.subviews.compactMap({ $0 as? ChromaColorPicker }).first else { return }
        colorPicker.layoutIfNeeded()
         colorPicker.setNeedsLayout()
        // Ensure existing handles are updated or removed accordingly
        let existingHandles = colorPicker.handles
        existingHandles.forEach { handle in
            if handle.handleId == activeHandleId {
                // Update the color of the active handle if it has changed
                if let index = viewModel.preSavedColors.firstIndex(where: { $0.id == activeHandleId }) {
                    let colorModel = viewModel.preSavedColors[index]
                    handle.color = colorModel.uiColor
                }
            } else {
                // This ensures only the active handle is visible and interactive
                colorPicker.deleteHandle(handle)
            }
        }
        
        // If there's no handle corresponding to activeHandleId, create it
        if !existingHandles.contains(where: { $0.handleId == activeHandleId }) {
            if let activeColorModel = viewModel.preSavedColors.first(where: { $0.id == activeHandleId }) {
                let newHandle = ChromaColorHandle()
                newHandle.handleId = activeHandleId!
                newHandle.color = activeColorModel.uiColor
                colorPicker.addHandle(newHandle)
            }
        }
    }

    

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }

    class Coordinator: NSObject, ChromaColorPickerDelegate {
        var parent: ChromaColorPickerWithSlider
        var viewModel : ColorPickerViewModel
//        @Published var activeHandleId : UUID?

        init(_ parent: ChromaColorPickerWithSlider, viewModel: ColorPickerViewModel) {
            self.parent = parent
            self.viewModel = viewModel
        }

        func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, handle:ChromaColorHandle, color: UIColor) {
            let activeHandleId = handle.handleId// Determine the active handle's ID
            DispatchQueue.main.async {
                self.parent.activeHandleId = activeHandleId
            }
            self.parent.viewModel.updateColor(color, forId: handle.handleId)
        }

        // Implement the delegate method for handle changes
        func colorPickerHandleDidChange(_ colorPicker: ChromaColorPicker, handle: ChromaColorHandle, to color: UIColor) {
            let activeHandleId = handle.handleId // Determine the active handle's ID
            DispatchQueue.main.async {
                self.parent.activeHandleId = activeHandleId
            }
            self.parent.viewModel.updateColor(color, forId: handle.handleId)
            
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let colorPicker = gesture.view as? ChromaColorPicker else { return }
            let location = gesture.location(in: colorPicker)

            // Assuming colorPicker contains an instance of ColorWheelView
            if let colorWheelView = colorPicker.subviews.compactMap({ $0 as? ColorWheelView }).first {
                if let colorAtLocation = colorWheelView.pixelColor(at: location) {
                   
                    
                    let customHandle = ChromaColorHandle()
                    customHandle.color = colorAtLocation
                    colorPicker.addHandle(customHandle)
                    self.parent.activeHandleId = customHandle.handleId
                    // Optionally, if you have a binding to the selected color in SwiftUI, update it
                    parent.selectedColor = colorAtLocation
                    viewModel.addPreSavedColor(customHandle.handleId, colorAtLocation)

                    colorPicker.setNeedsLayout()
                    colorPicker.layoutIfNeeded()
                }
            }
        }


    }
}
