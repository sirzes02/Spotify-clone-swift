//
//  AlbumViewController.swift
//  spotify-sub
//
//  Created by Santiago Varela on 17/08/24.
//

import UIKit

class AlbumViewController: UIViewController {
    enum Constants {
        enum Values {
            static let itemVerticalPadding: CGFloat = 1
            static let itemHorizontalPadding: CGFloat = 2
            static let groupHeightPadding: CGFloat = 60
        }

        enum Labels {
            static let saveAlbum = "Save album"
            static let cancel = "Cancel"
            static let actions = "Actions"
            static let releaseDate = "Release Date:"
        }
    }

    private let album: Album
    private var viewModels = [AlbumCollectionViewCellViewModel]()
    private var tracks = [AudioTrack]()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(
                top: Constants.Values.itemVerticalPadding,
                leading: Constants.Values.itemHorizontalPadding,
                bottom: Constants.Values.itemVerticalPadding,
                trailing: Constants.Values.itemHorizontalPadding
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(Constants.Values.groupHeightPadding)
                ),
                repeatingSubitem: item,
                count: 1
            )

            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(1)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                ),
            ]

            return section
        }

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            AlbumTrackCollectionViewCell.self,
            forCellWithReuseIdentifier: AlbumTrackCollectionViewCell.identifier
        )
        collectionView.register(
            PlaylistHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier
        )
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        return collectionView
    }()

    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = album.name
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)

        setupConstraints()
        fetchData()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapActions))
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc private func didTapActions() {
        let actionSheet = UIAlertController(title: album.name, message: Constants.Labels.actions, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: Constants.Labels.cancel, style: .cancel))
        actionSheet.addAction(UIAlertAction(title: Constants.Labels.saveAlbum, style: .default) { [weak self] _ in
            self?.saveAlbum()
        })

        present(actionSheet, animated: true)
    }

    private func saveAlbum() {
        APICaller.shared.saveAlbum(album: album) { success in
            if success {
                HapticsManager.shared.vibrate(for: .success)
                NotificationCenter.default.post(name: .albumSavedNotification, object: nil)
            } else {
                HapticsManager.shared.vibrate(for: .error)
            }
        }
    }

    private func fetchData() {
        APICaller.shared.getAlbumDetails(for: album) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(model):
                    self?.tracks = model.tracks.items
                    self?.viewModels = model.tracks.items.map {
                        AlbumCollectionViewCellViewModel(
                            name: $0.name,
                            artistName: $0.artists.first?.name ?? "-"
                        )
                    }
                    self?.collectionView.reloadData()
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AlbumTrackCollectionViewCell.identifier,
            for: indexPath
        ) as? AlbumTrackCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: viewModels[indexPath.row])

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                  ofKind: kind,
                  withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
                  for: indexPath
              ) as? PlaylistHeaderCollectionReusableView
        else {
            return UICollectionReusableView()
        }

        let headerViewModel = PlaylistHeaderViewViewModel(
            name: album.name,
            ownerName: album.artists.first?.name,
            description: "\(Constants.Labels.releaseDate) \(String.formattedDate(string: album.release_date))",
            artworkURL: URL(string: album.images.first?.url ?? "")
        )
        header.configure(with: headerViewModel)
        header.delegate = self

        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        var track = tracks[indexPath.row]
        track.album = album

        PlaybackPresenter.shared.startPlayback(from: self, track: track)
    }
}

// MARK: - PlaylistHeaderCollectionReusableViewDelegate

extension AlbumViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapAll(_: PlaylistHeaderCollectionReusableView) {
        let tracksWithAlbum: [AudioTrack] = tracks.map {
            var track = $0
            track.album = self.album

            return track
        }
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracksWithAlbum)
    }
}
