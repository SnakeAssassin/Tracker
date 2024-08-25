import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate()
}

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
}

final class TrackerStore: NSObject {
    
    // MARK: Properties
    private let context: NSManagedObjectContext
    private(set) var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    weak var delegate: TrackerStoreDelegate?
    private(set) var date: Date
    private(set) var text: String
    private(set) var completedFilter: Bool?
    
    var trackersCategories: [TrackerCategory] {
        var trackerCategories: [TrackerCategory] = []
        var trackerDictionary: [String: [Tracker]] = [:]
        var pinnedTrackers: [Tracker] = []
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        for object in objects {
            guard let categoryTitle = object.category?.title else {
                continue
            }
            
            let tracker = Tracker(
                id: object.id ?? UUID(),
                name: object.name ?? "",
                color: object.color ?? "",
                emoji: object.emoji ?? "",
                schedule: object.schedule?.components(separatedBy: ",").map { Weekdays(rawValue: $0) } ?? [],
                eventDate: object.eventDate
            )
            
            if object.isPinned {
                pinnedTrackers.append(tracker)
            } else {
                if var trackers = trackerDictionary[categoryTitle] {
                    trackers.append(tracker)
                    trackerDictionary[categoryTitle] = trackers
                } else {
                    trackerDictionary[categoryTitle] = [tracker]
                }
            }
        }

        if !pinnedTrackers.isEmpty {
            trackerCategories.append(TrackerCategory(title: "Закрепленные", trackers: pinnedTrackers))
        }
        let sortedCategories = trackerDictionary.keys.sorted().map { categoryTitle in
            TrackerCategory(title: categoryTitle, trackers: trackerDictionary[categoryTitle]!)
        }
        trackerCategories += sortedCategories
        return trackerCategories
    }
    
    // MARK: Initialization
    convenience init(date: Date, text: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        try! self.init(context: context, date: date, text: text)
    }

    init(context: NSManagedObjectContext, date: Date, text: String) throws {
        self.context = context
        self.date = date
        self.text = text
        super.init()
        fetchedResultsController = createFetchedResultsController()
        try?fetchedResultsController?.performFetch()
    }
    
    // MARK: Private Function
    
    private func createPredicate() -> NSPredicate {
        var finalPredicate = createDatePredicate()
        if completedFilter != nil {
            let filterPredicate = completedFilter! ?
            NSPredicate(format: "SUBQUERY(record, $record, $record.date == %@).@count > 0", date as CVarArg) :
            NSPredicate(format: "SUBQUERY(record, $record, $record.date == %@).@count == 0", date as CVarArg)
            finalPredicate = NSCompoundPredicate(type: .and, subpredicates: [filterPredicate, finalPredicate])
        }
        if text != "" {
            let textPredicate = NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(TrackerCoreData.name), text)
            finalPredicate = NSCompoundPredicate(type: .and, subpredicates: [textPredicate, finalPredicate])
        }
        return finalPredicate
    }
    
    private func createDatePredicate() -> NSPredicate {
        guard date != Date.distantPast else { return NSPredicate(value: true) }
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        let filterWeekday = Weekdays.fromNumberValue(weekdayNumber)
        let weekdayPredicate = NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(TrackerCoreData.schedule), filterWeekday)
        let datePredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.eventDate), date as CVarArg)
        let result = NSCompoundPredicate(type: .or, subpredicates: [datePredicate, weekdayPredicate])
        return result
    }
    
    private func createFetchedResultsController() -> NSFetchedResultsController<TrackerCoreData>? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = createPredicate()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }
    
    private func updateExistingTrackers(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        let scheduleString = tracker.schedule.compactMap { $0?.rawValue }.joined(separator: ",")
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = scheduleString
        trackerCoreData.eventDate = tracker.eventDate
        trackerCoreData.isPinned = trackerCoreData.isPinned
    }
    
    private func fetchCategory(with title: String) throws -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            throw error
        }
    }
    
    private func fetchTracker(by id: UUID) throws -> TrackerCoreData {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let result = try context.fetch(fetchRequest)
            guard let trackerCoreData = result.first else {
                return TrackerCoreData(context: context)
            }
            return trackerCoreData
        } catch {
            throw error
        }
    }
    
    private func decodeScheduleData(_ data: Data) -> [String]? {
        do {
            let scheduleArray = try JSONSerialization.jsonObject(with: data, options: []) as? [String]
            return scheduleArray
        } catch {
            return nil
        }
    }
    
    // MARK: Internal Function
    func update(with date: Date, text: String?, completedFilter: Bool?) {
        self.date = date
        self.text = text ?? ""
        self.completedFilter = completedFilter
        let predicate = createPredicate()
        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка при выполнении update: \(error)")
        }
    }
    
    func addNewTracker(_ tracker: Tracker, with category: TrackerCategory) throws {
        let trackerCoreData = try fetchTracker(by: tracker.id)
        updateExistingTrackers(trackerCoreData, with: tracker)
        if let existingCategory = try fetchCategory(with: category.title) {
            existingCategory.addToTrackers(trackerCoreData)
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = category.title
            newCategory.addToTrackers(trackerCoreData)
        }
        do {
            try context.save()
        } catch {
            throw error
        }
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        do {
            let trackerCoreData = try fetchTracker(by: tracker.id)
            if let records = trackerCoreData.record as? Set<TrackerRecordCoreData> {
                for record in records {
                    context.delete(record)
                }
            }
            context.delete(trackerCoreData)
            try context.save()
        } catch {
            throw error
        }
    }
    
    func togglePin(_ tracker: Tracker) throws {
        let trackerCoreData = try fetchTracker(by: tracker.id)
        trackerCoreData.isPinned.toggle()
        try context.save()
    }
    
    func deleteTrackersFromCoreData() throws {
        let request = TrackerCoreData.fetchRequest()
        let trackers = try? context.fetch(request)
        trackers?.forEach { context.delete($0) }
        try context.save()
    }
    
    func haveTrackers(for date: Date) throws -> Bool {
        self.date = date
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "TrackerCoreData")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = createDatePredicate()
        let result = try context.fetch(fetchRequest)
        return (result.first?.intValue ?? 0) > 0
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
