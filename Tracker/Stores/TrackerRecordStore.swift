import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    
    // MARK: Properties
    private let context: NSManagedObjectContext
    
    // MARK: Initialization
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                fatalError("Unable to cast delegate to AppDelegate")
            }
        let context = appDelegate.persistentContainer.viewContext
        do {
                try self.init(context: context)
            } catch {
                fatalError("Unable to initialize object: \(error.localizedDescription)")
            }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
    }
    
    // MARK: Public Methods
    
    // Получение завершенных дней для трекера
    func completedDays(for id: UUID) throws -> [Date] {
        return try fetchDays(for: id)
    }
    
    func fetchDays(for id: UUID) throws -> [Date] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let result = try context.fetch(fetchRequest)
        let dates = result.compactMap { $0.date }
        return dates
    }
    
    // Добавление или удаление записи
    func addOrDeleteRecord(id: UUID, date: Date) throws {
        if let existingRecord = try fetchRecord(id: id, date: date) {
            context.delete(existingRecord)
        } else {
            if date <= Date() {
                let newRecord = TrackerRecordCoreData(context: context)
                newRecord.id = id
                newRecord.date = date
            }
        }
        try context.save()
    }
    
    // Получение TrackerRecord по id и date:
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
    
    // Удаление TrackerRecord из CoreData
    func deleteTrackerRecordsFromCoreData() throws { // TODO: - delete in Sprint 16
        print(#fileID, #function)
        let request = TrackerRecordCoreData.fetchRequest()
        let records = try? context.fetch(request)
        records?.forEach { context.delete($0) }
        try context.save()
    }
}
