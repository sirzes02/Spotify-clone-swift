//
//  ProfileViewController.swift
//  spotify-sub
//
//  Created by Santiago Varela on 10/08/24.
//

import SDWebImage
import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    enum Constants {
        enum Labels {
            static let title = "Profile"
            static let name = "Full name:"
            static let id = "Email Address:"
            static let email = "User ID:"
            static let plan = "Plan:"
            static let failed = "Failed to load profile"
        }
    }

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        return tableView
    }()

    private var models = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.Labels.title
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        fetchProfile()
        view.backgroundColor = .systemBackground
    }

    private func fetchProfile() {
        APICaller.shared.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(model):
                    self?.updateUI(with: model)
                case let .failure(error):
                    self?.failedToGetProfile()
                    print(error.localizedDescription)
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    private func updateUI(with model: UserProfile) {
        tableView.isHidden = false
        // Configure Table models
        models = [
            "\(Constants.Labels.name) \(model.display_name)",
            "\(Constants.Labels.email) \(model.email)",
            "\(Constants.Labels.id) \(model.id)",
            "\(Constants.Labels.plan) \(model.product)",
        ]
        createTableHeader(with: model.images.first?.url)
        tableView.reloadData()
    }

    private func createTableHeader(with string: String?) {
        guard let urlString = string, let url = URL(string: urlString) else {
            return
        }

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width / 1.5))
        let imageSize: CGFloat = headerView.height / 2
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        headerView.addSubview(imageView)
        imageView.center = headerView.center
        imageView.contentMode = .scaleAspectFit
        imageView.sd_setImage(with: url, completed: nil)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize / 2

        tableView.tableHeaderView = headerView
    }

    private func failedToGetProfile() {
        let label = UILabel(frame: .zero)
        label.text = Constants.Labels.failed
        label.sizeToFit()
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.center = view.center
    }

    // MARK: - TableView

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none

        var cellContext = cell.defaultContentConfiguration()
        cellContext.text = models[indexPath.row]

        cell.contentConfiguration = cellContext

        return cell
    }
}
