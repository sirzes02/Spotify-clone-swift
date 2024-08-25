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
    func didTapResult(_ result: SearchResult )
}

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private var sections: [SearchSection] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultDefaultTableViewCell.self,
                           forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        tableView.register(SearchResultSubtitleTableViewCell.self,
                           forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func update(with results: [SearchResult]) {
        var tracks: [SearchResult] = []
        var artists: [SearchResult] = []
        var playlists: [SearchResult] = []
        var albums: [SearchResult] = []

        for result in results {
            switch result {
            case .track:
                tracks.append(result)
            case .artist:
                artists.append(result)
            case .playlist:
                playlists.append(result)
            case .album:
                albums.append(result)
            }
        }
        
        sections = [
            SearchSection(title: "Songs", results: tracks),
            SearchSection(title: "Artists", results: artists),
            SearchSection(title: "Playlists", results: playlists),
            SearchSection(title: "Albums", results: albums)
        ]
        
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row]
        
        switch result {
        case .artist(let artist):
            guard let localCell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultDefaultTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultDefaultTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultDefaultTableViewCellViewModel(
                title: artist.name,
                imageURL: URL(string: artist.images?.first?.url ?? "")
            )
            
            localCell.configure(with: viewModel)
            
            return localCell
        case .album(let album):
            guard let localCell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: album.name,
                subtitle: album.artists.first?.name ?? "", 
                imageURL: URL(string: album.images.first?.url ?? "")
            )
            
            localCell.configure(with: viewModel)
            
            return localCell
        case .track(let track):
            guard let localCell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: track.name,
                subtitle: track.artists.first?.name ?? "-",
                imageURL: URL(string: track.album?.images.first?.url ?? "")
            )
            
            localCell.configure(with: viewModel)
            
            return localCell
        case .playlist(let playlist):
            guard let localCell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: playlist.name,
                subtitle: playlist.owner.display_name,
                imageURL: URL(string: playlist.images.first?.url ?? "")
            )
            
            localCell.configure(with: viewModel)
            
            return localCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = sections[indexPath.section].results[indexPath.row]
        delegate?.didTapResult(result)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
}
