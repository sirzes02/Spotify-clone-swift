//
//  RecommendedTrackCollectionViewCell.swift
//  spotify-sub
//
//  Created by Santiago Varela on 16/08/24.
//

import UIKit

class RecommendedTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendedTrackCollectionViewCell"

    enum Constants {
        enum Values {
            static let paddingAlbumCoverImageDefault: CGFloat = 4
            static let paddingAlbumCoverImageLeadingDefault: CGFloat = 5
            static let paddingAlbumCoverImageTopDefault: CGFloat = 2
            static let paddingTrailingDefault: CGFloat = 15
            static let paddingLeadingDefault: CGFloat = 10
            static let fontSizeRegular: CGFloat = 18
            static let fontSizeThin: CGFloat = 15
            static let imageRadius: CGFloat = 4
        }
    }

    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = Constants.Values.imageRadius
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Values.fontSizeRegular, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Values.fontSizeThin, weight: .thin)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubviews(albumCoverImageView, trackNameLabel, artistNameLabel)

        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            albumCoverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Values.paddingAlbumCoverImageLeadingDefault),
            albumCoverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Values.paddingAlbumCoverImageTopDefault),
            albumCoverImageView.widthAnchor.constraint(equalTo: contentView.heightAnchor, constant: -Constants.Values.paddingAlbumCoverImageDefault),
            albumCoverImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -Constants.Values.paddingAlbumCoverImageDefault),

            trackNameLabel.leadingAnchor.constraint(equalTo: albumCoverImageView.trailingAnchor, constant: Constants.Values.paddingLeadingDefault),
            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Values.paddingTrailingDefault),
            trackNameLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),

            artistNameLabel.leadingAnchor.constraint(equalTo: albumCoverImageView.trailingAnchor, constant: Constants.Values.paddingLeadingDefault),
            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor),
            artistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Values.paddingTrailingDefault),
            artistNameLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        trackNameLabel.text = nil
        artistNameLabel.text = nil
        albumCoverImageView.sd_cancelCurrentImageLoad()
        albumCoverImageView.image = nil
    }

    func configure(with viewModel: RecommendedTrackCellViewModel) {
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL)
    }
}
