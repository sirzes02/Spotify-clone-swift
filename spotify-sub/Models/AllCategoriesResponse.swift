//
//  AllCategoriesResponse.swift
//  spotify-sub
//
//  Created by Santiago Varela on 24/08/24.
//

import Foundation

struct AllCategoriesResponse: Codable {
    let categories: Categories
}

struct Categories: Codable {
    let items: [Category]
}

struct Category: Codable {
    let id: String
    let name: String
    let icons: [APIImage]
}
