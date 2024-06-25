import CoreData
import UIKit

final class TrackerStore: NSObject {
    
    // MARK: Properties
    // Хранит объект контекста Core Data.
    private let context: NSManagedObjectContext
    // Вспомогательный объект для работы с цветами
    private let uiColorMarshalling = UIColorMarshalling()
    
    // MARK: Initialization
    // Удобный инициализатор
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
    
    // Основной инициализатор
    init(context: NSManagedObjectContext) throws {
        // Если контекст не передан (nil), создаем новый контекст Core Data.
        self.context = context
        super.init()
    }
    
    // MARK: Public Methods
    // Метод для добавления нового трекера с указанием категории.
    func addNewTracker(_ tracker: Tracker, with category: TrackerCategory) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTrackers(trackerCoreData, with: tracker)
        
        if let existingCategory = try fetchCategory(with: category.title) {
            existingCategory.addToTrackers(trackerCoreData)
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = category.title
            newCategory.addToTrackers(trackerCoreData)
        }
        try context.save()
    }
    
    // Метод для обновления свойств существующего объекта трекера.
    func updateExistingTrackers(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = DaysValueTransformer().transformedValue(tracker.schedule) as? NSObject
        trackerCoreData.eventDate = tracker.eventDate
    }
    
    // Метод для извлечения категории по ее названию.
    func fetchCategory(with title: String) throws -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            throw error
        }
    }
    
    // Удаление Tracker из Core Data
    func deleteTrackersFromCoreData() throws { // TODO: - delete in Sprint 16
        print(#fileID, #function)
        let request = TrackerCoreData.fetchRequest()
        let trackers = try? context.fetch(request)
        trackers?.forEach { context.delete($0) }
        try context.save()
    }
}
