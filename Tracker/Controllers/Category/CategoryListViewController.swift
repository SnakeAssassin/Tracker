// MARK: Экран "Список категорий"
import UIKit

// MARK: - CategoryProtocolDelegate
protocol CategoryProtocolDelegate: AnyObject {
    func setCategory(category: String)
    var categoryList: [String] { get set }
}

// MARK: - CategoryListViewController
final class CategoryListViewController: UIViewController {
    
    // MARK: Public Properties
    weak var delegate: CategoryProtocolDelegate?
    
    // MARK: Private Properties
    private var categoryList: [String] {
        get { return delegate?.categoryList ?? [] }
        set { delegate?.categoryList = newValue }
    }
    private var tableViewHeightConstraint: NSLayoutConstraint!
    private let cellHeight: CGFloat = 75
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var stubTrackersView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Stub trackers")
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
        image.widthAnchor.constraint(equalToConstant: 80).isActive = true
        return image
    }()
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stubTrackersView, textLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "Cell")
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "addCategoryButton"
        button.backgroundColor = .ypBlack
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(Self.addCategoryButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: Actions
    @objc func addCategoryButtonClicked() {
        let viewController = NewCategoryViewController()
        viewController.delegate = self
        viewController.modalPresentationStyle = .formSheet
        present(viewController, animated: true, completion: nil)
    }
    
    // MARK: Outlets
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        navigationItem.hidesBackButton = true
        setView()
        showStub()
        delegate?.categoryList = categoryList
    }
    
    // MARK: Private Methods
    private func updateView() {
        let indexPath = IndexPath(row: categoryList.endIndex - 1, section: 0)
        showStub()
        // Пересчет высоты таблицы
        tableViewHeightConstraint.constant = CGFloat(self.categoryList.count) * self.cellHeight
        // Вставить добавленную ячейку
        updateTableViewAnimated(indexPath: [indexPath])
        tableView.reloadData()
    }
    
    private func showStub() {
        stackView.isHidden = categoryList.isEmpty == false ? true : false
    }
}

// MARK: - NewCategoryProtocolDelegate
extension CategoryListViewController: NewCategoryProtocolDelegate {
    func addNewCategory(categoryName: String) {
        categoryList.append(categoryName)
        updateView()
    }
}

// MARK: - UITableViewDataSource
extension CategoryListViewController: UITableViewDataSource {
    // Количество строк
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    // Ячейка
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CategoryCell else { return UITableViewCell() }
        cell.textLabel?.text = categoryList[indexPath.row]
        cell.configCell(indexPath: indexPath)
        
        // Установка сепаратора для последней ячейки
        if indexPath.row == categoryList.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }
    
    func updateTableViewAnimated(indexPath: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPath, with: .automatic)
        }
    }
}

// MARK: - UITableViewDelegate
extension CategoryListViewController: UITableViewDelegate {
    // Высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    // Ширина ячейки
    func tableView(_ tableView: UITableView, widthForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.width
    }
    
    // Обработка нажатий на ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.setSelected(true, animated: true)
            delegate?.setCategory(category: categoryList[indexPath.row])
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // Обработка отпускания ячейки
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.setSelected(false, animated: true)
        }
    }
}

// MARK: - Extensions Create View
extension CategoryListViewController {
    private func setView() {
        let guide = view.safeAreaLayoutGuide
        
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27)
        ])
        
        view.addSubview(addCategoryButton)
        NSLayoutConstraint.activate([
            addCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addCategoryButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 0),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        view.addSubview(tableView)
        let tableHeight = CGFloat(categoryList.count) * cellHeight
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: tableHeight)
        tableViewHeightConstraint.isActive = true
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
        ])
    }
}
