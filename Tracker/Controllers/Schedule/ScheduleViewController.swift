// MARK: Экран "Расписание"
import UIKit

// MARK: - ScheduleProtocolDelegate
protocol ScheduleProtocolDelegate: AnyObject {
    func setSchedule(schedule: [Weekdays])
}

// MARK: - ScheduleViewController
final class ScheduleViewController: UIViewController {
    
    // MARK: Properties
    weak var delegate: ScheduleProtocolDelegate?
    internal var switchSelectedWeekdays: [Weekdays?]?
    
    // MARK: Private properties
    private var selectedDays = [Int]()
    private let weekdays: [Weekdays] = Weekdays.allCases
    private let cellHeight: CGFloat = 75
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: "Cell")
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(Self.didATapOkButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: Actions
    @objc private func didATapOkButton() {
        let result = selectedDays.sorted().map({weekdays[$0]})
        delegate?.setSchedule(schedule: result)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        navigationItem.hidesBackButton = true
        setView()
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    // Количество строк
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekdays.count
    }
    
    // Ячейка
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ScheduleCell
        cell.accessoryView = cell.scheduleSwitch
        cell.backgroundColor = .ypBackground
        cell.textLabel?.text = weekdays[indexPath.row].rawValue
        cell.configCell(indexPath: indexPath)
        cell.delegate = self
        
        // Начальное положение свитчера
        if let switchSelectedWeekdays = switchSelectedWeekdays,
            switchSelectedWeekdays.contains(weekdays[indexPath.row]) {
            selectedDays.append(weekdays[indexPath.row].numberValue - 1)
            cell.scheduleSwitch.isOn = true
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
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
        if indexPath.row == weekdays.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
    }
    
    // Убрать выделение с ячейки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SwitcherProtocolDelegate
extension ScheduleViewController: SwitcherProtocolDelegate {
    func receiveSwitcherValue(isSelected: Bool, indexPath: IndexPath) {
        if isSelected {
            selectedDays.append(indexPath.row)
        } else if let index = selectedDays.firstIndex(where: { $0 == indexPath.row }) {
            selectedDays.remove(at: index)
        }
    }
}

// MARK: - Extensions Create View
extension ScheduleViewController {

    private func setView() {
        let guide = view.safeAreaLayoutGuide
        
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 28)
        ])
        
        view.addSubview(tableView)
        let tableHeight = CGFloat(tableView.numberOfRows(inSection: 0)) * cellHeight
        
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: tableHeight),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(okButton)
        NSLayoutConstraint.activate([
            okButton.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            okButton.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 20),
            okButton.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -20),
            okButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
    }
}
