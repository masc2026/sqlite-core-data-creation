//
//  DataController.swift
//
//  Created by Markus Schmid on 17.07.22.
//

import Foundation
import CoreData

public class DataController: NSObject {
    static var isInitialized: Bool = false
    
    var mainContext: NSManagedObjectContext!
 
    public init(source: URL, model: URL) {
        let description = NSPersistentStoreDescription(url: source)
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.setValue("DELETE" as NSObject, forPragmaNamed: "journal_mode")
        let managedObjectModel = NSManagedObjectModel(contentsOf:model)
        let persitentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        do {
            let _ = try persitentStoreCoordinator.addPersistentStore(type: CoreData.NSPersistentStore.StoreType.sqlite, at: source)
            mainContext = NSManagedObjectContext(NSManagedObjectContext.ConcurrencyType.mainQueue)
            mainContext.persistentStoreCoordinator=persitentStoreCoordinator
        } catch {
            print("Init Data Controller Failed")
            return
        }

    }

    public func countSpec() -> Int {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "SPEC")
        request.returnsObjectsAsFaults = false
        do {
            let count = try mainContext.count(for:request)
            return count
        } catch {
            print("Count query failed")
        }
        return -1
    }

    public func specNr(name : String) -> (String, Int) {
        let request: NSFetchRequest<SPEC> = NSFetchRequest(entityName: "SPEC")
        let predicate = NSPredicate(format: "sci_name == [c] %@", name)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            let result:[SPEC] = try mainContext.fetch(request)
            if result.count > 0 {
                return (result[0].sci_name!, result[0].nr!.intValue)
            }
            else {
                return ("",-1)
            }
        } catch {
            print("Count query failed")
        }
        return ("",-1)
    }
}
