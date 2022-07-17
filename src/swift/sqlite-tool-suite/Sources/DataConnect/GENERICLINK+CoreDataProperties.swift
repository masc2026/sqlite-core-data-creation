//
//  GENERICLINK+CoreDataProperties.swift

import Foundation
import CoreData


extension GENERICLINK {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GENERICLINK> {
        return NSFetchRequest<GENERICLINK>(entityName: "GENERICLINK")
    }

    @NSManaged public var comment: String?
    @NSManaged public var md: String?
    @NSManaged public var name: String?
    @NSManaged public var section: String?
    @NSManaged public var sectionnr: NSNumber?
    @NSManaged public var type: NSNumber?
    @NSManaged public var url: String?
    @NSManaged public var sets: NSSet?

}

// MARK: Generated accessors for sets
extension GENERICLINK {

    @objc(addSetsObject:)
    @NSManaged public func addToSets(_ value: GENERICLINKSET)

    @objc(removeSetsObject:)
    @NSManaged public func removeFromSets(_ value: GENERICLINKSET)

    @objc(addSets:)
    @NSManaged public func addToSets(_ values: NSSet)

    @objc(removeSets:)
    @NSManaged public func removeFromSets(_ values: NSSet)

}

extension GENERICLINK : Identifiable {

}
