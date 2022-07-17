//
//  SPEC+CoreDataProperties.swift

import Foundation
import CoreData


extension SPEC {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SPEC> {
        return NSFetchRequest<SPEC>(entityName: "SPEC")
    }

    @NSManaged public var aggs: String?
    @NSManaged public var aggsranks: String?
    @NSManaged public var attributes: String?
    @NSManaged public var childs: String?
    @NSManaged public var de_name: String?
    @NSManaged public var en_name: String?
    @NSManaged public var fr_name: String?
    @NSManaged public var icon: NSNumber?
    @NSManaged public var images: String?
    @NSManaged public var info: String?
    @NSManaged public var nr: NSNumber?
    @NSManaged public var owner: NSNumber?
    @NSManaged public var rank: String?
    @NSManaged public var sci_name: String?
    @NSManaged public var status: NSNumber?
    @NSManaged public var synonyms: String?
    @NSManaged public var uuid: String?
    @NSManaged public var valid_nr: NSNumber?
    @NSManaged public var author: PERSON?
    @NSManaged public var geographic: LOCATION?

}

extension SPEC : Identifiable {

}
