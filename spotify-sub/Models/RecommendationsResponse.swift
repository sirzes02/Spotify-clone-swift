//
//  RecommendationsResponse.swift
//  spotify-sub
//
//  Created by Santiago Varela on 12/08/24.
//

import Foundation

struct RecommendationsResponse: Codable {
    let tracks: [AudioTrack]
}
