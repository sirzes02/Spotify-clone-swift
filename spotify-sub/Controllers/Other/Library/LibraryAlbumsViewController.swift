//
//  LibraryAlbumsViewController.swift
//  spotify-sub
//
//  Created by Santiago Varela on 30/08/24.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {
    enum Constants {
        enum Values {
            static let noAlbumsViewSize: CGFloat = 150
            static let rowHeightDefault: CGFloat = 70
        }

        enum Labels {
            static let noAlbum = "You do not have any album yet."
            static let browse = "Browse"
        }
    }

    private var albums = [Album]()
    private var observer: NSObjectProtocol?

    private lazy var noAlbumsView: ActionLabelView = {
        let view = ActionLabelView()
        view.isHidden = true
        view.delegate = self
        view.configure(with: ActionLabelViewViewModel(
            text: Constants.Labels.noAlbum,
            actionTitle: Constants.Labels.browse
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
        view.addSubviews(tableView, noAlbumsView)

        setUpConstraints()
        fetchData()

        observer = NotificationCenter.default.addObserver(
            forName: .albumSavedNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.fetchData()
            }
        )
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            noAlbumsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noAlbumsView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noAlbumsView.widthAnchor.constraint(equalToConstant: Constants.Values.noAlbumsViewSize),
            noAlbumsView.heightAnchor.constraint(equalToConstant: Constants.Values.noAlbumsViewSize),
        ])
    }

    private func fetchData() {
        albums.removeAll()
        APICaller.shared.getCurrentUserAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(albums):
                    self?.albums = albums
                    self?.updateUI()
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func updateUI() {
        if albums.isEmpty {
            noAlbumsView.isHidden = false
            tableView.isHidden = true
        } else {
            noAlbumsView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}

extension LibraryAlbumsViewController: ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_: ActionLabelView) {
        tabBarController?.selectedIndex = 0
    }
}

extension LibraryAlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultSubtitleTableViewCell.identifier,
            for: indexPath
        ) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let album = albums[indexPath.row]

        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(
            title: album.name,
            subtitle: album.artists.first?.name ?? "-",
            imageURL: URL(string: album.images.first?.url ?? "")
        ))

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()

        let album = albums[indexPath.row]
        let vc = AlbumViewController(album: album)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        Constants.Values.rowHeightDefault
    }
}
