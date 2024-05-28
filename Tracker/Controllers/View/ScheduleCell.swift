import UIKit

protocol SwitcherProtocolDelegate: AnyObject {
    func receiveSwitcherValue(isSelected: Bool, indexPath: IndexPath)
}

class ScheduleCell: UITableViewCell {
    
    weak var delegate: SwitcherProtocolDelegate?
    private var isSwitchSelected = false
    private var indexPath: IndexPath?
    
    lazy var scheduleSwitch: UISwitch = {
        let scheduleSwitch = UISwitch()
        scheduleSwitch.onTintColor = .ypBlue
        scheduleSwitch.translatesAutoresizingMaskIntoConstraints = false
        scheduleSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .touchUpInside)
        return scheduleSwitch
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        guard let indexPath = indexPath else { return }
        delegate?.receiveSwitcherValue(isSelected: sender.isOn, indexPath: indexPath)
    }
    
    private func setupSubviews() {
        addSubview(scheduleSwitch)
        
        NSLayoutConstraint.activate([
            scheduleSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            scheduleSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    func configCell(indexPath: IndexPath) {
        self.indexPath = indexPath
    }
}
