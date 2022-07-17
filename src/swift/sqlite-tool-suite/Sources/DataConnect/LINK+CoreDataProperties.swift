//
//  LINK+CoreDataProperties.swift

import Foundation
import CoreData


extension LINK {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LINK> {
        return NSFetchRequest<LINK>(entityName: "LINK")
    }

    @NSManaged public var bbnr: NSNumber?
    @NSManaged public var comment: String?
    @NSManaged public var ctype: Int16
    @NSManaged public var date: Date?
    @NSManaged public var index: NSNumber?
    @NSManaged public var md: String?
    @NSManaged public var name: String?
    @NSManaged public var section: String?
    @NSManaged public var sectionnr: NSNumber?
    @NSManaged public var speckey: String?
    @NSManaged public var specnr: NSNumber?
    @NSManaged public var type: NSNumber?
    @NSManaged public var url: String?
    @NSManaged public var author: PERSON?
    @NSManaged public var spec: SPECDETAIL?

}

extension LINK : Identifiable {

}
