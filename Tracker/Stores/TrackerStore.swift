import CoreData
import UIKit


final class TrackerStore: NSObject {
// хранит объект контекста Core Data.
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    private let uiColorMarshalling = UIColorMarshalling()
    
// Удобный нициализатор, который позволяет создавать экземпляры TrackerStore без явного передачи контекста. Внутри этого инициализатора контекст Core Data извлекается из общего делегата приложения и передается в основной инициализатор init(context: NSManagedObjectContext).
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        try! self.init(context: context)
    }
    
// Основной инициализатор, который принимает контекст Core Data в качестве параметра и сохраняет его в свойстве context.
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
    }
    
    func addNewTracker(_ tracker: Tracker, with category: TrackerCategory) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTrackers(trackerCoreData, with: tracker)
        
        if let existingCategory = try fetchCategory(with: category.title) {
            existingCategory.addToTracker(trackerCoreData)
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = category.title
            newCategory.addToTracker(trackerCoreData)
        }
        try context.save()
    }

    func updateExistingTrackers(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        //guard let (colorString, _) = colorDictionary.first(where: { $0.value == tracker.color }) else { return }
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = DaysValueTransformer().transformedValue(tracker.schedule) as? NSObject
        trackerCoreData.eventDate = tracker.eventDate
    }
    
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
}
