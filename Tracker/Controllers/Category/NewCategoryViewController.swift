// MARK: Экран "Новая категория"
import UIKit

// MARK: - NewCategoryProtocolDelegate
protocol NewCategoryProtocolDelegate: AnyObject {
    func addNewCategory(categoryName: String)
}

// MARK: - NewCategoryViewController
final class NewCategoryViewController: UIViewController {
    
    // MARK: Public Properties
    weak var delegate: NewCategoryProtocolDelegate?
    
    // MARK: Private Properties
    private let maxLengthTextField = 38
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = String.localized("newCategory.title.label")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var textField: RegisterTextField = {
        let textField = RegisterTextField(placeholder: String.localized("newCategory.textField"))
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
        label.text = String.localized("newCategory.warning.label")
        label.textColor = .ypRed
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var createCategoryButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "createCategoryButton"
        button.isEnabled = false
        button.backgroundColor = .ypGray
        button.setTitle(String.localized("newCategory.done.button"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(Self.createCategoryButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setView()
    }
    
    // MARK: Actions
    @objc private func didATapTextFieldButton() {
        textField.text = nil
    }
    
    @objc func createCategoryButtonClicked() {
        guard let newCategory = textField.text else { return }
        delegate?.addNewCategory(categoryName: newCategory)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension NewCategoryViewController: UITextFieldDelegate {
    
    // Ограничение символов на ввод
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        warningLabel.isHidden = newLength >= maxLengthTextField ? false : true
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        return newLength <= maxLengthTextField
    }
    
    // Считывание текста из поля ввода
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateButtonState(button: createCategoryButton, textField: textField)
    }
    
    // Скрыть клавиатуру по нажатию на enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Extensions Create View
extension NewCategoryViewController {
    private func setView() {
        let guide = view.safeAreaLayoutGuide
        
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27)
        ])
        
        view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(warningLabel)
        NSLayoutConstraint.activate([
            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8)
        ])
        
        view.addSubview(createCategoryButton)
        NSLayoutConstraint.activate([
            createCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createCategoryButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 0),
            createCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
