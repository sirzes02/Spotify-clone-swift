//
//  SettingModules.swift
//  spotify-sub
//
//  Created by Santiago Varela on 11/08/24.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
