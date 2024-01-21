//
//  Friends.swift
//  stroly
//
//  Created by 長濱聖英 on 2024/01/18.
//

import Foundation
import SwiftData

@Model
final class Friends {
    let friendId: String
    var userName: String
    var iconKey: String
    init(friendId: String, userName: String, iconKey: String) {
        self.friendId = friendId
        self.userName = userName
        self.iconKey = iconKey
    }
}

