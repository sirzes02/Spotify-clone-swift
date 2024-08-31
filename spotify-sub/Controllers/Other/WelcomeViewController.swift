//
//  WelcomeViewController.swift
//  spotify-sub
//
//  Created by Santiago Varela on 10/08/24.
//

import UIKit

class WelcomeViewController: UIViewController {
    enum Constants {
        enum Values {
            static let overlayViewAlpha: CGFloat = 0.7
            static let fontSizeDefault: CGFloat = 32
            static let logoImageSize: CGFloat = 120
            static let logoImageCenterY: CGFloat = 100
            static let labelPadding: CGFloat = 30
            static let SignInButtonPadding: CGFloat = 20
            static let SignInButtonHeight: CGFloat = 50
        }

        enum Labels {
            static let singIn = "Sign In with Spotify"
            static let title = "Spotify"
            static let description = "Listen to millions\nof Songs on\nthe go."
            static let oops = "Oops"
            static let somethingWrong = "Something went wrong when signing in."
            static let dissmiss = "Dissmis"
        }
    }

    private lazy var signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle(Constants.Labels.singIn, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)

        return button
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "albums_background"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = Constants.Values.overlayViewAlpha
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Values.fontSizeDefault, weight: .semibold)
        label.text = Constants.Labels.description
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Constants.Labels.title
        view.addSubviews(imageView, overlayView, logoImageView, label, signInButton)

        setUpConstraints()
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -Constants.Values.logoImageCenterY),
            logoImageView.widthAnchor.constraint(equalToConstant: Constants.Values.logoImageSize),
            logoImageView.heightAnchor.constraint(equalToConstant: Constants.Values.logoImageSize),

            label.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: Constants.Values.labelPadding),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Values.labelPadding),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Values.labelPadding),

            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Values.SignInButtonPadding),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Values.SignInButtonPadding),
            signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Values.SignInButtonPadding),
            signInButton.heightAnchor.constraint(equalToConstant: Constants.Values.SignInButtonHeight),
        ])
    }

    @objc private func didTapSignIn() {
        let vc = AuthViewController()
        vc.completionHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
            }
        }

        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    private func handleSignIn(success: Bool) {
        guard success else {
            let alert = UIAlertController(title: Constants.Labels.oops, message: Constants.Labels.somethingWrong, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.Labels.dissmiss, style: .cancel))

            present(alert, animated: true)

            return
        }
        let mainAppTabVC = TabBarViewController()
        mainAppTabVC.modalPresentationStyle = .fullScreen

        present(mainAppTabVC, animated: true)
    }
}
