//
//  MyPostView.swift
//  stroly
//
//  Created by 大坪雄也 on 2024/01/17.
//

import SwiftUI

struct MyPostView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingAlert = false
    @Binding var post: MyPosts?
    @Binding var postImage: UIImage?
    
    var body: some View {
        if let post = post {
            ScrollView {
                // VStackを以下の書き方すると左揃えできる便利！
                VStack(alignment: .leading, spacing: 10) {
                    Spacer()
                    HStack{
                        Image(systemName:"circle.fill")
                            .foregroundColor(.red)
                            .font(.largeTitle)
                        VStack (alignment: .leading, spacing: 0){
                            Text("@\(post.userName)")
                                .font(.headline)
                            Text("\(formattedDate(from: post.createdAt))")
                                .font(.caption)
                        }
                        Spacer()
                        Menu {
                            Button(action: {
                                showingAlert = true
                                print("Deleteボタンが押されました")
                            }) {
                                Text("削除する")
                                    .font(.headline)
                                    .background(Color.pink)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        } label: {
                            Image(systemName:"ellipsis")
                                .padding()
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("確認"),
                                message: Text("本当に削除しますか？"),
                                primaryButton: .destructive(Text("削除")) {
                                    // 削除処理
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .imageScale(.small)
                                .foregroundColor(.white)
                        }
                        .frame(width: 30, height: 30)  // ボタンのサイズを設定
                        .background(Color.gray)  // ボタンの背景色
                        .clipShape(Circle())  // ボタンを丸形にする
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 2)  // ボタンの枠線
                        )
                    }
                    if let image = postImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                    }
                    Text("\(post.title )")
                        .font(.headline)
                }
                .background(Color.white)
                .padding(.horizontal)
                .padding(.bottom, 5)
            }
        }
    }
    // ISO8601の日付文字列から月、日、時間を抽出する関数
    func formattedDate(from isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime] // 時間も含めるためのオプション
        if let date = isoFormatter.date(from: isoDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM月dd日HH時mm分" // 日付と時間のフォーマット
            return dateFormatter.string(from: date)
        } else {
            return "日付不明"
        }
    }
}
