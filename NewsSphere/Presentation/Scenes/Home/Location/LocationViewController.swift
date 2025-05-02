import UIKit
import Stevia

class LocationViewController: UIViewController {
    
    private lazy var locationList = UITableView()
    private lazy var textField = UITextField()
    var coordinator: HomeCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setupConstraints()
    }
}
extension LocationViewController {
    private func setUpUI() {
        view.backgroundColor = .hexBackGround
        locationList.style {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.backgroundColor = .hexBackGround
            $0.separatorStyle = .none
            $0.delegate = self
            $0.dataSource = self
            $0.estimatedRowHeight = 60
            $0.rowHeight = UITableView.automaticDimension
            $0.register(LocationListTableViewCell.self,
                        forCellReuseIdentifier: LocationListTableViewCell.identifier)
        }
        textField.style {
            $0.layer.cornerRadius = 10
            $0.placeholder = "Location..."
            $0.textAlignment = .left
        }
    }
    private func setupConstraints() {
        view.subviews {
            textField
            locationList
        }
        
        textField.height(40).top(16).left(16).right(16)
        
        // Constraints cho tableView
        locationList.left(0).right(0).bottom(0)
        locationList.Top == textField.Bottom + 8
    }
    
}
extension LocationViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LocationListTableViewCell.identifier,
            for: indexPath
        ) as? LocationListTableViewCell else {
            return UITableViewCell()
        }
        
        // configure cell
        
        return cell
    }
    
}
