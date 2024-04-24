import UIKit

//MARK: - RegisterTextField
final class RegisterTextField: UITextField {
    
    //MARK: - Private Property
    
    private let padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 46)
    
    

    
    //MARK: - Initializers
    
    init(placeholder: String) {
        super.init (frame: .zero)
        setupTextField(placeholder: placeholder)
    }
    
    @available(*, unavailable)
    required init? (coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    // MARK: - Override Methods
    private func setupTextField(placeholder: String) {
        textColor = .ypBlack
        layer.cornerRadius = 16
        layer.masksToBounds = true
        backgroundColor = .ypBackground
        font = .systemFont(ofSize: 17, weight: .regular)
      
        
        
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.ypGray])
 
        translatesAutoresizingMaskIntoConstraints = false
        
        

        
        
    }
    
    // MARK: - Override Methods
    
    
    // Текстовое поле внесенное пользователем
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset (by: padding)
    }
    
    // Размещение плейсхолдера
    override func placeholderRect (forBounds bounds: CGRect) -> CGRect {
        bounds.inset (by: padding)
    }
    
    // Размещение отредактированного текста
    override func editingRect (forBounds bounds: CGRect) -> CGRect {
        bounds.inset (by: padding)
    }
}


