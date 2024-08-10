//
//  AuthManager.swift
//  spotify-sub
//
//  Created by Santiago Varela on 10/08/24.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    struct Constans {
        static let clientID = "80f0d294116146f39c48bfb6a8fb8dea"
        static let clientSecret = "3c1d640da06a4f3ca437c6752be471b0"
    }
    
    private init() {
        
    }
    
    public var signInURL: URL? {
        let scopes = "user-read-private"
        let redirectURI = "https://www.iosacademy.io/"
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constans.clientID)&scope=\(scopes)&redirect_uri=\(redirectURI)&state=12&show_dialog=TRUE"
        
        return URL(string: string )
    }
    
    var isSignedIn: Bool {
        return false
    }
    
    private var accessToken: String? {
        return nil
    }
    
    private var refreshToken: String? {
        return nil
    }
    
    private var tokenExpirationDate: Date? {
        return nil
    }
    
    private var shouldRefreshToken: Bool {
        return false
    }
    
    public func exchangeCodeForToken(code: String, completion: @escaping((Bool) -> Void)) {
        // Get Token
    }
    
    public func refreshAcessToken() {
        
    }
    
    private func cacheToke() {
        
    }
}
