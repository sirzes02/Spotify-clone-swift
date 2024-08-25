//
//  Artist.swift
//  spotify-sub
//
//  Created by Santiago Varela on 10/08/24.
//

import Foundation

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let images: [APIImage]?
    let external_urls: [String: String]
}
