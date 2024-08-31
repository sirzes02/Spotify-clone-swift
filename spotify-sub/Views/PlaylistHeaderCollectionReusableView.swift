//
//  PlaylistHeaderCollectionReusableView.swift
//  spotify-sub
//
//  Created by Santiago Varela on 18/08/24.
//

import UIKit

protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject {
    func playlistHeaderCollectionReusableViewDidTapAll(_ header: PlaylistHeaderCollectionReusableView)
}

final class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "PlaylistHeaderCollectionReusableView"

    enum Constants {
        enum Values {
            static let paddingDefault: CGFloat = 10
            static let paddingHeightDefault: CGFloat = 44
            static let paddingVerticalDefault: CGFloat = 44
            static let playAllButtonSizeDefault: CGFloat = 60
            static let fontSizeSemibold: CGFloat = 22
            static let fontSizeRegularLight: CGFloat = 18
            static let imageRadius: CGFloat = 4
        }
    }

    weak var delegate: PlaylistHeaderCollectionReusableViewDelegate?

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Values.fontSizeSemibold, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Values.fontSizeRegularLight, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Values.fontSizeRegularLight, weight: .light)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo")
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = Constants.Values.imageRadius
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let playAllButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen

        let image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemBackground
        addSubviews(imageView, ownerLabel, descriptionLabel, nameLabel, playAllButton)

        playAllButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)

        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    @objc private func didTapPlayAll() {
        delegate?.playlistHeaderCollectionReusableViewDidTapAll(self)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Values.paddingVerticalDefault),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1 / 1.75),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Values.paddingDefault),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Values.paddingDefault),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: Constants.Values.paddingHeightDefault),

            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Values.paddingDefault),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Values.paddingDefault),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            descriptionLabel.heightAnchor.constraint(equalToConstant: Constants.Values.paddingHeightDefault),

            ownerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Values.paddingDefault),
            ownerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Values.paddingDefault),
            ownerLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            ownerLabel.heightAnchor.constraint(equalToConstant: Constants.Values.paddingHeightDefault),

            playAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Values.paddingVerticalDefault),
            playAllButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            playAllButton.widthAnchor.constraint(equalToConstant: Constants.Values.playAllButtonSizeDefault),
            playAllButton.heightAnchor.constraint(equalToConstant: Constants.Values.playAllButtonSizeDefault),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.sd_cancelCurrentImageLoad()
        imageView.image = nil
        nameLabel.text = nil
        descriptionLabel.text = nil
        ownerLabel.text = nil
    }

    func configure(with viewModel: PlaylistHeaderViewViewModel) {
        nameLabel.text = viewModel.name
        ownerLabel.text = viewModel.ownerName
        descriptionLabel.text = viewModel.description
        imageView.sd_setImage(with: viewModel.artworkURL, placeholderImage: UIImage(systemName: "photo"))
    }
}
