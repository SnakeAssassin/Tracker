// MARK: - Экран "Трекеры"
import UIKit

// MARK: TrackersViewController
final class TrackersViewController: UIViewController, UISearchBarDelegate {
    
    
    
    // MARK: Properties
    var categoryList: [String] = []                             // Список категорий 
    
    // MARK: Private properties
    private var categories: [TrackerCategory]?                  // Все категории и их трекеры
    private var visibleCategories: [TrackerCategory] = []       // Отображаемые категории на выбранный день
    private var selectedDate = Date()                           // Выбранная дата
    
    private var trackerCategoriesStore = TrackerCategoryStore()
    private var trackerStore = TrackerStore()
    private var trackerRecordStore = TrackerRecordStore()
    
    private let cellParams: GeometricParams = GeometricParams(cellCount: 2,
                                                              topInset: 0,
                                                              bottomInset: 0,
                                                              leftInset: 16,
                                                              rightInset: 16,
                                                              cellSpacingHorizontal: 9,
                                                              cellSpacingVertical: 0,
                                                              size: CGSize(width: 0, height: 0))
    private lazy var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.backgroundColor = .white
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        return navigationBar
    }()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TrackersCell.self,
                                forCellWithReuseIdentifier: TrackersCell.identifier)
        collectionView.register(SupplementaryTrackersView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "addTracker"
        button.setImage(UIImage(named: "Add tracker"), for: .normal)
        button.tintColor = .ypBlack
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -23, bottom: 0, right: 0)
        button.heightAnchor.constraint(equalToConstant: 42).isActive = true
        button.widthAnchor.constraint(equalToConstant: 42).isActive = true
        button.addTarget(self, action: #selector(Self.didAddButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.setValue("Отмена", forKey: "cancelButtonText")
        return searchController
    }()
    private lazy var stubTrackersView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Stub trackers")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
        image.widthAnchor.constraint(equalToConstant: 80).isActive = true
        return image
    }()
    private lazy var stubTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Actions
    @objc func didAddButton() {
        let viewController = AddTrackerViewController()
        viewController.delegate = self
        viewController.modalPresentationStyle = .popover
        present(viewController, animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(_ datePicker: UIDatePicker) {
        selectedDate = datePicker.date
        showVisibleTrackers()
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //clearDataStores()     // Удалить данные из CoreData
        trackerCategoriesStore.delegate = self
        reloadData()
        setView()
        setNavigationBar()
        showVisibleTrackers()
    }
    
    // MARK: Private Methods
    private func showStub() {
        stubTrackersView.isHidden = visibleCategories.isEmpty == false ? true : false
        stubTitleLabel.isHidden = visibleCategories.isEmpty == false ? true : false
    }
    
    private func showVisibleTrackers() {
        let calendar = Calendar(identifier: .iso8601)
        let components = calendar.dateComponents([.weekday], from: selectedDate)
        if let categories = categories, let weekdayNumber = components.weekday {
            let adjustedWeekdayNumber = (weekdayNumber == 1) ? 7 : weekdayNumber - 1
            visibleCategories = categories.compactMap { category in
                let trackers = category.trackers.filter { tracker in
                    let dateCondition = tracker.schedule.contains { weekDay in weekDay.numberValue == adjustedWeekdayNumber } == true
                    return dateCondition
                }
                if trackers.isEmpty { return nil }
                return TrackerCategory(title: category.title, trackers: trackers)
            }
        }
        showStub()
        collectionView.reloadData()
    }
    
    private func reloadData() {
        categories = trackerCategoriesStore.trackersCategories
        categories?.forEach { category in
            let title = category.title
            categoryList.append(title)
        }
        datePickerValueChanged(datePicker)
    }
    
    private func isCompletedToday(id: UUID) -> Bool {
        let days = try? trackerRecordStore.fetchDays(for: id)
        
        return (days?.contains(selectedDate) ?? false)
    }
}

// MARK: - Наполнение ячейки UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    // Количество секций в коллекции
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count/*categories?.count ?? 0*/
    }
    
    // Количество ячеек в секции
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    // Ячейка
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCell.identifier,
            for: indexPath
        ) as? TrackersCell else { return UICollectionViewCell() }
        cell.prepareForReuse()
        cell.delegate = self
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isCompletedToday = isCompletedToday(id: tracker.id)
        let completedDays = try? trackerRecordStore.fetchDays(for: tracker.id).count
        
        cell.configCell(with: tracker,
                        isCompletedToday: isCompletedToday,
                        completedDays: completedDays ?? 0,
                        indexPath: indexPath)
        return cell
    }
    
    // Хедер секции
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
            ) as? SupplementaryTrackersView else { return UICollectionReusableView() }
            header.titleLabel.text = visibleCategories[indexPath.section].title/*categories?[indexPath.section].title*/
            return header
        } else { return UICollectionReusableView() }
    }
}

