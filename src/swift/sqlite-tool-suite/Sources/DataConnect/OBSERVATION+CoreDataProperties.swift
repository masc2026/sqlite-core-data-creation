//
//  OBSERVATION+CoreDataProperties.swift

import Foundation
import CoreData


extension OBSERVATION {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OBSERVATION> {
        return NSFetchRequest<OBSERVATION>(entityName: "OBSERVATION")
    }

    @NSManaged public var altitude: String?
    @NSManaged public var comment: String?
    @NSManaged public var date: Date?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var md: String?
    @NSManaged public var remarks: String?
    @NSManaged public var section: String?
    @NSManaged public var sectionnr: NSNumber?
    @NSManaged public var author: PERSON?
    @NSManaged public var location: LOCATION?
    @NSManaged public var photos: NSSet?
    @NSManaged public var spec: SPECDETAIL?

}

// MARK: Generated accessors for photos
extension OBSERVATION {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: IMAGE)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: IMAGE)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}

extension OBSERVATION : Identifiable {

}
