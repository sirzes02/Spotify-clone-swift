//
//  Playlist.swift
//  spotify-sub
//
//  Created by Santiago Varela on 10/08/24.
//

import Foundation

struct Playlist: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let owner: User
}
