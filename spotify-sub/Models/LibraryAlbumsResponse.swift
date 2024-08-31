//
//  LibraryAlbumsResponse.swift
//  spotify-sub
//
//  Created by Santiago Varela on 31/08/24.
//

import Foundation

struct LibraryAlbumsResponse: Codable {
    let items: [SavedAlbum]
}

struct SavedAlbum: Codable {
    let added_at: String
    let album: Album
}
