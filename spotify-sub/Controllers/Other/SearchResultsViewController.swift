//
//  SearchResultsViewController.swift
//  spotify-sub
//
//  Created by Santiago Varela on 10/08/24.
//

import UIKit

struct SearchSection {
    let title: String
    let results: [SearchResult]
}

protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapResult(_ result: SearchResult)
}

class SearchResultsViewController: UIViewController {
    weak var delegate: SearchResultsViewControllerDelegate?

    enum Constants {
        enum Labels {
            static let songs = "Songs"
            static let artists = "Artists"
            static let playlists = "Playlists"
            static let albums = "Albums"
        }
    }

    private var sections: [SearchSection] = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(
            SearchResultDefaultTableViewCell.self,
            forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier
        )
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

        view.backgroundColor = .clear
        view.addSubview(tableView)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func update(with results: [SearchResult]) {
        let groupedResults = Dictionary(grouping: results, by: { result -> String in
            switch result {
            case .track:
                return Constants.Labels.songs
            case .artist:
                return Constants.Labels.artists
            case .playlist:
                return Constants.Labels.playlists
            case .album:
                return Constants.Labels.albums
            }
        })

        sections = groupedResults.map { SearchSection(title: $0.key, results: $0.value) }
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }

    private func configureCell(for result: SearchResult, in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        switch result {
        case let .artist(artist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier, for: indexPath) as? SearchResultDefaultTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultDefaultTableViewCellViewModel(
                title: artist.name,
                imageURL: URL(string: artist.images?.first?.url ?? "")
            )
            cell.configure(with: viewModel)

            return cell

        case let .album(album):
            return createSubtitleCell(
                for: album.name,
                subtitle: album.artists.first?.name ?? "",
                imageURL: album.images.first?.url,
                in: tableView,
                at: indexPath
            )

        case let .track(track):
            return createSubtitleCell(
                for: track.name,
                subtitle: track.artists.first?.name ?? "-",
                imageURL: track.album?.images.first?.url,
                in: tableView,
                at: indexPath
            )

        case let .playlist(playlist):
            return createSubtitleCell(
                for: playlist.name,
                subtitle: playlist.owner.display_name,
                imageURL: playlist.images?.first?.url,
                in: tableView,
                at: indexPath
            )
        }
    }

    private func createSubtitleCell(
        for title: String,
        subtitle: String,
        imageURL: String?,
        in tableView: UITableView,
        at indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let viewModel = SearchResultSubtitleTableViewCellViewModel(
            title: title,
            subtitle: subtitle,
            imageURL: URL(string: imageURL ?? "")
        )
        cell.configure(with: viewModel)

        return cell
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        sections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row]

        return configureCell(for: result, in: tableView, at: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        delegate?.didTapResult(result)
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
}
