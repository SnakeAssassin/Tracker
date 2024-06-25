import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ store: TrackerCategoryStore, _ update: TrackerCategoryStoreUpdate)
}

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidTitle
}

struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: Public properties
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: Private properties
    // Контроллер для выполнения запросов и отслеживания изменений в данных Core Data
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private let uiColorMarshalling = UIColorMarshalling()
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
        
        // Настройка NSFetchedResultsController для отслеживания изменений в категориях трекеров
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
    
    // Получение всех категорий трекеров
    var trackersCategories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let categories = try? objects.map({ try self.getCategories(from: $0) })
        else { return [] }
        return categories
    }
    
    // MARK: Public Methods
    // Преобразования объекта из CoreData в TrackerCategory
    func getCategories(from trackerCategoryStore: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryStore.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTitle
        }
        var trackers: [Tracker] = []
        
        if let trackerSet = trackerCategoryStore.trackers as? Set<TrackerCoreData> {
            for trackerCoreData in trackerSet {
                let tracker = Tracker(
                    id: trackerCoreData.id ?? UUID(),
                    name: trackerCoreData.name ?? "",
                    color: uiColorMarshalling.color(from: trackerCoreData.color ?? ""),
                    emoji: trackerCoreData.emoji ?? "",
                    schedule: (DaysValueTransformer().reverseTransformedValue(trackerCoreData.schedule) as? [Weekdays]) ?? [],
                    eventDate: trackerCoreData.eventDate
                )
                trackers.append(tracker)
            }
        }
        return TrackerCategory(
            title: title,
            trackers: trackers
        )
    }
    
    // Удаление TrackerCategory из Core Data
    func deleteCategoriesFromCoreData() throws { // TODO: - delete in Sprint 16
        print("TCS Run deleteCategoriesFromCoreData()")
        let request = TrackerCategoryCoreData.fetchRequest()
        let categories = try? context.fetch(request)
        categories?.forEach { context.delete($0) }
        try context.save()
    }
}

// MARK: - Отслеживание изменений в данных через NSFetchedResultsController
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    // Уведомляет о начале изменений
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
    }
    
    // Уведомляет об окончании изменений
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(self, TrackerCategoryStoreUpdate(insertedIndexes: insertedIndexes!,
                                                             deletedIndexes: deletedIndexes!,
                                                             updatedIndexes: updatedIndexes!))
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
    }
    
    // Уведомляет об изменениях в объектах. Можно обрабатывать вставки, удаления и модификации ячеек таблицы, используя методы insertRows(at:with:), deleteRows(at:with:) и так далее.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        switch type {
        case .delete:
            deletedIndexes?.insert(indexPath.item)
        case .insert:
            insertedIndexes?.insert(indexPath.item)
        case.update:
            updatedIndexes?.insert(indexPath.item)
        default:
            break
        }
    }
}
