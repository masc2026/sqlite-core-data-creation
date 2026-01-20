//
//  PERSON+CoreDataProperties.swift

import Foundation
import CoreData


extension PERSON {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PERSON> {
        return NSFetchRequest<PERSON>(entityName: "PERSON")
    }

    @NSManaged public var address: String?
    @NSManaged public var citedlong: String?
    @NSManaged public var country: String?
    @NSManaged public var email: String?
    @NSManaged public var firstname: String?
    @NSManaged public var gender: String?
    @NSManaged public var institution: String?
    @NSManaged public var language: NSNumber?
    @NSManaged public var lastname: String?
    @NSManaged public var md: String?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var shortauthor: String?
    @NSManaged public var tel: String?
    @NSManaged public var title: String?
    @NSManaged public var year: Date?
    @NSManaged public var images: NSSet?
    @NSManaged public var infos: NSSet?
    @NSManaged public var locations: NSSet?
    @NSManaged public var observations: NSSet?
    @NSManaged public var owner: OWNER?
    @NSManaged public var setauthor: NSSet?
    @NSManaged public var taxaauthor: NSSet?
    @NSManaged public var traitsauthor: NSSet?

}

// MARK: Generated accessors for images
extension PERSON {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: IMAGE)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: IMAGE)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

// MARK: Generated accessors for infos
extension PERSON {

    @objc(addInfosObject:)
    @NSManaged public func addToInfos(_ value: INFO)

    @objc(removeInfosObject:)
    @NSManaged public func removeFromInfos(_ value: INFO)

    @objc(addInfos:)
    @NSManaged public func addToInfos(_ values: NSSet)

    @objc(removeInfos:)
    @NSManaged public func removeFromInfos(_ values: NSSet)

}

// MARK: Generated accessors for locations
extension PERSON {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: LOCATION)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: LOCATION)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}

// MARK: Generated accessors for observations
extension PERSON {

    @objc(addObservationsObject:)
    @NSManaged public func addToObservations(_ value: OBSERVATION)

    @objc(removeObservationsObject:)
    @NSManaged public func removeFromObservations(_ value: OBSERVATION)

    @objc(addObservations:)
    @NSManaged public func addToObservations(_ values: NSSet)

    @objc(removeObservations:)
    @NSManaged public func removeFromObservations(_ values: NSSet)

}

// MARK: Generated accessors for setauthor
extension PERSON {

    @objc(addSetauthorObject:)
    @NSManaged public func addToSetauthor(_ value: SET)

    @objc(removeSetauthorObject:)
    @NSManaged public func removeFromSetauthor(_ value: SET)

    @objc(addSetauthor:)
    @NSManaged public func addToSetauthor(_ values: NSSet)

    @objc(removeSetauthor:)
    @NSManaged public func removeFromSetauthor(_ values: NSSet)

}

// MARK: Generated accessors for taxaauthor
extension PERSON {

    @objc(addTaxaauthorObject:)
    @NSManaged public func addToTaxaauthor(_ value: SPEC)

    @objc(removeTaxaauthorObject:)
    @NSManaged public func removeFromTaxaauthor(_ value: SPEC)

    @objc(addTaxaauthor:)
    @NSManaged public func addToTaxaauthor(_ values: NSSet)

    @objc(removeTaxaauthor:)
    @NSManaged public func removeFromTaxaauthor(_ values: NSSet)

}

// MARK: Generated accessors for traitsauthor
extension PERSON {

    @objc(addTraitsauthorObject:)
    @NSManaged public func addToTraitsauthor(_ value: TRAIT)

    @objc(removeTraitsauthorObject:)
    @NSManaged public func removeFromTraitsauthor(_ value: TRAIT)

    @objc(addTraitsauthor:)
    @NSManaged public func addToTraitsauthor(_ values: NSSet)

    @objc(removeTraitsauthor:)
    @NSManaged public func removeFromTraitsauthor(_ values: NSSet)

}

extension PERSON : Identifiable {

}
