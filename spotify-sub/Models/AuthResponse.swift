//
//  AuthResponse.swift
//  spotify-sub
//
//  Created by Santiago Varela on 10/08/24.
//

import Foundation

struct AuthResponse: Codable {
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
    let token_type: String
}
