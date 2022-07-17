//
//  COLLECTIONVIEW+CoreDataProperties.swift

import Foundation
import CoreData


extension COLLECTIONVIEW {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<COLLECTIONVIEW> {
        return NSFetchRequest<COLLECTIONVIEW>(entityName: "COLLECTIONVIEW")
    }

    @NSManaged public var adduserdata: Bool
    @NSManaged public var cla_name: String?
    @NSManaged public var fam_name: String?
    @NSManaged public var gen_name: String?
    @NSManaged public var info: String?
    @NSManaged public var json: String?
    @NSManaged public var level: Int16
    @NSManaged public var nr: Int32
    @NSManaged public var ord_name: String?
    @NSManaged public var rank: String?
    @NSManaged public var sci_name: String?
    @NSManaged public var setnr: Int32
    @NSManaged public var spec_name: String?
    @NSManaged public var specdetails: SPECDETAIL?

}

extension COLLECTIONVIEW : Identifiable {

}
