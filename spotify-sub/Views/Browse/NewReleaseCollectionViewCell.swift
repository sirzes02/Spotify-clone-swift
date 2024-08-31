//
//  NewReleaseCollectionViewCell.swift
//  spotify-sub
//
//  Created by Santiago Varela on 16/08/24.
//

import SDWebImage
import UIKit

class NewReleaseCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewReleaseCollectionViewCell"

    enum Constants {
        enum Values {
            static let paddingLabelsDefault: CGFloat = 10
            static let paddingVerticalDefault: CGFloat = 5
            static let paddingSubtitleLabelBottomDefault: CGFloat = 2
            static let fontSizeSemibold: CGFloat = 20
            static let fontSizeThinLight: CGFloat = 18
        }
    }

    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Values.fontSizeSemibold, weight: .semibold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let numberOfTracksLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Values.fontSizeThinLight, weight: .thin)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Values.fontSizeThinLight, weight: .light)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubviews(albumCoverImageView, albumNameLabel, numberOfTracksLabel, artistNameLabel)

        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            albumCoverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Values.paddingVerticalDefault),
            albumCoverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Values.paddingVerticalDefault),
            albumCoverImageView.widthAnchor.constraint(equalTo: contentView.heightAnchor),
            albumCoverImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),

            albumNameLabel.leadingAnchor.constraint(equalTo: albumCoverImageView.trailingAnchor, constant: Constants.Values.paddingLabelsDefault),
            albumNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Values.paddingLabelsDefault),
            albumNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Values.paddingVerticalDefault),

            artistNameLabel.leadingAnchor.constraint(equalTo: albumCoverImageView.trailingAnchor, constant: Constants.Values.paddingLabelsDefault),
            artistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Values.paddingLabelsDefault),
            artistNameLabel.topAnchor.constraint(equalTo: albumNameLabel.bottomAnchor, constant: Constants.Values.paddingVerticalDefault),

            numberOfTracksLabel.leadingAnchor.constraint(equalTo: albumCoverImageView.trailingAnchor, constant: Constants.Values.paddingLabelsDefault),
            numberOfTracksLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Values.paddingLabelsDefault),
            numberOfTracksLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Values.paddingVerticalDefault),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        albumNameLabel.text = nil
        artistNameLabel.text = nil
        numberOfTracksLabel.text = nil
        albumCoverImageView.sd_cancelCurrentImageLoad()
        albumCoverImageView.image = nil
    }

    func configure(with viewModel: NewReleasesCellViewModel) {
        albumNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        numberOfTracksLabel.text = "Tracks: \(viewModel.numberOfTracks)"
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL)
    }
}
