//
//  ColorPickerViewModel.swift
//  Mood
//
//  Created by Anthony Contreras on 2/7/24.
//
 
import Foundation
import SwiftUI
import CoreData

class ColorPickerViewModel: ObservableObject {

    @Published var collections: [SavedColorModels] = []
    @Published var preSavedColors: [SavedColorModel] = [] // For displaying colors before saving
    
    @Published var chosenCollection : SavedColorModels?
    
    private let persistenceController = PersistenceController.shared


    func updateColor(_ color: UIColor, forId id: UUID) {
        if let index = preSavedColors.firstIndex(where: { $0.id == id }) {
            DispatchQueue.main.async {
                self.preSavedColors[index] = SavedColorModel(id: id, color: color) // Replace with the new color

            }
        }
    }
    
    func removePreSavedColors(){
        DispatchQueue.main.async {
            self.preSavedColors.removeAll()
        }
    }
    func removedPreSavedColor(_ id: UUID){
        DispatchQueue.main.async {
            self.preSavedColors.removeAll { $0.id == id }
        }
    }

    func addPreSavedColor(_ id:UUID,_ color: UIColor) {
        
        
        let savedColor = SavedColorModel(id: id, color: color)
        DispatchQueue.main.async {
            self.preSavedColors.append(savedColor)

        }
        print("Adding presave")
    }
    
    func doesColorCollectionExist(id: UUID) -> Bool {
        return collections.contains(where: { $0.id == id })
    }

    
    func saveNewPreSavedColors(deviceId : UUID, id : UUID, timeOption : TimeOption) {
          guard !preSavedColors.isEmpty else { return }
        
        if doesColorCollectionExist(id: id) {
            
            persistenceController.updateColorCollection(collectionID: id, with: preSavedColors, rateOfChange: timeOption.seconds ?? 100)

                // Update the corresponding collection in @Published collections
                if let index = collections.firstIndex(where: { $0.id == id }) {
                    var updatedCollection = collections[index]
                    updatedCollection.savedColorModels = preSavedColors
                    updatedCollection.rateOfChange = timeOption.seconds ?? 100
                    collections[index] = updatedCollection
                }
        }else{
//            if let seconds = timeOption.seconds {
            persistenceController.createAndSaveNewColorCollection(forDeviceId: deviceId, collectionID: id, with: preSavedColors, timeOption: timeOption.seconds ?? 100)

            collections.append(SavedColorModels(id: id, savedColorModels: preSavedColors, rateOfChange: timeOption.seconds ?? 100))
//
//            }


        }
        preSavedColors.removeAll()
      }
    
    func loadExistingColors(id : UUID){
        if doesColorCollectionExist(id: id) {
            
            if let index = collections.firstIndex(where: { $0.id == id }) {
                let existingPreSavedColors = collections[index]
                
                self.preSavedColors = existingPreSavedColors.savedColorModels
                
            }
        }
    }
    func returnExistingColors(id : UUID) -> [SavedColorModel]{
        if doesColorCollectionExist(id: id) {
            
            if let index = collections.firstIndex(where: { $0.id == id }) {
                let existingPreSavedColors = collections[index]
                
                 return existingPreSavedColors.savedColorModels
            }
        }
        return []
    }
    

    
    func deleteCollection(with id: UUID) {
        // Call PersistenceController to delete the collection
        PersistenceController.shared.deleteCollection(collectionID: id) { success in
            if success {
                // Remove the collection from the collections array
                DispatchQueue.main.async {
                    self.collections.removeAll { $0.id == id }
                }
            }
        }
    }

    
    
    func fetchColorCollections(_ bluetoothId : UUID) {
        let collections = persistenceController.fetchColorCollections(forDeviceId: bluetoothId)

        var fetchedCollection: [SavedColorModels] = []
        for collection in collections {
            guard let collectionId = collection.id else { continue } // Ensure ID is not nil
            let rateOfChange = Int(collection.rateOfChange) // Convert Int32 to Int

            // Convert NSSet to [SavedColorModel]
            let savedColorModels: [SavedColorModel] = (collection.savedColors as? Set<SavedColor>)?.map { color in
                // Assuming SavedColorModel can be initialized with SavedColor properties
                if let colorExistingId = color.id {
                    let colorConversion = SavedColorModel(id: colorExistingId, color: UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha))
                    return colorConversion

                }else{
                    let colorConversion = SavedColorModel(id: UUID(), color: UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha))
                    return colorConversion

                }
            } ?? [] // Provide an empty array if conversion fails

            // Create an instance of SavedColorModels with the converted types
            let individualCollection = SavedColorModels(id: collectionId, savedColorModels: savedColorModels, rateOfChange: rateOfChange)
            fetchedCollection.append(individualCollection)
        }
        self.collections = fetchedCollection
    }




//    func fetchColorCollections() {
//        let request: NSFetchRequest<ColorCollection> = ColorCollection.fetchRequest()
//        // Add any sort descriptors or predicates here if necessary
//        
//        do {
//            collections = try context.fetch(request)
//        } catch {
//            print("Error fetching color collections: \(error)")
//        }
//    }

    





}
