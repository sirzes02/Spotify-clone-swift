//
//  AlbumTrackCollectionViewCell.swift
//  spotify-sub
//
//  Created by Santiago Varela on 18/08/24.
//

import UIKit

class AlbumTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "AlbumTrackCollectionViewCell"

    enum Constants {
        enum Values {
            static let paddingDefault: CGFloat = 10
            static let paddingTrackNameLabelHeightDefault: CGFloat = 15
            static let paddingTrackNameLabelBottomDefault: CGFloat = 5
            static let fontSizeRegular: CGFloat = 18
            static let fontSizeThin: CGFloat = 15
        }
    }

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

        backgroundColor = .secondarySystemBackground
        addSubviews(trackNameLabel, artistNameLabel)

        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Values.paddingDefault),
            trackNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Values.paddingDefault),
            trackNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Values.paddingDefault),
            trackNameLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5, constant: -Constants.Values.paddingTrackNameLabelHeightDefault),

            artistNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Values.paddingDefault),
            artistNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Values.paddingDefault),
            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: Constants.Values.paddingTrackNameLabelBottomDefault),
            artistNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.Values.paddingDefault),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }

    func configure(with viewModel: AlbumCollectionViewCellViewModel) {
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
}
