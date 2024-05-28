import UIKit

// Хедер и футер для Collect View
class SupplementaryTrackersView: UICollectionReusableView {
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0), // Минус, чтобы создать нижний отступ
            //titleLabel.widthAnchor.constraint(equalToConstant: 100), // Устанавливаем фиксированную ширину
            titleLabel.heightAnchor.constraint(equalToConstant: 46) // Устанавливаем фиксированную высоту
        ])

    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
