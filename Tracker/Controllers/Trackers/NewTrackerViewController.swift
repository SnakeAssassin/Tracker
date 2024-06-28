// MARK: Экран "Создание трекера. Новая привычка"
import UIKit

// MARK: - NewTrackerViewControllerDelegate
protocol NewTrackerViewControllerDelegate: AnyObject {
    func addNewTracker(newCategory: TrackerCategory)
    var categoryList: [String] { get set }
}

// MARK: - NewTrackerViewController
final class NewTrackerViewController: UIViewController {
    
    // MARK: Public properties
    weak var delegate: NewTrackerViewControllerDelegate?
    
    // MARK: Private properties
    private var category: String?           // Выбрана категория
    private var schedule: [Weekdays]?          // Выбрано расписание
    private var selectedEmoji: IndexPath?    // Выбран emoji
    private var selectedColor: IndexPath?    // Выбран цвет
    private var tableViewTopConstraint: NSLayoutConstraint?
    private var collectionViewHeightConstraint: NSLayoutConstraint?
    
    private let trackerEmojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                                 "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                                 "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private let trackerColors = Array(0...17)
    private let maxLengthTextField = 38
    private var sections = ["Категория", "Расписание"] // !
    private let cellHeight: CGFloat = 75
    private let cellParams: GeometricParams = GeometricParams(cellCount: 18,
                                                              topInset: 24,
                                                              bottomInset: 24,
                                                              leftInset: 18,
                                                              rightInset: 18,
                                                              cellSpacingHorizontal: 0,
                                                              cellSpacingVertical: 0,
                                                              size: CGSize(width: 52, height: 52))
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 898)
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"   // !
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var textField: RegisterTextField = {
        let textField = RegisterTextField(placeholder: "Введите название трекера")
        textField.delegate = self
        textField.rightView = textFieldButton
        textField.rightViewMode = .whileEditing
        return textField
    }()
    private lazy var textFieldButton: UIButton = {
        let button = UIButton()
        button.tintColor = .ypGray
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        button.contentEdgeInsets = UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11)
        button.addTarget(self, action: #selector(Self.didATapTextFieldButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .ypRed
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypWhite
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(Self.didATapCancelButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypGray
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(Self.didATapCreateButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "emojiCell")
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "colorCell")
        collectionView.register(SupplementaryNewHabbitView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
        collectionView.allowsMultipleSelection = true                   // Отключение множественного выделения
        collectionView.allowsSelection = true                           // Разрешение выделения
        collectionView.isScrollEnabled = false                          // Отключение прокрутки
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    // MARK: Actions
    @objc private func didATapTextFieldButton() {
        textField.text = nil
    }
    
    @objc private func didATapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didATapCreateButton() {
        guard let selectedColor, let selectedEmoji, let category, let schedule else { return }
        
        let color = UIColor(named: String(selectedColor.row)) ?? UIColor.clear
        let emoji = trackerEmojis[selectedEmoji.row]
        let title = category
        
        let newTracker = Tracker(
            id: UUID(),
            name: textField.text ?? "",
            color: color,
            emoji: emoji,
            schedule: schedule,
            eventDate: Date())
        let categoryTracker = TrackerCategory(
            title: title,
            trackers: [newTracker])
        delegate?.addNewTracker(newCategory: categoryTracker)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setView()
    }
    
    // MARK: Public methods
    func configViewController(_ title: String, _ sections: [String]) {
        self.titleLabel.text = title
        self.sections = sections
        if sections.count == 1 {
            schedule = [.Monday, .Tuesday, .Wednesday, .Thursday, .Friday , .Saturday, .Sunday]
        }
    }
    
    // MARK: Private methods
    private func updateButtonState() {
        let bool = !(textField.text?.isEmpty == true) && category != nil && !(schedule?.isEmpty == true) && selectedEmoji != nil && selectedColor != nil
        createButton.backgroundColor = bool ? .ypBlack : .ypGray
        createButton.isEnabled = bool ? true : false
    }
}

// MARK: - ScheduleProtocolDelegate
extension NewTrackerViewController: ScheduleProtocolDelegate {
    func setSchedule(schedule: [Weekdays]) {
        self.schedule = schedule
        tableView.reloadData()
        updateButtonState()
    }
}

// MARK: - CategoryProtocolDelegate
extension NewTrackerViewController: CategoryProtocolDelegate {
    var categoryList: [String] {
        get { return delegate?.categoryList ?? [] }
        set { delegate?.categoryList = newValue }
    }
    
    func setCategory(category: String) {
        self.category = category
        tableView.reloadData()
        updateButtonState()
    }
}

// MARK: - UITextFieldDelegate
extension NewTrackerViewController: UITextFieldDelegate {
    // Ограничение символов на ввод
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        warningLabel.isHidden = newLength >= maxLengthTextField ? false : true
        tableViewTopConstraint?.constant = warningLabel.isHidden ? 24 : 62
        scrollView.contentSize.height = warningLabel.isHidden ? 898 : 936
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        return newLength <= maxLengthTextField
    }
    
    // Считывание текста из поля ввода
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateButtonState()
    }
    
    // Скрыть клавиатуру по нажатию на enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource
