import UIKit

class PlaylistViewController: UIViewController {
    enum Constants {
        enum Values {
            static let itemVerticalPadding: CGFloat = 1
            static let itemHorizontalPadding: CGFloat = 2
            static let groupHeightPadding: CGFloat = 60
        }

        enum Labels {
            static let removePlaylist = "Would you like to remove this from the playlist?"
            static let cancel = "Cancel"
            static let remove = "Remove"
        }
    }

    private let playlist: Playlist
    public var isOwner = false

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
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(1)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [headerItem]

            return section
        }

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.register(
            RecommendedTrackCollectionViewCell.self,
            forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier
        )
        collectionView.register(
            PlaylistHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier
        )

        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    private var viewModels = [RecommendedTrackCellViewModel]()
    private var tracks = [AudioTrack]()

    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = playlist.name
        view.backgroundColor = .systemBackground

        view.addSubview(collectionView)

        setUpConstraints()
        fetchPlaylistDetails()
        configureNavigationBar()
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapShare)
        )
    }

    private func fetchPlaylistDetails() {
        APICaller.shared.getPlaylistDetails(for: playlist) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(model):
                    self?.tracks = model.tracks.items.compactMap { $0.track }
                    self?.viewModels = model.tracks.items.compactMap {
                        RecommendedTrackCellViewModel(
                            name: $0.track.name,
                            artistName: $0.track.artists.first?.name ?? "-",
                            artworkURL: URL(string: $0.track.album?.images.first?.url ?? "")
                        )
                    }
                    self?.collectionView.reloadData()
                case let .failure(error):
                    print("Failed to load playlist details: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc private func didTapShare() {
        guard let url = URL(string: playlist.external_urls["spotify"] ?? "") else {
            return
        }

        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem

        present(vc, animated: true)
    }

    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }

        let touchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else {
            return
        }

        let trackToDelete = tracks[indexPath.row]
        let actionSheet = UIAlertController(
            title: trackToDelete.name,
            message: Constants.Labels.removePlaylist,
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: Constants.Labels.cancel, style: .cancel))
        actionSheet.addAction(UIAlertAction(title: Constants.Labels.remove, style: .destructive) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            APICaller.shared.removeTrackToPlaylist(track: trackToDelete, playlist: strongSelf.playlist) { success in
                DispatchQueue.main.async {
                    if success {
                        strongSelf.tracks.remove(at: indexPath.row)
                        strongSelf.viewModels.remove(at: indexPath.row)
                        strongSelf.collectionView.reloadData()
                    } else {
                        print("Failed to remove")
                    }
                }
            }
        })

        present(actionSheet, animated: true)
    }
}

// MARK: - UICollectionViewDelegate and UICollectionViewDataSource

extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
            for: indexPath
        ) as? RecommendedTrackCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: viewModels[indexPath.row])

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
            for: indexPath
        ) as? PlaylistHeaderCollectionReusableView,
            kind == UICollectionView.elementKindSectionHeader
        else {
            return UICollectionReusableView()
        }

        let headerViewModel = PlaylistHeaderViewViewModel(
            name: playlist.name,
            ownerName: playlist.owner.display_name,
            description: playlist.description,
            artworkURL: URL(string: playlist.images?.first?.url ?? "")
        )
        header.configure(with: headerViewModel)
        header.delegate = self

        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let track = tracks[indexPath.row]
        PlaybackPresenter.shared.startPlayback(from: self, track: track)
    }
}

// MARK: - PlaylistHeaderCollectionReusableViewDelegate

extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapAll(_: PlaylistHeaderCollectionReusableView) {
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracks)
    }
}
