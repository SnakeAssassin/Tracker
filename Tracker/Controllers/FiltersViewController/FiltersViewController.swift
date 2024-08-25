import Foundation
import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func useSelectedFilter(selectedFilter: Filters)
}

final class FiltersViewController: UIViewController {
    
    //MARK: Properties
    private var filtersArray: [Filters] = Filters.allCases
    var selectedFilter: Filters?
    var selectedIndexPath: IndexPath?
    weak var delegate: FiltersViewControllerDelegate?
    
    private lazy var filtersTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        filtersTableView.dataSource = self
        filtersTableView.delegate = self
        addElements()
        createNavigationBar()
        setupConstraints()
    }
    
    //MARK: Private Function
    private func addElements(){
        view.addSubview(filtersTableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            filtersTableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func createNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = String.localized("traсkers.buttonFilters.title")
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
}
    
// MARK: - Extension UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .ypLigthGray.withAlphaComponent(0.3)
        cell.selectionStyle = .none
        cell.textLabel?.text = String.localized(filtersArray[indexPath.row].rawValue)
        cell.accessoryView = nil
        if filtersArray[indexPath.row] == selectedFilter {
            selectedIndexPath = indexPath
            let checkmarkImageView = UIImageView(image: UIImage(named: "checkmark"))
            cell.accessoryView = checkmarkImageView
        }
        cell.viewWithTag(100)?.removeFromSuperview()
        if indexPath.row != filtersArray.count - 1 {
            createSeparatorImageView(cell: cell)
        }
        return cell
    }
}

// MARK: - Extension UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = filtersArray[indexPath.row]
        
        if self.selectedFilter != selectedFilter {
            updateAccessoryView(for: selectedFilter, in: tableView, at: indexPath)
            saveSelectedFilter(selectedFilter)
        }
        delegate?.useSelectedFilter(selectedFilter: selectedFilter)
        dismissViewWithDelay()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(75)
    }
    
    private func updateAccessoryView(for filter: Filters, in tableView: UITableView, at indexPath: IndexPath) {
        if let lastIndexPath = filtersArray.firstIndex(of: self.selectedFilter ?? Filters.allTrackers) {
            tableView.cellForRow(at: IndexPath(row: lastIndexPath, section: 0))?.accessoryView = nil
        }
        
        self.selectedFilter = filter
        let checkmarkImageView = UIImageView(image: UIImage(named: "checkmark"))
        tableView.cellForRow(at: indexPath)?.accessoryView = checkmarkImageView
    }
    
    private func saveSelectedFilter(_ filter: Filters) {
        UserDefaults.standard.set(filter.rawValue, forKey: "selectedFilter")
    }
    
    private func dismissViewWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
