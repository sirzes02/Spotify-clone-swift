//
//  FeaturedPlaylistsCollectionViewCell.swift
//  spotify-sub
//
//  Created by Santiago Varela on 16/08/24.
//

import UIKit

class FeaturedPlaylistsCollectionViewCell: UICollectionViewCell {
    static let identifier = "FeaturedPlaylistsCollectionViewCell"

    enum Constants {
        enum Values {
            static let paddingDefault: CGFloat = 5
            static let paddingPlaylistNameLabelBottomDefault: CGFloat = 2
            static let paddingHeightDefault: CGFloat = 30
            static let imageSizeReducer: CGFloat = 70
            static let fontSizeRegular: CGFloat = 18
            static let fontSizeThin: CGFloat = 15
            static let imageRadius: CGFloat = 4
        }
    }

    private let playlistCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = Constants.Values.imageRadius
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Values.fontSizeRegular, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let creatorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Values.fontSizeThin, weight: .thin)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubviews(playlistCoverImageView, playlistNameLabel, creatorNameLabel)

        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setupConstraints() {
        let imageSize = height - Constants.Values.imageSizeReducer

        NSLayoutConstraint.activate([
            playlistCoverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Values.paddingDefault),
            playlistCoverImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            playlistCoverImageView.widthAnchor.constraint(equalToConstant: imageSize),
            playlistCoverImageView.heightAnchor.constraint(equalToConstant: imageSize),

            playlistNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Values.paddingDefault),
            playlistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Values.paddingDefault),
            playlistNameLabel.bottomAnchor.constraint(equalTo: creatorNameLabel.topAnchor, constant: -Constants.Values.paddingPlaylistNameLabelBottomDefault),
            playlistNameLabel.heightAnchor.constraint(equalToConstant: Constants.Values.paddingHeightDefault),

            creatorNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Values.paddingDefault),
            creatorNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Values.paddingDefault),
            creatorNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Values.paddingDefault),
            creatorNameLabel.heightAnchor.constraint(equalToConstant: Constants.Values.paddingHeightDefault),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        playlistNameLabel.text = nil
        creatorNameLabel.text = nil
        playlistCoverImageView.sd_cancelCurrentImageLoad()
        playlistCoverImageView.image = nil
    }

    func configure(with viewModel: FeaturedPlaylistCellViewModel) {
        playlistNameLabel.text = viewModel.name
        creatorNameLabel.text = viewModel.creatorName
        playlistCoverImageView.sd_setImage(with: viewModel.artworkURL)
    }
}
