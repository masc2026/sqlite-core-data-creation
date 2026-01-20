//
//  GENERICLINKSET+CoreDataProperties.swift

import Foundation
import CoreData


extension GENERICLINKSET {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GENERICLINKSET> {
        return NSFetchRequest<GENERICLINKSET>(entityName: "GENERICLINKSET")
    }

    @NSManaged public var bbnr: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var speckey: String?
    @NSManaged public var specnr: NSNumber?
    @NSManaged public var links: NSSet?
    @NSManaged public var specs: NSSet?

}

// MARK: Generated accessors for links
extension GENERICLINKSET {

    @objc(addLinksObject:)
    @NSManaged public func addToLinks(_ value: GENERICLINK)

    @objc(removeLinksObject:)
    @NSManaged public func removeFromLinks(_ value: GENERICLINK)

    @objc(addLinks:)
    @NSManaged public func addToLinks(_ values: NSSet)

    @objc(removeLinks:)
    @NSManaged public func removeFromLinks(_ values: NSSet)

}

// MARK: Generated accessors for specs
extension GENERICLINKSET {

    @objc(addSpecsObject:)
    @NSManaged public func addToSpecs(_ value: SPECDETAIL)

    @objc(removeSpecsObject:)
    @NSManaged public func removeFromSpecs(_ value: SPECDETAIL)

    @objc(addSpecs:)
    @NSManaged public func addToSpecs(_ values: NSSet)

    @objc(removeSpecs:)
    @NSManaged public func removeFromSpecs(_ values: NSSet)

}

extension GENERICLINKSET : Identifiable {

}
