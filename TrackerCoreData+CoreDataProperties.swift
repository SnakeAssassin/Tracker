//
//  TrackerCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Joe Kramer on 18.08.2024.
//
//

import Foundation
import CoreData


extension TrackerCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }

    @NSManaged public var color: String?
    @NSManaged public var emoji: String?
    @NSManaged public var eventDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isPinned: Bool
    @NSManaged public var name: String?
    @NSManaged public var schedule: NSObject?
    @NSManaged public var category: TrackerCategoryCoreData?
    @NSManaged public var record: TrackerRecordCoreData?

}

extension TrackerCoreData : Identifiable {

}
