//
//  PlayerControlsView.swift
//  spotify-sub
//
//  Created by Santiago Varela on 24/08/24.
//

import Foundation
import UIKit

protocol PlayerControlsViewDelegate: AnyObject {
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapNextButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapBackButton(_ playerControlsView: PlayerControlsView)
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float)
}

struct PlayerControlsViewViewModel {
    let title: String?
    let subtitle: String?
}

final class PlayerControlsView: UIView {
    weak var delegate: PlayerControlsViewDelegate?

    enum Constants {
        enum Values {
            static let volumeDefault: Float = 0.5
            static let fontSizeSemibold: CGFloat = 20
            static let fontSizeRegular: CGFloat = 18
            static let imagePointSizeDefault: CGFloat = 34
            static let buttonSizeDefault: CGFloat = 60
            static let backNextPadding: CGFloat = 80
            static let defaultPadding: CGFloat = 10
            static let defaultHeightPadding: CGFloat = 50
            static let playPauseButtonTopPadding: CGFloat = 30
            static let VolumeSliderHeightPadding: CGFloat = 44
            static let VolumeSliderTopPadding: CGFloat = 20
        }
    }

    private var isPlaying = true

    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = Constants.Values.volumeDefault
        slider.translatesAutoresizingMaskIntoConstraints = false

        return slider
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: Constants.Values.fontSizeSemibold, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: Constants.Values.fontSizeRegular, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let backButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label

        let image = UIImage(
            systemName: "backward.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: Constants.Values.imagePointSizeDefault, weight: .regular)
        )
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label

        let image = UIImage(
            systemName: "forward.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: Constants.Values.imagePointSizeDefault, weight: .regular)
        )
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label

        let image = UIImage(
            systemName: "pause",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: Constants.Values.imagePointSizeDefault, weight: .regular)
        )
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        addSubviews(nameLabel, subtitleLabel, volumeSlider, backButton, nextButton, playPauseButton)

        volumeSlider.addTarget(self, action: #selector(didSlideSlider(_:)), for: .valueChanged)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)

        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: Constants.Values.defaultHeightPadding),

            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.Values.defaultPadding),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitleLabel.heightAnchor.constraint(equalToConstant: Constants.Values.defaultHeightPadding),

            volumeSlider.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Constants.Values.VolumeSliderTopPadding),
            volumeSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Values.defaultPadding),
            volumeSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Values.defaultPadding),
            volumeSlider.heightAnchor.constraint(equalToConstant: Constants.Values.VolumeSliderHeightPadding),

            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.topAnchor.constraint(equalTo: volumeSlider.bottomAnchor, constant: Constants.Values.playPauseButtonTopPadding),
            playPauseButton.widthAnchor.constraint(equalToConstant: Constants.Values.buttonSizeDefault),
            playPauseButton.heightAnchor.constraint(equalToConstant: Constants.Values.buttonSizeDefault),

            backButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -Constants.Values.backNextPadding),
            backButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: Constants.Values.buttonSizeDefault),
            backButton.heightAnchor.constraint(equalToConstant: Constants.Values.buttonSizeDefault),

            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: Constants.Values.backNextPadding),
            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: Constants.Values.buttonSizeDefault),
            nextButton.heightAnchor.constraint(equalToConstant: Constants.Values.buttonSizeDefault),
        ])
    }

    @objc private func didSlideSlider(_ slider: UISlider) {
        let value = slider.value
        delegate?.playerControlsView(self, didSlideSlider: value)
    }

    @objc private func didTapBack() {
        delegate?.playerControlsViewDidTapBackButton(self)
    }

    @objc private func didTapNext() {
        delegate?.playerControlsViewDidTapNextButton(self)
    }

    @objc private func didTapPlayPause() {
        isPlaying = !isPlaying
        delegate?.playerControlsViewDidTapPlayPauseButton(self)

        let pause = UIImage(
            systemName: "pause",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: Constants.Values.imagePointSizeDefault, weight: .regular)
        )
        let play = UIImage(
            systemName: "play.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: Constants.Values.imagePointSizeDefault, weight: .regular)
        )
        playPauseButton.setImage(isPlaying ? pause : play, for: .normal)
    }

    func configure(with viewModel: PlayerControlsViewViewModel) {
        nameLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }
}
