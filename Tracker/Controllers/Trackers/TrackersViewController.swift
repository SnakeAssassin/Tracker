// MARK: - Экран "Трекеры"
import UIKit

// MARK: TrackersViewController
final class TrackersViewController: UIViewController, UISearchBarDelegate {
    
    
    
    
    // MARK: Public properties
    var categoryList: [String] = []                             // Список категорий
    
    // MARK: Private properties
    private var categories: [TrackerCategory]?                  // Все категории и их трекеры
    private var visibleCategories: [TrackerCategory] = []       // Отображаемые категории на выбранный день
    private var completedTrackers: [TrackerRecord] = []         // Выполненные трекеры
    private var selectedDate = Date()                           // Выбранная дата
    
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
        /// -----------------
        /// Данные для отладки
        categories = [
            TrackerCategory(title: "Нужное", trackers: [Tracker(id: UUID(), name: "Tracker 1", color: ._0, emoji: "🙂", schedule: [Weekdays.Monday, Weekdays.Sunday], eventDate: Date()),
                                                        Tracker(id: UUID(), name: "Tracker 2", color: ._1, emoji: "😻", schedule: [Weekdays.Tuesday, Weekdays.Sunday], eventDate: Date()),
                                                        Tracker(id: UUID(), name: "Tracker 3", color: ._2, emoji: "🌺", schedule: [Weekdays.Wednesday, Weekdays.Sunday], eventDate: Date()),
                                                        Tracker(id: UUID(), name: "Tracker 4", color: ._3, emoji: "❤️", schedule: [Weekdays.Thursday, Weekdays.Sunday], eventDate: Date())]),
            TrackerCategory(title: "Важное", trackers: [Tracker(id: UUID(), name: "Tracker 5", color: ._4, emoji: "😱", schedule: [Weekdays.Friday, Weekdays.Sunday], eventDate: Date())]),
            TrackerCategory(title: "Ненужное", trackers: [Tracker(id: UUID(), name: "Tracker 6", color: ._5, emoji: "🚀", schedule: [Weekdays.Saturday, Weekdays.Sunday], eventDate: Date())]),
        ]
        categoryList = ["Нужное", "Важное", "Ненужное"]
        /// ----------------
        
        setView()
        setNavigationBar()
        showVisibleTrackers()
    }
    
    // MARK: Private Methods
    private func showStub() {
        stubTrackersView.isHidden = visibleCategories.isEmpty == false ? true : false
    }
    
    private func showVisibleTrackers() {
        let calendar = Calendar(identifier: .iso8601)
        print(calendar)
        let components = calendar.dateComponents([.weekday], from: selectedDate)
        if let categories = categories, let weekdayNumber = components.weekday {
            visibleCategories = categories.compactMap { category in
                let trackers = category.trackers.filter { tracker in
                    let dateCondition = tracker.schedule.contains { weekDay in weekDay.numberValue == weekdayNumber } == true
                    return dateCondition
                }
                if trackers.isEmpty { return nil }
                return TrackerCategory(title: category.title, trackers: trackers)
            }
        }
        showStub()
        collectionView.reloadData()
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
        return visibleCategories[section].trackers.count/*categories?[section].trackers.count ?? 0*/
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
        let isCompletedToday = completedTrackers.contains { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: selectedDate)
            return trackerRecord.id == tracker.id && isSameDay
        }
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        
        cell.configCell(with: tracker,
                        isCompletedToday: isCompletedToday,
                        completedDays: completedDays,
                        indexPath: indexPath)
        return cell
    }
    
    // Хедер секции
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
            ) as! SupplementaryTrackersView
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
        
        // Обновление существующей категории
        if var categories = categories {
            if let index = categories.firstIndex(where: { $0.title == newCategory.title }) {
                categories[index] = TrackerCategory(title: newCategory.title,
                                                    trackers: categories[index].trackers
                                                    + newCategory.trackers)
            } else {
                // Добавление новой категория
                categories.append(newCategory)
            }
            self.categories = categories
        } else {
            // Категория создается впервые
            self.categories = [newCategory]
        }
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
            let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
            completedTrackers.append(trackerRecord)
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func uncompletedTracker(id: UUID, indexPath: IndexPath) {
        if selectedDate < Date() {
            completedTrackers.removeAll { trackerRecord in
                let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: selectedDate)
                return trackerRecord.id == id && isSameDay
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
    }
}
