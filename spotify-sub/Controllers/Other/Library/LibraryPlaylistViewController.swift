//
//  LibraryPlaylistViewController.swift
//  spotify-sub
//
//  Created by Santiago Varela on 30/08/24.
//

import UIKit

class LibraryPlaylistViewController: UIViewController {
    enum Constants {
        enum Values {
            static let noPlaylistsViewSize: CGFloat = 150
            static let rowHeightDefault: CGFloat = 70
        }

        enum Labels {
            static let noPlayslist = "You do not have any playlist yet."
            static let create = "Create"
            static let newPlaylisTitle = "New Playlist"
            static let newPlaylisMessage = "Enter playlist name"
            static let newPlaylisPlaceholder = "Playlist..."
            static let cancel = "Cancel"
        }
    }

    private var playlists = [Playlist]()
    public var selectionHandler: ((Playlist) -> Void)?

    private lazy var noPlaylistView: ActionLabelView = {
        let view = ActionLabelView()
        view.isHidden = true
        view.delegate = self
        view.configure(with: ActionLabelViewViewModel(
            text: Constants.Labels.noPlayslist,
            actionTitle: Constants.Labels.create
        ))
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(
            SearchResultSubtitleTableViewCell.self,
            forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier
        )
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubviews(tableView, noPlaylistView)

        setUpConstraints()
        fetchData()

        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(didTapClose)
            )
        }
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            noPlaylistView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noPlaylistView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noPlaylistView.widthAnchor.constraint(equalToConstant: Constants.Values.noPlaylistsViewSize),
            noPlaylistView.heightAnchor.constraint(equalToConstant: Constants.Values.noPlaylistsViewSize),
        ])
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    private func fetchData() {
        APICaller.shared.getCurrentUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(playlists):
                    self?.playlists = playlists
                    self?.updateUI()
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func updateUI() {
        if playlists.isEmpty {
            noPlaylistView.isHidden = false
            tableView.isHidden = true
        } else {
            noPlaylistView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }

    public func showCreatePlaylistAlert() {
        let alert = UIAlertController(
            title: Constants.Labels.newPlaylisTitle,
            message: Constants.Labels.newPlaylisMessage,
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = Constants.Labels.newPlaylisPlaceholder
        }

        alert.addAction(UIAlertAction(title: Constants.Labels.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: Constants.Labels.create, style: .default) { _ in
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty
            else {
                return
            }

            APICaller.shared.createPlaylist(with: text) { [weak self] success in
                if success {
                    HapticsManager.shared.vibrate(for: .success)
                    self?.fetchData()
                } else {
                    HapticsManager.shared.vibrate(for: .error)
                    print("Failed to create playlist.")
                }
            }
        })

        present(alert, animated: true)
    }
}

extension LibraryPlaylistViewController: ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_: ActionLabelView) {
        showCreatePlaylistAlert()
    }
}

extension LibraryPlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        playlists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultSubtitleTableViewCell.identifier,
            for: indexPath
        ) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let playlist = playlists[indexPath.row]

        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(
            title: playlist.name,
            subtitle: playlist.owner.display_name,
            imageURL: URL(string: playlist.images?.first?.url ?? "")
        ))

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()

        let playlist = playlists[indexPath.row]

        guard selectionHandler == nil else {
            selectionHandler?(playlist)
            dismiss(animated: true)
            return
        }

        let vc = PlaylistViewController(playlist: playlist)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.isOwner = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        Constants.Values.rowHeightDefault
    }
}
