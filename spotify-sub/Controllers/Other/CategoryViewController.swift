//
//  CategoryViewController.swift
//  spotify-sub
//
//  Created by Santiago Varela on 24/08/24.
//

import UIKit

class CategoryViewController: UIViewController {
    enum Constants {
        enum Values {
            static let itemPaddingDefault: CGFloat = 5
            static let groupHeightPadding: CGFloat = 250
        }
    }

    private let category: Category
    private var playlists = [Playlist]()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(
                top: Constants.Values.itemPaddingDefault,
                leading: Constants.Values.itemPaddingDefault,
                bottom: Constants.Values.itemPaddingDefault,
                trailing: Constants.Values.itemPaddingDefault
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(Constants.Values.groupHeightPadding)
                ),
                repeatingSubitem: item,
                count: 2
            )
            group.contentInsets = NSDirectionalEdgeInsets(
                top: Constants.Values.itemPaddingDefault,
                leading: Constants.Values.itemPaddingDefault,
                bottom: Constants.Values.itemPaddingDefault,
                trailing: Constants.Values.itemPaddingDefault
            )

            return NSCollectionLayoutSection(group: group)
        }

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            FeaturedPlaylistsCollectionViewCell.self,
            forCellWithReuseIdentifier: FeaturedPlaylistsCollectionViewCell.identifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        return collectionView
    }()

    init(category: Category) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = category.name
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)

        setupConstraints()
        fetchData()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func fetchData() {
        APICaller.shared.getCategoryPlaylist(category: category) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(playlists):
                    self?.playlists = playlists
                    self?.collectionView.reloadData()
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        playlists.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FeaturedPlaylistsCollectionViewCell.identifier,
            for: indexPath
        ) as? FeaturedPlaylistsCollectionViewCell else {
            return UICollectionViewCell()
        }

        let playlist = playlists[indexPath.row]
        cell.configure(with: FeaturedPlaylistCellViewModel(
            name: playlist.name,
            artworkURL: URL(string: playlist.images?.first?.url ?? ""),
            creatorName: playlist.owner.display_name
        ))

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let vc = PlaylistViewController(playlist: playlists[indexPath.row])
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
