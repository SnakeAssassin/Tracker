import UIKit


final class CategoryCell: UITableViewCell {

    private var indexPath: IndexPath?
    
    let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupSubviews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.backgroundColor = .ypLigthGray
        checkmarkImageView.isHidden = !selected
    }
    
    private func setupSubviews() {
        addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkmarkImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    func configCell(indexPath: IndexPath) {
        self.indexPath = indexPath
    }
}
