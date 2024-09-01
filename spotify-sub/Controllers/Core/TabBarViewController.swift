//
//  TabBarViewController.swift
//  spotify-sub
//
//  Created by Santiago Varela on 10/08/24.
//

import UIKit

class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
    }

    private func configureViewControllers() {
        let homeVC = createNavController(for: HomeViewController(), title: "Home", image: UIImage(systemName: "house"))
        let searchVC = createNavController(for: SearchViewController(), title: "Search", image: UIImage(systemName: "magnifyingglass"))
        let libraryVC = createNavController(for: LibraryViewController(), title: "Library", image: UIImage(systemName: "music.note.list"))

        setViewControllers([homeVC, searchVC, libraryVC], animated: true)
    }

    private func createNavController(for rootViewController: UIViewController, title: String, image: UIImage?) -> UINavigationController {
        rootViewController.title = title
        rootViewController.navigationItem.largeTitleDisplayMode = .always

        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem = UITabBarItem(title: title, image: image, tag: 1)
        navController.navigationBar.prefersLargeTitles = true
        navController.navigationBar.tintColor = .label

        return navController
    }
}
