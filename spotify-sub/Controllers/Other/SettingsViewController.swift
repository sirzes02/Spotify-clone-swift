//
//  SettingsViewController.swift
//  spotify-sub
//
//  Created by Santiago Varela on 10/08/24.
//

import UIKit

class SettingsViewController: UIViewController {
    enum Constants {
        enum Labels {
            static let title = "Settings"
            static let profileTitle = "Profile"
            static let profileDescription = "View Your Profile"
            static let accountTitle = "Account"
            static let accountDescription = "Sign Out"
            static let areSure = "Are you sure?"
            static let cancel = "Cancel"
        }
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self

        return tableView
    }()

    private var sections = [Section]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Constants.Labels.title
        view.backgroundColor = .systemBackground
        configureModules()

        view.addSubview(tableView)

        setUpConstraints()
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func configureModules() {
        sections = [
            Section(title: Constants.Labels.profileTitle, options: [Option(title: Constants.Labels.profileDescription, handler: { [weak self] in
                self?.viewProfile()
            })]),
            Section(title: Constants.Labels.accountTitle, options: [Option(title: Constants.Labels.accountDescription, handler: { [weak self] in
                self?.signOutTapped()
            })]),
        ]
    }

    private func signOutTapped() {
        let alert = UIAlertController(title: Constants.Labels.accountDescription, message: Constants.Labels.areSure, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.Labels.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: Constants.Labels.accountDescription, style: .destructive) { [weak self] _ in
            AuthManager.shared.signOut { signedOut in
                if signedOut {
                    DispatchQueue.main.async {
                        let navVC = UINavigationController(rootViewController: WelcomeViewController())
                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
                        navVC.modalPresentationStyle = .fullScreen

                        self?.present(navVC, animated: true) {
                            self?.navigationController?.popToRootViewController(animated: false)
                        }
                    }
                }
            }
        })

        present(alert, animated: true)
    }

    private func viewProfile() {
        let vc = ProfileViewController()
        vc.title = Constants.Labels.profileTitle
        vc.navigationItem.largeTitleDisplayMode = .never

        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        sections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var cellContext = cell.defaultContentConfiguration()
        cellContext.text = model.title
        cell.contentConfiguration = cellContext

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
}
