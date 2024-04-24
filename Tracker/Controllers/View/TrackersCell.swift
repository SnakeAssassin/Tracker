import UIKit

protocol TrackerCellDelegate: AnyObject{
    func completedTracker(id: UUID, indexPath: IndexPath)
    func uncompletedTracker(id: UUID, indexPath: IndexPath)
}

// Класс ячейки должен наследоваться от `UICollectionViewCell`.
// Ключевое слово final позволяет немного ускорить компиляцию и гарантирует, что от класса не будет никаких наследников.

// MARK: - Ячейка ColorCell
final class TrackersCell: UICollectionViewCell {
    
    weak var delegate: TrackerCellDelegate?
    
    static let identifier = "ColorCell"
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
    private lazy var backView: UIView = {
        let imageView = UIView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var emojiBackgroundView: UIView = {
        let emojiBackgroundView = UIView()
        emojiBackgroundView.layer.cornerRadius = 12
        emojiBackgroundView.layer.masksToBounds = true
        emojiBackgroundView.backgroundColor = .ypWhite
        emojiBackgroundView.alpha = 0.3
        emojiBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        return emojiBackgroundView
    }()
    
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        //label.text = ""
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .right
        label.baselineAdjustment = .alignCenters
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackerNameLabel: UILabel = {
        let label = UILabel()
        //label.text = ""
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.numberOfLines = 2
        label.textAlignment = .left
        label.baselineAdjustment = .alignBaselines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        //label.text = ""
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(/*frame: CGRect(x: 100, y: 100, width: 34, height: 34)*/)
        button.tintColor = .ypWhite
        button.addTarget(self, action: #selector(switchValueChanged(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc private func switchValueChanged(_ sender: UIButton) {
        guard let trackerId = trackerId , let indexPath = indexPath else { return }
        if isCompletedToday {
            delegate?.uncompletedTracker(id: trackerId, indexPath: indexPath)
        } else {
            delegate?.completedTracker(id: trackerId, indexPath: indexPath)
        }
    }
    
    // Конструктор:
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

extension TrackersCell {
    private func setupSubviews() {
        
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(backView)
        NSLayoutConstraint.activate([
            backView.heightAnchor.constraint(equalToConstant: 90),
            backView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        ])
        
        backView.addSubview(emojiBackgroundView)
        NSLayoutConstraint.activate([
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 12),
        ])
        
        backView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            emojiLabel.topAnchor.constraint(equalTo: backView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 12)
        ])
        
        backView.addSubview(trackerNameLabel)
        NSLayoutConstraint.activate([
            trackerNameLabel.topAnchor.constraint(equalTo: backView.topAnchor, constant: 44),
            trackerNameLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 12),
            trackerNameLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -12),
            trackerNameLabel.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -12)
        ])
        
        contentView.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            doneButton.heightAnchor.constraint(equalToConstant: 34),
            doneButton.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 8),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        contentView.addSubview(counterLabel)
        NSLayoutConstraint.activate([
            counterLabel.heightAnchor.constraint(equalToConstant: 18),
            counterLabel.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 16),
            counterLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: -8),
            counterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
}

extension TrackersCell {
    func configCell(with tracker: Tracker, isCompletedToday: Bool, completedDays: Int, indexPath: IndexPath) {

        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        backView.backgroundColor = tracker.color
        doneButton.backgroundColor = tracker.color
        trackerNameLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        let formattedLabel = formatDayLabel(daysCount: completedDays)
        counterLabel.text = formattedLabel
        
        let image = isCompletedToday ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        if isCompletedToday {
            // Установка полупрозрачного цвета фона кнопки
            doneButton.backgroundColor = doneButton.backgroundColor?.withAlphaComponent(0.3)
        }
        doneButton.setImage(image, for: .normal)
    }
    
    private func formatDayLabel(daysCount: Int) -> String {
        let suffix: String
        
        if daysCount % 10 == 1 && daysCount % 100 != 11 {
            suffix = "день"
        } else if (daysCount % 10 == 2 && daysCount % 100 != 12) ||
                    (daysCount % 10 == 3 && daysCount % 100 != 13) ||
                    (daysCount % 10 == 4 && daysCount % 100 != 14) {
            suffix = "дня"
        } else {
            suffix = "дней"
        }
        return "\(daysCount) \(suffix)"
    }
}
