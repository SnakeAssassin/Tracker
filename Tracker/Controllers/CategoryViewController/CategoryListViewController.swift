// MARK: Экран "Список категорий"

import UIKit
final class CategoryListViewController: UIViewController {
    
    // MARK: View
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = String.localized("categoryList.title.label")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var listTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var stubImageView: UIImageView = {
        let image = UIImage(named: "Stub trackers")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = String.localized("categoryList.text.label")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.setTitle(String.localized("categoryList.add.button"), for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    let viewModel: CategoryListViewModel
    
    // MARK: Initialization
    init(viewModel: CategoryListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        listTableView.dataSource = self
        listTableView.delegate = self
        addElements()
        createNavigationBar()
        setupConstraints()
        conditionStubs()
    }
    
    // MARK: Private Functions
    private func addElements() {
        view.addSubview(titleLabel)
        view.addSubview(listTableView)
        view.addSubview(addCategoryButton)
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            listTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            listTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            listTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            listTableView.heightAnchor.constraint(equalToConstant: CGFloat(viewModel.categoriesArray.count * 75)),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 80),
            stubLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80),
            stubLabel.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func createNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = String.localized("categoryList.title.label")
    }
    
    private func conditionStubs() {
        let isContainCategories = viewModel.conditionStubs()
        listTableView.isHidden = isContainCategories
        stubLabel.isHidden = !isContainCategories
        stubImageView.isHidden = !isContainCategories
    }
    
    private func createSeparatorImageView(cell: UITableViewCell) {
        let separatorImageView = UIImageView()
        separatorImageView.image = UIImage(named: "custom_separator")
        separatorImageView.tag = 100
        separatorImageView.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(separatorImageView)
        
        NSLayoutConstraint.activate([
            separatorImageView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16),
            separatorImageView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16),
            separatorImageView.bottomAnchor.constraint(equalTo: cell.bottomAnchor),
            separatorImageView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func updateTableView() {
        let heightConstraints = listTableView.constraints.filter { $0.firstAttribute == .height }
        listTableView.removeConstraints(heightConstraints)
        listTableView.heightAnchor.constraint(equalToConstant: CGFloat(viewModel.categoriesArray.count * 75)).isActive = true
        listTableView.reloadData()
        view.layoutIfNeeded()
    }
    
    private func showAlert(for indexPath: IndexPath, in tableView: UITableView) {
        let alert = UIAlertController(title: nil, message: String.localized("traсkers.delete.confirmation"), preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: String.localized("traсkers.delete"), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.deleteCategory(at: indexPath)
            for visibleIndexPath in tableView.indexPathsForVisibleRows ?? [] {
                if visibleIndexPath != indexPath {
                    tableView.cellForRow(at: visibleIndexPath)?.accessoryView = nil
                }
            }
            self.conditionStubs()
            self.updateTableView()
        }
        
        let cancelAction = UIAlertAction(title: String.localized("traсkers.cancel"), style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    @objc private func addCategoryButtonTapped() {
        if viewModel.selectedIndexPath != nil {
            viewModel.setCategory()
            dismiss(animated: true, completion: nil)
        } else {
            let viewController = NewCategoryViewController()
            viewController.delegate = self
            viewController.modalPresentationStyle = .formSheet
            present(viewController, animated: true, completion: nil)
        }
    }
}

// MARK: - Extension UITableViewDataSource
extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categoriesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .ypLigthGray.withAlphaComponent(0.3)
        cell.textLabel?.text = viewModel.categoriesArray[indexPath.row]
        cell.accessoryView = nil
        if viewModel.categoriesArray[indexPath.row] == viewModel.selectedCategory {
            viewModel.selectedIndexPath = indexPath
            let checkmarkImageView = UIImageView(image: UIImage(named: "checkmark"))
            cell.accessoryView = checkmarkImageView
        }
        cell.viewWithTag(100)?.removeFromSuperview()
        if indexPath.row != viewModel.categoriesArray.count - 1 {
            createSeparatorImageView(cell: cell)
        }
        return cell
    }
}

// MARK: - Extension UITableViewDelegate
extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedIndexPath = viewModel.selectedIndexPath, selectedIndexPath == indexPath {
            tableView.cellForRow(at: indexPath)?.accessoryView = nil
            viewModel.selectedIndexPath = nil
            viewModel.selectedCategory = nil
        } else {
            if let prevSelectedIndexPath = viewModel.selectedIndexPath {
                tableView.cellForRow(at: prevSelectedIndexPath)?.accessoryView = nil
            }
            let checkmarkImageView = UIImageView(image: UIImage(named: "checkmark"))
            tableView.cellForRow(at: indexPath)?.accessoryView = checkmarkImageView
            viewModel.selectedIndexPath = indexPath
            viewModel.selectedCategory = viewModel.categoriesArray[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(75)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let category = viewModel.categoriesArray[indexPath.row]
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: String.localized("traсkers.edit"), image: nil) { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.editingIndex = indexPath.row
                let editingCategoryVC = EditingCategoryViewController()
                editingCategoryVC.delegate = self
                editingCategoryVC.editingCategory = category
                let navVC = UINavigationController(rootViewController: editingCategoryVC)
                self.present(navVC, animated: true)
            }
            
            let deleteAction = UIAction(title: String.localized("traсkers.delete"), image: nil, attributes: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.showAlert(for: indexPath, in: tableView)
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
        return configuration
    }
}

// MARK: - Extension NewCategoryViewControllerDelegate
extension CategoryListViewController: NewCategoryViewControllerDelegate {
    func addNewCategory(categoryName: String) {
        viewModel.addNewCategory(categoryName)
        conditionStubs()
        updateTableView()
    }
}

// MARK: - Extension EditingCategoryViewControllerDelegate
extension CategoryListViewController: EditingCategoryViewControllerDelegate {
    func saveEditingCategory(editingCategory: String, newName: String) {
        viewModel.updateCategory(editingCategory, with: newName)
        updateTableView()
    }
}
