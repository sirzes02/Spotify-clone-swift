//
//  GenreCollectionViewCell.swift
//  spotify-sub
//
//  Created by Santiago Varela on 18/08/24.
//

import SDWebImage
import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "CategoryCollectionViewCell"

    enum Constants {
        enum Values {
            static let paddingDefault: CGFloat = 10
            static let fontSizeDefault: CGFloat = 22
            static let imageViewPointSize: CGFloat = 50
        }
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(
            systemName: "music.quarternote.3",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: Constants.Values.imageViewPointSize,
                weight: .regular
            )
        )
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Values.fontSizeDefault, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let colors: [UIColor] = [
        .systemPink,
        .systemBlue,
        .systemPurple,
        .systemOrange,
        .systemGreen,
        .systemRed,
        .systemYellow,
        .systemGray,
        .systemTeal,
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 8
        layer.masksToBounds = true

        backgroundColor = colors.randomElement()
        addSubviews(imageView, label)

        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Values.paddingDefault),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5, constant: -Constants.Values.paddingDefault),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5, constant: -Constants.Values.paddingDefault),

            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Values.paddingDefault),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Values.paddingDefault),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.Values.paddingDefault),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.Values.paddingDefault),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        label.text = nil
        imageView.image = UIImage(
            systemName: "music.quarternote.3",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: Constants.Values.imageViewPointSize,
                weight: .regular
            )
        )
        backgroundColor = colors.randomElement()
    }

    func configure(with viewModel: CategoryCollectionViewCellViewModel) {
        label.text = viewModel.title
        imageView.sd_setImage(with: viewModel.artworkURL)
    }
}
