//
//  SearchResultSubtitleTableViewCell.swift
//  spotify-sub
//
//  Created by Santiago Varela on 24/08/24.
//

import SDWebImage
import UIKit

class SearchResultSubtitleTableViewCell: UITableViewCell {
    static let identifier = "SearchResultSubtitleTableViewCell"

    enum Constants {
        enum Values {
            static let paddingLeadingDefault: CGFloat = 10
            static let paddingTrailingDefault: CGFloat = 15
            static let paddingVerticalDefault: CGFloat = 5
            static let paddingSubtitleLabelBottomDefault: CGFloat = 2
            static let imageSizeDefault: CGFloat = 50
        }
    }

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true

        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubviews(label, subtitleLabel, iconImageView)
        accessoryType = .disclosureIndicator

        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Values.paddingLeadingDefault),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.Values.imageSizeDefault),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.Values.imageSizeDefault),

            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Constants.Values.paddingLeadingDefault),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Values.paddingTrailingDefault),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Values.paddingVerticalDefault),

            subtitleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Constants.Values.paddingLeadingDefault),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Values.paddingTrailingDefault),
            subtitleLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Constants.Values.paddingSubtitleLabelBottomDefault),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Values.paddingVerticalDefault),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        iconImageView.sd_cancelCurrentImageLoad()
        iconImageView.image = nil
        label.text = nil
        subtitleLabel.text = nil
    }

    func configure(with viewModel: SearchResultSubtitleTableViewCellViewModel) {
        label.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        iconImageView.sd_setImage(with: viewModel.imageURL, placeholderImage: UIImage(systemName: "photo"))
    }
}
