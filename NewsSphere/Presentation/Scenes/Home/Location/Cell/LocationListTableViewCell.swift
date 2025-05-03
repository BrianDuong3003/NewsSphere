import UIKit
import Stevia

class LocationListTableViewCell: UITableViewCell {
    static let identifier = "LocationListTableViewCell"
    private lazy var iconLocation = UIImageView()
    private lazy var nameLocation = UILabel()
    private lazy var primaryLocation = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupStyle()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LocationListTableViewCell {
    private func setupView() {
        contentView.subviews {
            iconLocation
            nameLocation
            primaryLocation
        }
    }
    
    private func setupStyle() {
        backgroundColor = .clear 
        selectionStyle = .none
        
        iconLocation.image = UIImage(named: "ic_location")
        iconLocation.contentMode = .scaleAspectFit
        
        nameLocation.textColor = .white
        nameLocation.font = .systemFont(ofSize: 18, weight: .regular)
        
        primaryLocation.textColor = .white
        primaryLocation.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    private func setupConstraints() {
        iconLocation.left(16).centerVertically().width(22).height(22)
        
        nameLocation.Top == iconLocation.Top
        nameLocation.Left == iconLocation.Right + 12
        nameLocation.right(16)
        
        primaryLocation.Top == nameLocation.Bottom + 2
        primaryLocation.Left == nameLocation.Left
        primaryLocation.right(16)
    }
}
