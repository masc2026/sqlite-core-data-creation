//
//  LOCATION+CoreDataProperties.swift

import Foundation
import CoreData


extension LOCATION {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LOCATION> {
        return NSFetchRequest<LOCATION>(entityName: "LOCATION")
    }

    @NSManaged public var altitude: String?
    @NSManaged public var comment: String?
    @NSManaged public var geographicvalue: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var md: String?
    @NSManaged public var name: String?
    @NSManaged public var section: String?
    @NSManaged public var sectionnr: NSNumber?
    @NSManaged public var author: PERSON?
    @NSManaged public var div: NSSet?
    @NSManaged public var observations: NSSet?

}

// MARK: Generated accessors for div
extension LOCATION {

    @objc(addDivObject:)
    @NSManaged public func addToDiv(_ value: SPEC)

    @objc(removeDivObject:)
    @NSManaged public func removeFromDiv(_ value: SPEC)

    @objc(addDiv:)
    @NSManaged public func addToDiv(_ values: NSSet)

    @objc(removeDiv:)
    @NSManaged public func removeFromDiv(_ values: NSSet)

}

// MARK: Generated accessors for observations
extension LOCATION {

    @objc(addObservationsObject:)
    @NSManaged public func addToObservations(_ value: OBSERVATION)

    @objc(removeObservationsObject:)
    @NSManaged public func removeFromObservations(_ value: OBSERVATION)

    @objc(addObservations:)
    @NSManaged public func addToObservations(_ values: NSSet)

    @objc(removeObservations:)
    @NSManaged public func removeFromObservations(_ values: NSSet)

}

extension LOCATION : Identifiable {

}
