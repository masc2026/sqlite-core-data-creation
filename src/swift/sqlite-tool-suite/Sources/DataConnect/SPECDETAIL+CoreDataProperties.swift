//
//  SPECDETAIL+CoreDataProperties.swift

import Foundation
import CoreData


extension SPECDETAIL {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SPECDETAIL> {
        return NSFetchRequest<SPECDETAIL>(entityName: "SPECDETAIL")
    }

    @NSManaged public var abbrev: String?
    @NSManaged public var bbnr: NSNumber?
    @NSManaged public var inheritgl: NSNumber?
    @NSManaged public var level: NSNumber?
    @NSManaged public var objectid: String?
    @NSManaged public var rankobjectid: String?
    @NSManaged public var specnr: NSNumber?
    @NSManaged public var genericlinksets: NSSet?
    @NSManaged public var images: NSSet?
    @NSManaged public var infos: NSSet?
    @NSManaged public var links: NSSet?
    @NSManaged public var observations: NSSet?
    @NSManaged public var traits: NSSet?

}

// MARK: Generated accessors for genericlinksets
extension SPECDETAIL {

    @objc(addGenericlinksetsObject:)
    @NSManaged public func addToGenericlinksets(_ value: GENERICLINKSET)

    @objc(removeGenericlinksetsObject:)
    @NSManaged public func removeFromGenericlinksets(_ value: GENERICLINKSET)

    @objc(addGenericlinksets:)
    @NSManaged public func addToGenericlinksets(_ values: NSSet)

    @objc(removeGenericlinksets:)
    @NSManaged public func removeFromGenericlinksets(_ values: NSSet)

}

// MARK: Generated accessors for images
extension SPECDETAIL {

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
extension SPECDETAIL {

    @objc(addInfosObject:)
    @NSManaged public func addToInfos(_ value: INFO)

    @objc(removeInfosObject:)
    @NSManaged public func removeFromInfos(_ value: INFO)

    @objc(addInfos:)
    @NSManaged public func addToInfos(_ values: NSSet)

    @objc(removeInfos:)
    @NSManaged public func removeFromInfos(_ values: NSSet)

}

// MARK: Generated accessors for links
extension SPECDETAIL {

    @objc(addLinksObject:)
    @NSManaged public func addToLinks(_ value: LINK)

    @objc(removeLinksObject:)
    @NSManaged public func removeFromLinks(_ value: LINK)

    @objc(addLinks:)
    @NSManaged public func addToLinks(_ values: NSSet)

    @objc(removeLinks:)
    @NSManaged public func removeFromLinks(_ values: NSSet)

}

// MARK: Generated accessors for observations
extension SPECDETAIL {

    @objc(addObservationsObject:)
    @NSManaged public func addToObservations(_ value: OBSERVATION)

    @objc(removeObservationsObject:)
    @NSManaged public func removeFromObservations(_ value: OBSERVATION)

    @objc(addObservations:)
    @NSManaged public func addToObservations(_ values: NSSet)

    @objc(removeObservations:)
    @NSManaged public func removeFromObservations(_ values: NSSet)

}

// MARK: Generated accessors for traits
extension SPECDETAIL {

    @objc(addTraitsObject:)
    @NSManaged public func addToTraits(_ value: TRAIT)

    @objc(removeTraitsObject:)
    @NSManaged public func removeFromTraits(_ value: TRAIT)

    @objc(addTraits:)
    @NSManaged public func addToTraits(_ values: NSSet)

    @objc(removeTraits:)
    @NSManaged public func removeFromTraits(_ values: NSSet)

}

extension SPECDETAIL : Identifiable {

}
