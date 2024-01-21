//
//  SettingView.swift
//  stroly
//
//  Created by 大坪雄也 on 2024/01/17.
//

import SwiftUI
import SwiftData

struct SettingView: View {
    
    private let decoSet = DecorationSettings()
    
    @State private var userName = UserDefaults.standard.string(forKey: "name") ?? "ユーザー名"
    @State private var mail = UserDefaults.standard.string(forKey: "email") ?? "メールアドレス"
    
    @State private var isShowingAlert = false
    @State private var isNameChangeTapped = false
    @State private var isMailChangeTapped = false
    @State private var newUserName = ""
    @State private var newMail = ""
    
    @AppStorage("isLogined") var isLogined = UserDefaults.standard.bool(forKey: "isLogined")
    @Environment(\.modelContext) private var context
    @Query private var myPosts: [MyPosts]
    
    var body: some View {
        VStack {
            
            Spacer()
                .frame(height: 20)
            //ユーザーネームの行
            VStack {
                HStack {
                    Spacer()
                        .frame(width: decoSet.sideWidth)
                    Text("ユーザーネーム")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                Spacer()
                    .frame(height: decoSet.heightBetweenString)
                HStack {
                    Spacer()
                        .frame(width: decoSet.sideWidth)
                    if !isNameChangeTapped {
                        Text(userName)
                    } else {
                        TextField(userName + "(ここに入力)", text: $newUserName)
                    }
                    Spacer()
                    Button(action: {
                        if isNameChangeTapped {
                            if newUserName != "" {
                                userName = newUserName
                                newUserName = ""
                            }
                        }
                        isNameChangeTapped.toggle()
                    }, label: {
                        if !isNameChangeTapped {
                            Text("変更")
                        } else {
                            Text("更新")
                        }
                        Spacer()
                            .frame(width: decoSet.sideWidth)
                        
                    })
                }
            }
            
            //メールの行
            HStack {
                Spacer()
                    .frame(width: decoSet.lineWidth)
                Rectangle()
                    .frame(height: decoSet.rectangleHeight)
                    .foregroundColor(.gray.opacity(decoSet.opacity))
                Spacer()
                    .frame(width: decoSet.lineWidth)
            }
            VStack {
                HStack {
                    Spacer()
                        .frame(width: decoSet.sideWidth)
                    Text("メールアドレス")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                Spacer()
                    .frame(height: decoSet.heightBetweenString)
                HStack {
                    Spacer()
                        .frame(width: decoSet.sideWidth)
                    if !isMailChangeTapped {
                        Text(mail)
                    } else {
                        TextField(mail + "(ここに入力)", text: $newMail)
                    }
                    Spacer()
                    Button(action: {
                        if isMailChangeTapped {
                            if newMail != "" {
                                mail = newMail
                                newMail = ""
                            }
                        }
                        isMailChangeTapped.toggle()
                    }, label: {
                        if !isMailChangeTapped {
                            Text("変更")
                        } else {
                            Text("更新")
                        }
                        Spacer()
                            .frame(width: decoSet.sideWidth)
                        
                    })
                }
            }
            
            HStack {
                Spacer()
                    .frame(width: decoSet.lineWidth)
                Rectangle()
                    .frame(height: decoSet.rectangleHeight)
                    .foregroundColor(.gray.opacity(decoSet.opacity))
                Spacer()
                    .frame(width: decoSet.lineWidth)
            }
            
            Spacer()
            // Logoutボタン
                Button(action: {
                    isShowingAlert = true
                }, label: {
                Text("ログアウト")
                    .foregroundColor(.white)
            })
            .padding()
            .background(.pink)
            .clipShape(Capsule())
            .alert(isPresented: $isShowingAlert) {
                Alert(
                    title: Text("確認"),
                    message: Text("本当にログアウトしますか？"),
                    primaryButton: .destructive(Text("ログアウト")) {
                        // Documentフォルダの内容全削除
                        let fileManager = FileManager.default
                        let documentDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let fileURLs = try! fileManager.contentsOfDirectory(at: documentDir, includingPropertiesForKeys: nil, options: [])
                        for fileURL in fileURLs {
                            try! fileManager.removeItem(at: fileURL)
                        }
                        isLogined = false
                        do {
                            let fetchPostsDescriptor = FetchDescriptor<MyPosts>()
                            let fetchFriendsDescriptor = FetchDescriptor<Friends>()
                            let postsCount = try context.fetchCount(fetchPostsDescriptor)
                            let friendsCount = try context.fetchCount(fetchFriendsDescriptor)
                            print("posts count: \(postsCount)")
                            print("friends count: \(friendsCount)")
                            try context.delete(model: MyPosts.self, includeSubclasses: true)
                            try context.delete(model: Friends.self, includeSubclasses: true)
                            print("deleted")
                        } catch {
                            print("error")
                        }
                        let _ = LaunchScreen()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        Spacer()
            .frame(height: 40)
    }
}

#Preview {
    SettingView()
}
