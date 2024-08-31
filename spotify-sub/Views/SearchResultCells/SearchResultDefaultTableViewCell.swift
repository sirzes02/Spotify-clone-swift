//
//  SearchResultDefaultTableViewCell.swift
//  spotify-sub
//
//  Created by Santiago Varela on 24/08/24.
//

import SDWebImage
import UIKit

class SearchResultDefaultTableViewCell: UITableViewCell {
    static let identifier = "SearchResultDefaultTableViewCell"

    enum Constants {
        enum Values {
            static let paddingDefault: CGFloat = 10
            static let imageSizeDefault: CGFloat = 40
        }
    }

    // MARK: - Subviews

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubviews(label, iconImageView)
        accessoryType = .disclosureIndicator
        clipsToBounds = true

        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Values.paddingDefault),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.Values.imageSizeDefault),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.Values.imageSizeDefault),

            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Constants.Values.paddingDefault),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Values.paddingDefault),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])

        iconImageView.layer.cornerRadius = Constants.Values.imageSizeDefault / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        iconImageView.sd_cancelCurrentImageLoad()
        iconImageView.image = nil
        label.text = nil
    }

    // MARK: - Configuration

    func configure(with viewModel: SearchResultDefaultTableViewCellViewModel) {
        label.text = viewModel.title
        iconImageView.sd_setImage(with: viewModel.imageURL, placeholderImage: UIImage(systemName: "photo"))
    }
}
