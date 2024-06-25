import UIKit

final class ColorCell: UICollectionViewCell {

    let titleLabel = UILabel()
    let contentContainerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(contentContainerView)
        contentContainerView.frame = CGRect(x: 6, y: 6, width: 40, height: 40)

        contentContainerView.layer.cornerRadius = 8
        contentContainerView.layer.masksToBounds = true
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
