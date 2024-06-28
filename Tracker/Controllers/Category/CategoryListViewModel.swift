import UIKit

// MARK: - CategoryProtocolDelegate
protocol CategoryProtocolDelegate: AnyObject {
    func setCategory(category: String)
    var categoryList: [String] { get set }
}

// MARK: - CategoryListViewModel
final class CategoryListViewModel: NSObject {
    
    // MARK: Properties
    weak var delegate: CategoryProtocolDelegate?
    var didChange: (() -> Void)?
    var categoryList: [String] {
        get {
            return delegate?.categoryList ?? [] }
        set {
            delegate?.categoryList = newValue
            didChange?()
        }
    }
    
    // MARK: Private Methods
    func setCategory(index: Int) {
        delegate?.setCategory(category: categoryList[index])
    }
}

// MARK: - NewCategoryProtocolDelegate
extension CategoryListViewModel: NewCategoryProtocolDelegate {
    func addNewCategory(categoryName: String) {
        categoryList.append(categoryName)
    }
}
