// MARK: Экран "Выбор типа трекера"
import UIKit

// MARK: - AddTrackerViewControllerDelegate
protocol AddTrackerViewControllerDelegate: AnyObject {
    func updateListOfTrackers(newCategory: TrackerCategory)
    var categoryList: [String] { get set }
}

// MARK: - AddTrackerViewController
final class AddTrackerViewController: UIViewController {
    
    // MARK: Public Properties
    weak var delegate: AddTrackerViewControllerDelegate?
    
    // MARK: Private Properties
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
        viewController.configViewController(title: String.localized("newTraсker.habbit.title"), sections: [String.localized("newTraсker.habbit.section1"), String.localized("newTraсker.habbit.section2")])
        viewController.modalPresentationStyle = .formSheet
        present(viewController, animated: true, completion: nil)
    }
    
    @objc func eventButtonClicked() {
        let viewController = NewTrackerViewController()
        viewController.delegate = self
        viewController.configViewController(title: String.localized("newTraсker.event.title"), sections: [String.localized("newTraсker.event.section1")])
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

// MARK: - Extension AddTrackerViewControllerDelegate
extension AddTrackerViewController: NewTrackerViewControllerDelegate {
    var categoryList: [String] {
        get { return delegate?.categoryList ?? [] }
        set { delegate?.categoryList = newValue }
    }
    
    func addNewTracker(newCategory: TrackerCategory) {
        delegate?.updateListOfTrackers(newCategory: newCategory)
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
