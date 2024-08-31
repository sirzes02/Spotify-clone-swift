//
//  LibraryToggleView.swift
//  spotify-sub
//
//  Created by Santiago Varela on 30/08/24.
//

import UIKit

protocol LibraryToggleViewDelegate: AnyObject {
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView)
    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView)
}

class LibraryToggleView: UIView {
    enum Constants {
        enum Values {
            static let paddingWidthDefault: CGFloat = 100
            static let paddingHeightDefault: CGFloat = 40
            static let indicatorHeight: CGFloat = 3
            static let indicatorCornerRadius: CGFloat = 4
            static let animationDuration: CGFloat = 0.2
        }
    }

    enum State {
        case playlist
        case album
    }

    var state: State = .playlist

    weak var delegate: LibraryToggleViewDelegate?

    private let playlistButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Playlists", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let albumsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Albums", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.masksToBounds = true
        view.layer.cornerRadius = Constants.Values.indicatorCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubviews(playlistButton, albumsButton, indicatorView)

        albumsButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)
        playlistButton.addTarget(self, action: #selector(didTapPlaylists), for: .touchUpInside)

        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    @objc private func didTapPlaylists() {
        update(for: .playlist)
        delegate?.libraryToggleViewDidTapPlaylists(self)
    }

    @objc private func didTapAlbums() {
        update(for: .album)
        delegate?.libraryToggleViewDidTapAlbums(self)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            playlistButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            playlistButton.topAnchor.constraint(equalTo: topAnchor),
            playlistButton.widthAnchor.constraint(equalToConstant: Constants.Values.paddingWidthDefault),
            playlistButton.heightAnchor.constraint(equalToConstant: Constants.Values.paddingHeightDefault),

            albumsButton.leadingAnchor.constraint(equalTo: playlistButton.trailingAnchor),
            albumsButton.topAnchor.constraint(equalTo: topAnchor),
            albumsButton.widthAnchor.constraint(equalToConstant: Constants.Values.paddingWidthDefault),
            albumsButton.heightAnchor.constraint(equalToConstant: Constants.Values.paddingHeightDefault),

            indicatorView.heightAnchor.constraint(equalToConstant: Constants.Values.indicatorHeight),
            indicatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: Constants.Values.paddingWidthDefault),
        ])

        update(for: state)
    }

    func update(for state: State) {
        self.state = state

        let targetX: CGFloat

        switch state {
        case .playlist:
            targetX = 0
        case .album:
            targetX = Constants.Values.paddingWidthDefault
        }

        UIView.animate(withDuration: Constants.Values.animationDuration) {
            self.indicatorView.frame.origin.x = targetX
        }
    }
}
