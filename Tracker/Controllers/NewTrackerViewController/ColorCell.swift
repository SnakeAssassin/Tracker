import UIKit

final class ColorCell: UICollectionViewCell {

    private let contentContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(contentContainerView)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            contentContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentContainerView.widthAnchor.constraint(equalToConstant: 40),
            contentContainerView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(color: UIColor) {
        contentContainerView.backgroundColor = color
    }
}
