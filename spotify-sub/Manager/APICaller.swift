//
//  APICaller.swift
//  spotify-sub
//
//  Created by Santiago Varela on 10/08/24.
//

import Foundation

final class APICaller {
    static let shared = APICaller()

    private init() {}

    enum Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }

    enum APIError: Error {
        case failedToGetData
    }

    // Generic function to perform API request and handle response decoding
    private func performRequest<T: Decodable>(
        url: URL?,
        httpMethod: HTTPMethod,
        responseType _: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        createRequest(with: url, type: httpMethod) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    // Generic function to handle API requests where the response is a simple Bool
    private func performSimpleRequest(
        url: URL?,
        httpMethod: HTTPMethod,
        httpBody: Data? = nil,
        completion: @escaping (Bool) -> Void
    ) {
        createRequest(with: url, type: httpMethod) { baseRequest in
            var request = baseRequest
            request.httpBody = httpBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                let success = (response as? HTTPURLResponse)?.statusCode == 200
                completion(success && error == nil)
            }
            task.resume()
        }
    }

    // MARK: - Albums

    public func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetailsResponse, Error>) -> Void) {
        let url = URL(string: Constants.baseAPIURL + "/albums/" + album.id)

        performRequest(url: url, httpMethod: .GET, responseType: AlbumDetailsResponse.self, completion: completion)
    }

    public func getCurrentUserAlbums(completion: @escaping (Result<[Album], Error>) -> Void) {
        let url = URL(string: Constants.baseAPIURL + "/me/albums")

        performRequest(url: url, httpMethod: .GET, responseType: LibraryAlbumsResponse.self) { result in
            switch result {
            case let .success(response):
                completion(.success(response.items.compactMap { $0.album }))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func saveAlbum(album: Album, completion: @escaping (Bool) -> Void) {
        let url = URL(string: Constants.baseAPIURL + "/me/albums?ids=\(album.id)")

        performSimpleRequest(url: url, httpMethod: .PUT, completion: completion)
    }

    // MARK: - Playlists

    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping (Result<PlaylistDetailsResponse, Error>) -> Void) {
        let url = URL(string: Constants.baseAPIURL + "/playlists/" + playlist.id)

        performRequest(url: url, httpMethod: .GET, responseType: PlaylistDetailsResponse.self, completion: completion)
    }

    public func getCurrentUserPlaylists(completion: @escaping (Result<[Playlist], Error>) -> Void) {
        let url = URL(string: Constants.baseAPIURL + "/me/playlists")

        performRequest(url: url, httpMethod: .GET, responseType: LibraryPlaylistsResponse.self) { result in
            switch result {
            case let .success(response):
                completion(.success(response.items))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func createPlaylist(with name: String, completion: @escaping (Bool) -> Void) {
        getCurrentUserProfile { [weak self] result in
            switch result {
            case let .success(profile):
                let url = URL(string: Constants.baseAPIURL + "/users/\(profile.id)/playlists")
                let json = ["name": name]
                let body = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)

                self?.performSimpleRequest(url: url, httpMethod: .POST, httpBody: body, completion: completion)
            case .failure:
                completion(false)
            }
        }
    }

    public func addTrackToPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void) {
        let url = URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks")
        let json = ["uris": ["spotify:track:\(track.id)"]]
        let body = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)

        performSimpleRequest(url: url, httpMethod: .POST, httpBody: body, completion: completion)
    }

    public func removeTrackToPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void) {
        let url = URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks")
        let json = ["tracks": [["uri": "spotify:track:\(track.id)"]]]
        let body = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)

        performSimpleRequest(url: url, httpMethod: .DELETE, httpBody: body, completion: completion)
    }

    // MARK: - Profile

    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        let url = URL(string: Constants.baseAPIURL + "/me")

        performRequest(url: url, httpMethod: .GET, responseType: UserProfile.self, completion: completion)
    }

    // MARK: - Browse

    public func getNewReleases(completion: @escaping (Result<NewReleasesResponse, Error>) -> Void) {
        let url = URL(string: Constants.baseAPIURL + "/browse/new-releases?limit=50")

        performRequest(url: url, httpMethod: .GET, responseType: NewReleasesResponse.self, completion: completion)
    }

    public func getFeaturedPlaylists(completion: @escaping (Result<FeaturedPlaylistsResponse, Error>) -> Void) {
        let url = URL(string: Constants.baseAPIURL + "/browse/featured-playlists?limit=20")

        performRequest(url: url, httpMethod: .GET, responseType: FeaturedPlaylistsResponse.self, completion: completion)
    }

    public func getRecommendations(genres: Set<String>, completion: @escaping (Result<RecommendationsResponse, Error>) -> Void) {
        let seeds = genres.joined(separator: ",")
        let url = URL(string: Constants.baseAPIURL + "/recommendations?seed_genres=\(seeds)&limit=40")

        performRequest(url: url, httpMethod: .GET, responseType: RecommendationsResponse.self, completion: completion)
    }

    public func getRecommendedGenres(completion: @escaping (Result<RecommendedGenresResponse, Error>) -> Void) {
        let url = URL(string: Constants.baseAPIURL + "/recommendations/available-genre-seeds")

        performRequest(url: url, httpMethod: .GET, responseType: RecommendedGenresResponse.self, completion: completion)
    }

    public func getCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        let url = URL(string: Constants.baseAPIURL + "/browse/categories?limit=50")

        performRequest(url: url, httpMethod: .GET, responseType: AllCategoriesResponse.self) { result in
            switch result {
            case let .success(response):
                completion(.success(response.categories.items))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func getCategoryPlaylist(category: Category, completion: @escaping (Result<[Playlist], Error>) -> Void) {
        let url = URL(string: Constants.baseAPIURL + "/browse/categories/\(category.id)/playlists?limit=50")

        performRequest(url: url, httpMethod: .GET, responseType: CategoryPlaylistsResponse.self) { result in
            switch result {
            case let .success(response):
                completion(.success(response.playlists.items))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Search

    public func search(with query: String, completion: @escaping (Result<[SearchResult], Error>) -> Void) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: Constants.baseAPIURL + "/search?limit=10&type=album,artist,playlist,track&q=\(encodedQuery)")

        performRequest(url: url, httpMethod: .GET, responseType: SearchResultResponse.self) { result in
            switch result {
            case let .success(response):
                var searchResults: [SearchResult] = []
                searchResults.append(contentsOf: response.tracks.items.compactMap { .track(model: $0) })
                searchResults.append(contentsOf: response.albums.items.compactMap { .album(model: $0) })
                searchResults.append(contentsOf: response.playlists.items.compactMap { .playlist(model: $0) })
                searchResults.append(contentsOf: response.artists.items.compactMap { .artist(model: $0) })

                completion(.success(searchResults))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private Helpers

    enum HTTPMethod: String {
        case GET, POST, DELETE, PUT
    }

    private func createRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) -> Void
    ) {
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else {
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30

            completion(request)
        }
    }
}