extension NewTrackerViewController: UITableViewDataSource {
    // Количество строк
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    // Ячейка
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = sections[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        cell.detailTextLabel?.textColor = .ypGray
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .ypBackground
        
        if indexPath.row == 0, let categoryFooter = category {
            cell.detailTextLabel?.text = categoryFooter
        }
        
        if indexPath.row == 1, let schedule = self.schedule {
            let scheduleFooter: String
            if schedule.count == 7 {
                scheduleFooter = "Каждый день"
            } else {
                let text = schedule.compactMap { $0.shortDayName }.joined(separator: ", ")
                scheduleFooter = text.isEmpty ? "" : text
            }
            cell.detailTextLabel?.text = scheduleFooter
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewTrackerViewController: UITableViewDelegate {
    // Высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    // Ширина ячейки
    func tableView(_ tableView: UITableView, widthForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.width
    }
    
    // Настройка ячейки (убрать последний сепаратор)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == sections.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
    }
    
    // Обработка нажатий на ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let viewModel = CategoryListViewModel()
            viewModel.delegate = self
            let viewController = CategoryListViewController(viewModel: viewModel)
            viewController.modalPresentationStyle = .formSheet
            present(viewController, animated: true, completion: nil)
        }
        
        if indexPath.row == 1 {
            let viewController = ScheduleViewController()
            viewController.delegate = self
            viewController.switchSelectedWeekdays = schedule
            viewController.modalPresentationStyle = .formSheet
            present(viewController, animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension NewTrackerViewController: UICollectionViewDataSource {
    
    // Количество секций
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    // Количество ячеек в секции
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int
    ) -> Int {
        return section == 0 ? trackerEmojis.count : trackerColors.count
    }
    
    //  Создание ячейки
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            guard let emojiCell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as? EmojiCell else { return UICollectionViewCell() }
            emojiCell.titleLabel.text = trackerEmojis[indexPath.row]
            emojiCell.titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
            emojiCell.backgroundColor = .clear
            return emojiCell
            
        } else if indexPath.section == 1 {
            guard let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as? ColorCell else { return UICollectionViewCell() }
            
            colorCell.contentContainerView.backgroundColor = UIColor(named: String(trackerColors[indexPath.row]))
            return colorCell
        } else {
            return UICollectionViewCell()
        }
    }
    
    // Хедер секции
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "header",
                                                                         for: indexPath
        ) as? SupplementaryNewHabbitView else { return SupplementaryNewHabbitView() }
        
        if kind == UICollectionView.elementKindSectionHeader {
            let section = indexPath.section
            if section == 0 {
                view.titleLabel.text = "Emoji"
            } else if section == 1 {
                view.titleLabel.text = "Цвет"
            }
        }
        view.titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return view
    }
    
    // Обновление высоты коллекции после отображения каждой ячейки
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        collectionViewHeightConstraint?.constant = collectionView.contentSize.height
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
    
    // Размер хедера секции
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView,
                                             viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
                                             at: indexPath)
        return headerView.systemLayoutSizeFitting(CGSize(width: 0, height: 0),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
    
    // Отступы ячеек от краев коллекции
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: cellParams.topInset,
                            left: cellParams.leftInset,
                            bottom: cellParams.bottomInset,
                            right: cellParams.rightInset)
    }
    
    // Размер ячейки
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return cellParams.size
    }
    
    // Минимальное расстояние между строками (вертикально)
    func collectionView(_: UICollectionView,
                        layout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt: Int
    ) -> CGFloat {
        return cellParams.cellSpacingVertical
    }
    
    // Минимальное расстояние между ячейками (горизонтально)
    func collectionView(_: UICollectionView,
                        layout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt: Int
    ) -> CGFloat {
        return cellParams.cellSpacingHorizontal
    }
}

// MARK: - UICollectionViewDelegate
extension NewTrackerViewController: UICollectionViewDelegate {
    
    // Выделить ячейку
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
            // Снять выделение с предыдущей ячейки
            if let section = selectedEmoji, selectedEmoji != indexPath {
                guard let cell = collectionView.cellForItem(at: section) as? EmojiCell else { return }
                cell.backgroundColor = .clear
                collectionView.deselectItem(at: section, animated: true)
            }
            
            // Выделить текущую ячейку
            selectedEmoji = indexPath
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else { return }
            cell.backgroundColor = .ypLigthGray
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
            
            
        } else if indexPath.section == 1 {
            
            // Снять выделение с предыдущей ячейки
            if let section = selectedColor, selectedColor != indexPath {
                guard let cell = collectionView.cellForItem(at: section) as? ColorCell else { return }
                cell.layer.borderWidth = 0
                collectionView.deselectItem(at: section, animated: false)
            }
            
            // Выделить текущую ячейку
            selectedColor = indexPath
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell,
                  let uiColor = UIColor(named: String(trackerColors[indexPath.row]))
            else { return }
            
            let newUIColor = uiColor.withAlphaComponent(0.3)
            let cgColor = newUIColor.cgColor
            cell.layer.borderColor = cgColor
            cell.layer.borderWidth = 3
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
        }
        updateButtonState()
    }
    
    // Снять выделение при повторном нажатии
    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedEmoji = nil
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else { return }
            cell.backgroundColor = .clear
        } else if indexPath.section == 1 {
            selectedColor = nil
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else { return }
            cell.layer.borderWidth = 0
        }
        updateButtonState()
    }
}

// MARK: - Extensions Create View
extension NewTrackerViewController {
    private func setView() {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        scrollView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 27),
            titleLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        scrollView.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        scrollView.addSubview(warningLabel)
        NSLayoutConstraint.activate([
            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8)
        ])
        
        scrollView.addSubview(tableView)
        
        let tableHeight = CGFloat(tableView.numberOfRows(inSection: 0)) * cellHeight
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24)
        tableViewTopConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: tableHeight),
            tableView.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        scrollView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Создаем констрейнт для нижней границы коллекции
        let bottomAnchor: NSLayoutYAxisAnchor
        if let lastCell = collectionView.visibleCells.last {
            bottomAnchor = lastCell.bottomAnchor
        } else {
            bottomAnchor = collectionView.topAnchor
        }
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // Создаем констрейнт для высоты коллекции
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 100)
        collectionViewHeightConstraint?.isActive = true
        
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
