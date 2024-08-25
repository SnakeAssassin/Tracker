import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    
    // MARK: Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    
    // MARK: Initialization
    convenience override init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
    }
    
    // MARK: Private Function
    private func fetchTracker(id: UUID) throws -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            throw error
        }
    }
    
    // MARK: Public Function
    func fetchDays(for id: UUID) throws -> [Date] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let result = try context.fetch(fetchRequest)
        let dates = result.compactMap { $0.date }
        return dates
    }
    
    func addOrDeleteRecord(id: UUID, date: Date) throws {
        if let existingRecord = try fetchRecord(id: id, date: date) {
            context.delete(existingRecord)
        } else {
            if date <= Date().dateWithoutTime() {
                guard let tracker = try fetchTracker(id: id) else { return }
                let newRecord = TrackerRecordCoreData(context: context)
                newRecord.id = id
                newRecord.date = date
                newRecord.tracker = tracker
            }
        }
        try context.save()
    }
    
    func fetchRecord(id: UUID, date: Date) throws -> TrackerRecordCoreData? {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date == %@", id as CVarArg, date as CVarArg)
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            throw error
        }
    }
    
    func fetchMinDate() throws -> Date? {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do {
            let result = try context.fetch(fetchRequest)
            return result.first?.date
        } catch {
            throw error
        }
    }
    
    func fetchAllTrackers() throws -> [TrackerForStatistics] {
        var trackers: [TrackerForStatistics] = []
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let result = try context.fetch(fetchRequest)
        for object in result {
            let tracker = TrackerForStatistics(
                id: object.id ?? UUID(),
                schedule: object.schedule?.components(separatedBy: ",").compactMap { Weekdays(rawValue: $0) } ?? [],
                dateEvent: object.eventDate,
                completedAt: object.record?.compactMap { ($0 as? TrackerRecordCoreData)?.date} ?? []
            )
            trackers.append(tracker)
        }
        return trackers
    }
    
    func deleteTrackerRecordsFromCoreData() throws {
        print(#fileID, #function)
        let request = TrackerRecordCoreData.fetchRequest()
        let records = try? context.fetch(request)
        records?.forEach { context.delete($0) }
        try context.save()
    }
}
