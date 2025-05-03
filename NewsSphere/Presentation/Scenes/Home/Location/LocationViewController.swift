import UIKit
import Stevia

class LocationViewController: UIViewController {
    
    private lazy var locationList = UITableView()
    private lazy var textField = UITextField()
    var coordinator: HomeCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
        setupConstraints()
    }
}

extension LocationViewController {
    private func setupView() {
        view.subviews {
            textField
            locationList
        }
    }
    
    private func setupStyle() {
        view.backgroundColor = .hexBackGround
        
        locationList.showsHorizontalScrollIndicator = false
        locationList.showsVerticalScrollIndicator = false
        locationList.backgroundColor = .hexBackGround
        locationList.separatorStyle = .none
        locationList.delegate = self
        locationList.dataSource = self
        locationList.estimatedRowHeight = 60
        locationList.rowHeight = UITableView.automaticDimension
        locationList.register(LocationListTableViewCell.self,
                      forCellReuseIdentifier: LocationListTableViewCell.identifier)
        
        textField.layer.cornerRadius = 10
        textField.placeholder = "Location..."
        textField.textAlignment = .left
    }
    
    private func setupConstraints() {
        textField.height(40).top(16).left(16).right(16)
        locationList.left(0).right(0).bottom(0)
        locationList.Top == textField.Bottom + 8
    }
}

extension LocationViewController : UITableViewDelegate, UITableViewDataSource {
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
        return cell
    }
}
