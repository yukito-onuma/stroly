//
//  AlbumView.swift
//  stroly
//
//  Created by 大坪雄也 on 2023/12/12.
//

//import SwiftUI
//
//struct AlbumView: View {
//    var body: some View {
//        Text("World!")
//    }
//}
//
//#Preview {
//    AlbumView()
//}

import SwiftUI
import SwiftData

// sortの種類はenumで管理
enum SortType {
    case dateAscending
    case dateDescending
    case distanceAscending
    case distanceDescending
}

enum FilterType {
    case season
    case time
    case postStatus
    case all
}

struct AlbumView: View {
    private let decoSet = DecorationSettings()
    @Environment(\.modelContext) private var context
    @Query private var myPosts: [MyPosts]
    @Binding var isPostTapped: Bool
    @Binding var selectedPost: MyPosts?
    @Binding var selectedImage: UIImage?
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    @State private var sortType: SortType = .dateAscending
    @State private var filterType: FilterType = .all
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            // 写真一覧表示
            HStack {
                Spacer()
                    .frame(width: decoSet.sideWidth)
                Text("あなたの投稿一覧")
                    .foregroundColor(.black)
                Spacer()

                // 絞り込みボタン
                Menu {
                    Button(action: {
                        filterType = .all
                    }, label: {
                        Text("すべて")
                    })
                    Button(action: {
                        filterType = .season
                    }, label: {
                        Text("季節")
                    })
                    Button(action: {
                        filterType = .time
                    }, label: {
                        Text("時間")
                    })
                    Button(action: {
                        filterType = .postStatus
                    }, label: {
                        Text("投稿設定")
                    })
                } label: {
                    Image(systemName: "list.bullet")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: decoSet.buttonWidth, height: decoSet.buttonHeight)
                        .opacity(decoSet.opacity)
                }
                Spacer()
                    .frame(width: 16)
                
                // sortボタン
                Menu {
                    Button(action: {
                        sortType = .dateAscending
                    }, label: {
                        Text("新しい順")
                        Image(systemName: "arrow.down")
                    })
                    Button(action: {
                        sortType = .dateDescending
                    }, label: {
                        Text("古い順")
                        Image(systemName: "arrow.up")
                    })
                    Button(action: {
                        sortType = .distanceAscending
                    }, label: {
                        Text("ここから近い順")
                        Image(systemName: "arrow.up")
                    })
                    Button(action: {
                        sortType = .distanceDescending
                    }, label: {
                        Text("ここから遠い順")
                        Image(systemName: "arrow.down")
                    })
                } label: {
                    Image(systemName: "arrow.up.and.down.text.horizontal")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: decoSet.buttonWidth, height: decoSet.buttonHeight)
                        .opacity(decoSet.opacity)
                }
                Spacer()
                    .frame(width: decoSet.sideWidth)
            }
            Spacer()
            Divider()
                .foregroundColor(.gray)
            ScrollView {
                var columns: [GridItem] = Array(repeating: .init(.fixed(decoSet.screenWidth / 3)), count: 3)
                LazyVGrid(columns: columns) {
                    ForEach(myPosts, id: \.id) {post in
                        Button(action: {
                            isPostTapped = true
                            selectedPost = post
                            selectedImage = convertURLToImage(iconURL: documentsURL.appendingPathComponent(post.key))
                        }, label: {
                            if let image = convertURLToImage(iconURL: documentsURL.appendingPathComponent(post.key)) {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: decoSet.screenWidth / 3, height: decoSet.screenWidth / 3)
                                    .scaledToFill()
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                            }
                        })
                    }
                }
            }
        }
    }
}

