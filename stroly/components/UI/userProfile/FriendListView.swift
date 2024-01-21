//
//  FriendListView.swift
//  stroly
//
//  Created by 大坪雄也 on 2023/12/12.
//

import SwiftUI

struct FriendListView: View {
    @State private var isPushed = false
    @State private var friends = ["Aさん", "Bさん", "Cさん"]
    @State private var isScanButtonTapped = false
    @State private var isGenQRButtonTapped = false
    @State private var qrimage: UIImage?
    
        var body: some View {
            VStack {
                List {
                    ForEach(friends, id: \.self) {friend in
                        //左にスワイプしたら削除できるような、Listの要素を作りたい
                        Text(friend)
                            .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: delete)
                }
                .scrollContentBackground(.hidden)
            }
        }
    func delete (at offsets: IndexSet) {
        friends.remove(atOffsets: offsets)
    }
}

#Preview {
    FriendListView()
}
