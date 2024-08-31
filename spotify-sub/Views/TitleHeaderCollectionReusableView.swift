//
//  TitleHeaderCollectionReusableView.swift
//  spotify-sub
//
//  Created by Santiago Varela on 18/08/24.
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "TitleHeaderCollectionReusableView"

    enum Constants {
        enum Values {
            static let paddingDefault: CGFloat = 15
            static let fontSizeDefault: CGFloat = 22
        }
    }

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: Constants.Values.fontSizeDefault, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemBackground
        addSubview(label)

        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Values.paddingDefault),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Values.paddingDefault),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        label.text = nil
    }

    func configure(with title: String) {
        label.text = title
    }
}
