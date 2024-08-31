//
//  LibraryPlaylistViewController.swift
//  spotify-sub
//
//  Created by Santiago Varela on 30/08/24.
//

import UIKit

class LibraryPlaylistViewController: UIViewController {
    var playlists = [Playlist]()

    public var selectionHandler: ((Playlist) -> Void)?

    private let noPlaylistView = ActionLabelView()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(
            SearchResultSubtitleTableViewCell.self,
            forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier
        )
        tableView.isHidden = true

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        setUpNoPlaylistView()
        fetchData()

        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(didTapClose)
            )
        }
    }

    @objc func didTapClose() {
        dismiss(animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        noPlaylistView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        noPlaylistView.center = view.center

        tableView.frame = view.bounds
    }

    private func setUpNoPlaylistView() {
        view.addSubview(noPlaylistView)
        noPlaylistView.delegate = self
        noPlaylistView.configure(with: ActionLabelViewViewModel(
            text: "you do not have any playlist yet.",
            actionTitle: "Create"
        ))
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
            tableView.reloadData()
            noPlaylistView.isHidden = true
            tableView.isHidden = false
        }
    }

    public func showCreatePlaylistAlert() {
        let alert = UIAlertController(
            title: "New Playlist",
            message: "Enter playlist name",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "Playlist..."
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default) { _ in
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
        let playlists = playlists[indexPath.row]

        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(
            title: playlists.name,
            subtitle: playlists.owner.display_name,
            imageURL: URL(string: playlists.images?.first?.url ?? "")
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
        70
    }
}
