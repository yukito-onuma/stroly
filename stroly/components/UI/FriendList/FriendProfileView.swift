//
//  FriendProfileView.swift
//  stroly
//
//  Created by 大坪雄也 on 2024/01/12.
//

import SwiftUI

struct FriendProfileView: View {
    var friend: Friend
    var deco = DecorationSettings()
    @State var isAlbumButtonTapped = false
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 70)
            if let icon = friend.icon {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1.0) // 1.0やそれ以下の値に調整
                    )
                    .frame(width: deco.iconWidth, height: deco.iconHeight)
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1.0) // 1.0やそれ以下の値に調整
                    )
                    .frame(width: deco.iconWidth, height: deco.iconHeight)
            }
            VStack {
                HStack {
                    Spacer()
                        .frame(width: deco.sideWidth)
                    Text("ユーザーネーム")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                Spacer()
                    .frame(height: deco.heightBetweenString)
                HStack {
                    Spacer()
                        .frame(width: deco.sideWidth)
                    Text(friend.userName)
                    Spacer()
                }
            }
            Spacer()
        }
    }
}
