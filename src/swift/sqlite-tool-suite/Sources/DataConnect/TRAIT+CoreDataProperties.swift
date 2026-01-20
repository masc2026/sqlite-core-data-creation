//
//  TRAIT+CoreDataProperties.swift

import Foundation
import CoreData


extension TRAIT {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TRAIT> {
        return NSFetchRequest<TRAIT>(entityName: "TRAIT")
    }

    @NSManaged public var category: String?
    @NSManaged public var comment: String?
    @NSManaged public var index: NSNumber?
    @NSManaged public var info: String?
    @NSManaged public var key: String?
    @NSManaged public var md: String?
    @NSManaged public var name: String?
    @NSManaged public var nr: NSNumber?
    @NSManaged public var section: String?
    @NSManaged public var sectionnr: NSNumber?
    @NSManaged public var type: NSNumber?
    @NSManaged public var author: PERSON?
    @NSManaged public var spec: SPECDETAIL?

}

extension TRAIT : Identifiable {

}
