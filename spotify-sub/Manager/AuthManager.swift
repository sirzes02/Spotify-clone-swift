//
//  AuthManager.swift
//  spotify-sub
//
//  Created by Santiago Varela on 10/08/24.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()

    private var refreshingToken = false

    private enum Constants {
        static let clientID = "80f0d294116146f39c48bfb6a8fb8dea"
        static let clientSecret = "3c1d640da06a4f3ca437c6752be471b0"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://www.iosacademy.io/"
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }

    private init() {}

    public var signInURL: URL? {
        let base = "https://accounts.spotify.com/authorize"
        let query = "?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&state=12&show_dialog=TRUE"

        return URL(string: "\(base)\(query)")
    }

    var isSignedIn: Bool {
        accessToken != nil
    }

    private var accessToken: String? {
        UserDefaults.standard.string(forKey: "access_token")
    }

    private var refreshToken: String? {
        UserDefaults.standard.string(forKey: "refresh_token")
    }

    private var tokenExpirationDate: Date? {
        UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }

    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else { return false }
        return Date().addingTimeInterval(300) >= expirationDate // 5 minutes buffer
    }

    private var onRefreshBlocks = [(String) -> Void]()

    public func exchangeCodeForToken(code: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: Constants.tokenAPIURL) else { return }

        let request = createTokenRequest(url: url, grantType: "authorization_code", code: code)
        performTokenRequest(request, completion: completion)
    }

    public func withValidToken(completion: @escaping (String) -> Void) {
        guard !refreshingToken else {
            onRefreshBlocks.append(completion)
            return
        }

        if shouldRefreshToken {
            refreshIfNeeded { [weak self] success in
                if let token = self?.accessToken, success {
                    completion(token)
                }
            }
        } else if let token = accessToken {
            completion(token)
        }
    }

    public func refreshIfNeeded(completion: ((Bool) -> Void)?) {
        guard !refreshingToken, shouldRefreshToken, let refreshToken = refreshToken, let url = URL(string: Constants.tokenAPIURL) else {
            completion?(true)
            return
        }

        refreshingToken = true

        let request = createTokenRequest(url: url, grantType: "refresh_token", refreshToken: refreshToken)

        performTokenRequest(request) { [weak self] success in
            self?.refreshingToken = false

            if success {
                self?.onRefreshBlocks.forEach { $0(self?.accessToken ?? "") }
                self?.onRefreshBlocks.removeAll()
            }

            completion?(success)
        }
    }

    private func createTokenRequest(url: URL, grantType: String, code: String? = nil, refreshToken: String? = nil) -> URLRequest {
        var components = URLComponents()

        components.queryItems = [
            URLQueryItem(name: "grant_type", value: grantType),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
        ]

        if let code = code {
            components.queryItems?.append(URLQueryItem(name: "code", value: code))
        }

        if let refreshToken = refreshToken {
            components.queryItems?.append(URLQueryItem(name: "refresh_token", value: refreshToken))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)

        let basicToken = "\(Constants.clientID):\(Constants.clientSecret)"

        if let base64String = basicToken.data(using: .utf8)?.base64EncodedString() {
            request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    private func performTokenRequest(_ request: URLRequest, completion: @escaping (Bool) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }

            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: result)

                completion(true)
            } catch {
                print("Token decoding error: \(error.localizedDescription)")
                completion(false)
            }
        }
        task.resume()
    }

    private func cacheToken(result: AuthResponse) {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")

        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
        }

        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }

    public func signOut(completion: (Bool) -> Void) {
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        UserDefaults.standard.removeObject(forKey: "expirationDate")

        completion(true)
    }
}
