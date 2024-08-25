// MARK: Экран "Расписание"
import UIKit

// MARK: - ScheduleProtocolDelegate
protocol ScheduleViewControllerDelegate: AnyObject {
    func setSchedule(weekdays: [Weekdays])
}

// MARK: - ScheduleViewController
final class ScheduleViewController: UIViewController {
    
    // MARK: Properties
    weak var delegate: ScheduleViewControllerDelegate?
    internal var switchSelectedWeekdays: [Weekdays?]?
    
    // MARK: Private properties
    private var switches = [UISwitch]()
    private var selectedWeekdays: [Weekdays] = []
    private let weekdays: [Weekdays] = Weekdays.allCases
    private let cellHeight: CGFloat = 75
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = String.localized("schedule.title.label")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        button.setTitle(String.localized("schedule.done.button"), for: .normal)
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
        delegate?.setSchedule(weekdays: selectedWeekdays)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        if let index = switches.firstIndex(of: sender) {
            let dayOfWeek = weekdays[index]
            if sender.isOn {
                selectedWeekdays.append(dayOfWeek)
                switchSelectedWeekdays?.append(dayOfWeek)
            } else {
                if let indexToRemove = selectedWeekdays.firstIndex(of: dayOfWeek) {
                    selectedWeekdays.remove(at: indexToRemove)
                }
                if let indexToRemove = switchSelectedWeekdays!.firstIndex(of: dayOfWeek) {
                    switchSelectedWeekdays?.remove(at: indexToRemove)
                }
            }
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        navigationItem.hidesBackButton = true
        setView()
        setupSwitches()
    }
    
    //MARK: Private Function
    private func setupSwitches() {
        for day in weekdays {
            let switchControl = UISwitch()
            switchControl.onTintColor = .ypBlue
            switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            switches.append(switchControl)
            
            guard let switchSelectedWeekdays = switchSelectedWeekdays else { return }
            let isSelected = switchSelectedWeekdays.contains(day)
            switchControl.isOn = isSelected
            switchControl.sendActions(for: .valueChanged)
        }
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekdays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none
        cell.textLabel?.text = String.localized(weekdays[indexPath.row].rawValue)
        cell.accessoryView = switches[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, widthForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.width
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == weekdays.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
            okButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16)
        ])
    }
}
