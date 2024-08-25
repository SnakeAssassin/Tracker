// MARK: Экран "Выбор типа трекера"
import UIKit

protocol AddTrackerViewControllerDelegate: AnyObject {
    func addNewTracker(newTracker: TrackerCategory)
}

// MARK: - AddTrackerViewController
final class AddTrackerViewController: UIViewController {
    
    // MARK: Properties
    weak var delegate: AddTrackerViewControllerDelegate?
    
    //MARK: View
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = String.localized("addTraсker.title.label")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "habitButton"
        button.backgroundColor = .ypBlack
        button.setTitle(String.localized("addTraсker.habbit.button"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(Self.habbitButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var eventButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "eventButton"
        button.backgroundColor = .ypBlack
        button.setTitle(String.localized("addTraсker.event.button"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(Self.eventButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [habitButton, eventButton])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: Actions
    @objc func habbitButtonClicked() {
        let viewController = NewTrackerViewController()
        viewController.delegate = self
        viewController.eventMode = false
        viewController.modalPresentationStyle = .formSheet
        present(viewController, animated: true, completion: nil)
    }
    
    @objc func eventButtonClicked() {
        let viewController = NewTrackerViewController()
        viewController.delegate = self
        viewController.eventMode = true
        viewController.setSchedule(weekdays: Weekdays.allCases)
        viewController.modalPresentationStyle = .formSheet
        present(viewController, animated: true, completion: nil)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setView()
    }
}

// MARK: - Extension NewHabitOrEventViewControllerDelegate
extension AddTrackerViewController: NewTrackerViewControllerDelegate {
    func addNewTracker(newTracker: TrackerCategory) {
        delegate?.addNewTracker(newTracker: newTracker)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Extensions Create View
extension AddTrackerViewController {
    private func setView() {
        let guide = view.safeAreaLayoutGuide
        
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 27)
        ])
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20)
        ])
    }
}
