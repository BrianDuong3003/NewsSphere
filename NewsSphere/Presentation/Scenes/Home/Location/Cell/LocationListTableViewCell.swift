import UIKit
import Stevia

class LocationListTableViewCell: UITableViewCell {
    static let identifier = "LocationListTableViewCell"
    private lazy var iconLocation = UIImageView()
    private lazy var nameLocation = UILabel()
    private lazy var primaryLocation = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LocationListTableViewCell {
    private func setUpUI() {
        backgroundColor = .clear 
        selectionStyle = .none
        
        iconLocation.style {
            $0.image = UIImage(named: "ic_location")
            $0.contentMode = .scaleAspectFit
        }
        
        nameLocation.style {
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 18, weight: .regular)
        }
        
        primaryLocation.style {
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 14, weight: .regular)
        }
        
        contentView.subviews {
            iconLocation
            nameLocation
            primaryLocation
        }
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