extension TrackersViewController: UICollectionViewDelegate {
}

// MARK: - Параметры отображения ячейки UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    // Размер ячейки
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth  = collectionView.frame.width - cellParams.paddingWidth
        let cellWidth = availableWidth / CGFloat(cellParams.cellCount)
        return CGSize(width: cellWidth, height: 148)
    }
    
    // Отступ ячейки от краев коллекции
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: cellParams.topInset,
                            left: cellParams.leftInset,
                            bottom: cellParams.bottomInset,
                            right: cellParams.rightInset)
    }
    
    // Вертикальные отступы между ячейками
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return cellParams.cellSpacingVertical
    }
    
    // Горизонтальные отступы  между ячейками
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return cellParams.cellSpacingHorizontal
    }
    
    // Размер хедера
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView,
                                             viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
                                             at: indexPath)
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: collectionView.frame.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}

// MARK: - Метод поиска UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    // Вызывается при изменении текста в поле поиска
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        print(searchText)
        // TODO: код для получения результатов поиска на основе searchText
    }
}

// MARK: - AddTrackerViewControllerDelegate
extension TrackersViewController: AddTrackerViewControllerDelegate {
    func updateListOfTrackers(newCategory: TrackerCategory) {

        try? trackerStore.addNewTracker(newCategory.trackers[0], with: newCategory)
        showVisibleTrackers()
        if self.presentedViewController is AddTrackerViewController {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func completedTracker(id: UUID, indexPath: IndexPath) {
        if selectedDate < Date() {
            do {
                try trackerRecordStore.addOrDeleteRecord(id: id, date: selectedDate)
            } catch {
                print("Ошибка сохранения изменения трекера \(error)")
            }
            collectionView.reloadItems(at: [indexPath])
        }
    }
}


// MARK: - Extensions Create View
extension TrackersViewController {
    private func setNavigationBar() {
        guard
            let navigationBar = navigationController?.navigationBar,
            let topItem = navigationBar.topItem
        else { return }
        topItem.setLeftBarButton(UIBarButtonItem(customView: addButton), animated: true)
        topItem.setRightBarButton(UIBarButtonItem(customView: datePicker), animated: true)
        topItem.title = "Трекеры"
        navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setView() {
        view.backgroundColor = .ypWhite
        let guide = view.safeAreaLayoutGuide
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        view.addSubview(stubTrackersView)
        NSLayoutConstraint.activate([
            stubTrackersView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            stubTrackersView.centerYAnchor.constraint(equalTo: guide.centerYAnchor)
        ])
        
        view.addSubview(stubTitleLabel)
        NSLayoutConstraint.activate([
            stubTitleLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            stubTitleLabel.topAnchor.constraint(equalTo: stubTrackersView.bottomAnchor, constant: 8)
        ])
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension TrackersViewController: TrackerCategoryStoreDelegate {
    func didUpdate(_ store: TrackerCategoryStore, _ update: TrackerCategoryStoreUpdate) {
        categories = store.trackersCategories
        collectionView.reloadData()
    }
}

// MARK: - Clear CoreData
private extension TrackersViewController {
    func clearDataStores() {
        print(#fileID, #function)
        do {
            try trackerStore.deleteTrackersFromCoreData()
            try trackerCategoriesStore.deleteCategoriesFromCoreData()
            try trackerRecordStore.deleteTrackerRecordsFromCoreData()
            
        } catch {
            print("CoreData: an error occurred")
        }
        print("CoreData: successfully cleared. Restart app")
    }
}
