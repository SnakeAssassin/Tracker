import Foundation

protocol CategoryListViewModelDelegate: AnyObject {
    func setCategory(category: String)
}

final class CategoryListViewModel {
    
    // MARK: Properties
    private let trackerCategoryStore = TrackerCategoryStore()
    weak var delegate: CategoryListViewModelDelegate?
    var categoriesArray: [String] = []
    var selectedCategory: String?
    var selectedIndexPath: IndexPath?
    var editingIndex: Int?
    
    // MARK: Initializer
    init() {
        categoriesArray = trackerCategoryStore.fetchAllCategory()
    }
    
    // MARK: Public Methods
    func addNewCategory(_ newCategory: String) {
        categoriesArray.append(newCategory)
        selectedCategory = newCategory
        selectedIndexPath = IndexPath(row: categoriesArray.count - 1, section: 0)
    }
    
    func updateCategory(_ oldName: String, with newName: String) {
        guard let editingIndex = editingIndex else { return }
        categoriesArray[editingIndex] = newName
        try? trackerCategoryStore.updateCategory(withTitle: oldName, newName: newName)
        selectedCategory = newName
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        let category = categoriesArray[indexPath.row]
        categoriesArray.remove(at: indexPath.row)
        try? trackerCategoryStore.deleteCategory(title: category)
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil
            selectedCategory = nil
        }
    }
    
    func conditionStubs() -> Bool {
        return categoriesArray.isEmpty
    }
    
    func setCategory() {
        if let selectedCategory {
            delegate?.setCategory(category: selectedCategory)
        }
    }
}
