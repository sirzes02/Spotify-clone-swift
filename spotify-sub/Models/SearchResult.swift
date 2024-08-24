//
//  SearchResult.swift
//  spotify-sub
//
//  Created by Santiago Varela on 24/08/24.
//

import Foundation

enum SearchResult {
    case artist(model: Artist)
    case album(model: Album)
    case track(model: AudioTrack)
    case playlist(model: Playlist)
}
