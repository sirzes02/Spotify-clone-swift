//
//  PlayerViewController.swift
//  spotify-sub
//
//  Created by Santiago Varela on 10/08/24.
//

import SDWebImage
import UIKit

protocol PlayerViewControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapNext()
    func didTapBack()
    func didSlideSlider(_ value: Float)
}

class PlayerViewController: UIViewController {
    weak var dataSource: PlayerDataSource?
    weak var delegate: PlayerViewControllerDelegate?

    enum Constants {
        enum Values {
            static let paddingDefault: CGFloat = 10
        }
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let controlsView: PlayerControlsView = {
        let controlsView = PlayerControlsView()
        controlsView.translatesAutoresizingMaskIntoConstraints = false

        return controlsView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        controlsView.delegate = self

        view.addSubview(imageView)
        view.addSubview(controlsView)

        setUpConstraints()
        configureBarButtons()
        configure()
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: view.widthAnchor),

            controlsView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.Values.paddingDefault),
            controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Values.paddingDefault),
            controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Values.paddingDefault),
            controlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Values.paddingDefault),
        ])
    }

    private func configure() {
        if let imageURL = dataSource?.imageURL {
            imageView.sd_setImage(with: imageURL)
        }
        controlsView.configure(with: PlayerControlsViewViewModel(
            title: dataSource?.songName,
            subtitle: dataSource?.subtitle
        ))
    }

    private func configureBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapAction)
        )
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    @objc private func didTapAction() {}

    func refreshUI() {
        configure()
    }
}

// MARK: - PlayerControlsViewDelegate

extension PlayerViewController: PlayerControlsViewDelegate {
    func playerControlsViewDidTapPlayPauseButton(_: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }

    func playerControlsViewDidTapNextButton(_: PlayerControlsView) {
        delegate?.didTapNext()
    }

    func playerControlsViewDidTapBackButton(_: PlayerControlsView) {
        delegate?.didTapBack()
    }

    func playerControlsView(_: PlayerControlsView, didSlideSlider value: Float) {
        delegate?.didSlideSlider(value)
    }
}
