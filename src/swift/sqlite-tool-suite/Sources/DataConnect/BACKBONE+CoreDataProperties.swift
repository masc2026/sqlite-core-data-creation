//
//  BACKBONE+CoreDataProperties.swift

import Foundation
import CoreData


extension BACKBONE {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BACKBONE> {
        return NSFetchRequest<BACKBONE>(entityName: "BACKBONE")
    }

    @NSManaged public var citation: String?
    @NSManaged public var filetype: String?
    @NSManaged public var info: String?
    @NSManaged public var name: String?
    @NSManaged public var namelangs: String?
    @NSManaged public var nativelang: String?
    @NSManaged public var nr: NSNumber?
    @NSManaged public var productid: String?
    @NSManaged public var productinfo: String?
    @NSManaged public var productversion: Float
    @NSManaged public var published: Date?
    @NSManaged public var ranklangs: String?
    @NSManaged public var roottaxa: String?
    @NSManaged public var source: String?
    @NSManaged public var sourcetype: String?
    @NSManaged public var specscounter: String?
    @NSManaged public var status: Int64
    @NSManaged public var uuid: String?
    @NSManaged public var version: String?

}

extension BACKBONE : Identifiable {

}
