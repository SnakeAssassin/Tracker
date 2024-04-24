import UIKit

func updateButtonState(button: UIButton, textField: UITextField) {
    guard let text = textField.text else { return }
    button.backgroundColor = text.isEmpty == true ? .ypGray : .ypBlack
    button.isEnabled = text.isEmpty == true ? false : true
}
