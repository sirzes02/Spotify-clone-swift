//
//  AlbumViewController.swift
//  spotify-sub
//
//  Created by Santiago Varela on 17/08/24.
//

import UIKit

class AlbumViewController: UIViewController {
    private let album: Album
    
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        view.backgroundColor = .systemBackground
        
        APICaller.shared.getAlbumDetails(for: album) { result in
            DispatchQueue.main.sync {
                switch result {
                case .success(let success):
                    break
                case .failure(let failure):
                    break
                }
            }
        }
    }
}
