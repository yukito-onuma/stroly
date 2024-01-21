//
//  Cre.swift
//  stroly
//
//  Created by 小平暖太 on 2023/12/06.
//

import SwiftUI
import Combine
import CoreLocation
import SwiftData


struct postResponse: Decodable {
    let id : Int
    let userId: String
    let userName: String
    let title: String
    let key: String
    let createdAt: String
    let latitude: Double
    let longitude: Double
    let isPublic: Bool
    let isFriendsOnly: Bool
    let isPrivate: Bool
}

enum Status {
    case global, friends, privatePost
}

let textLimit = 20 //最大文字数

struct CreatePost: View {
    
    @State private var comment: String = ""
    @State private var status: Status = .global
    @Binding var image: UIImage?
    @State private var globeColor = true
    @State private var friendsColor = false
    @State private var privacyColor = false
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.modelContext) private var context
    
    @Query var myPosts: [MyPosts]
    
    
    public init(image: Binding<UIImage?>) {
        self._image = image
    }
    
    public func makeFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmssSSS"
        return "phone_" + formatter.string(from: Date()) + ".jpg"
    }
    
    public func submitPin(userIdLocal: String, titleLocal: String, imageLocal: String, latitudeLocal: Double, longitudeLocal: Double, isPublicLocal: Bool, isFriendsOnlyLocal: Bool, isPrivateLocal: Bool, userNameLocal: String) {
        let url = URL(string: "https://backend.2xseitest.workers.dev/api/post")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        print(latitudeLocal, longitudeLocal)
        let body: [String: Any] = [
            "userId": userIdLocal,
            "userName": userNameLocal,
            "title": titleLocal,
            "key": imageLocal,
            "latitude": latitudeLocal,
            "longitude": longitudeLocal,
            "isPublic": isPublicLocal,
            "isFriendsOnly": isFriendsOnlyLocal,
            "isPrivate": isPrivateLocal
        ]
        let finalBody = try! JSONSerialization.data(withJSONObject: body)
        request.httpBody = finalBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                _ = JSONDecoder()
                print(String(data: data, encoding: .utf8)!)
                do {
                    let postdata: [postResponse] = try JSONDecoder().decode([postResponse].self, from: data)
                    print(postdata)
                    self.savePost(id: postdata[0].id, userIdLocal: postdata[0].userId, titleLocal: postdata[0].title, keyLocal: postdata[0].key, latitudeLocal: postdata[0].latitude, longitudeLocal: postdata[0].longitude, isPublicLocal: postdata[0].isPublic, isFriendsOnlyLocal: postdata[0].isFriendsOnly, createdAtLocal: postdata[0].createdAt, isPrivateLocal: postdata[0].isPrivate, userNameLocal: postdata[0].userName)
                } catch {
                    print("Decode Error")
                    print(error)
                }
            }
        }.resume()
    }
    
    public func savePost(id: Int, userIdLocal: String, titleLocal: String, keyLocal: String, latitudeLocal: Double, longitudeLocal: Double, isPublicLocal: Bool, isFriendsOnlyLocal: Bool, createdAtLocal: String, isPrivateLocal: Bool, userNameLocal: String) {
        let post = MyPosts(id: id, userId: userIdLocal, title: titleLocal, key: keyLocal, createdAt: createdAtLocal, latitude: latitudeLocal, longitude: longitudeLocal, isPublic: isPublicLocal, isFriendsOnly: isFriendsOnlyLocal, userName: userNameLocal, isPrivate: isPrivateLocal)
        let fileName = keyLocal
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pictureURL = documentsURL.appendingPathComponent(fileName)
        if let data = image?.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: pictureURL)
            } catch {
                print("Error writing to file:¥(error)")
            }
        }
        context.insert(post)
        do {
            try context.save()
            print("Saved")
            print("Count: \(myPosts.count)")
        } catch {
            print(error)
        }
    }
    
    
    var body: some View {
        NavigationView {
        //背景を白
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        UIApplication.shared.closeKeyboard()
                    }
                VStack {
                    HStack {
                        Button(action: {
                            self.presentation.wrappedValue.dismiss()
                        }) {
                            Image(systemName:  "xmark")
                                .font(.system(size: 25))
                                .foregroundColor(Color.black)
                                .frame(height: 50) // ボタンの縦幅を50pxに設定
                                .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 0))
                        }
                        Spacer()
                        Button(action: {
                            print("投稿")
                            let locationManager = CLLocationManager()
                            let location = locationManager.location
                            let latitude = location?.coordinate.latitude
                            let longitude = location?.coordinate.longitude
                            print("latitude: \(latitude!), longitude: \(longitude!)")
                            let base64String = image?.jpegData(compressionQuality: 0.5)?.base64EncodedString()
                            let title = comment
                            let userId = UserDefaults.standard.string(forKey: "userId")!
                            let userName = UserDefaults.standard.string(forKey: "name")!
                            if (status == .global) {
                                self.submitPin(userIdLocal: userId, titleLocal: title, imageLocal: base64String!, latitudeLocal: latitude!, longitudeLocal: longitude!, isPublicLocal: true, isFriendsOnlyLocal: false, isPrivateLocal: false, userNameLocal: userName)
                            } else if (status == .friends) {
                                self.submitPin(userIdLocal: userId, titleLocal: title, imageLocal: base64String!, latitudeLocal: latitude!, longitudeLocal: longitude!, isPublicLocal: false, isFriendsOnlyLocal: true, isPrivateLocal: false, userNameLocal: userName)
                            } else if (status == .privatePost) {
                                self.submitPin(userIdLocal: userId, titleLocal: title, imageLocal: base64String!, latitudeLocal: latitude!, longitudeLocal: longitude!, isPublicLocal: false, isFriendsOnlyLocal: false, isPrivateLocal: true, userNameLocal: userName)
                            }
                            self.presentation.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "paperplane")
                                .font(.system(size: 25))
                                .foregroundColor(Color(0xB6CC77, alpha: 1.0))
                                .frame(height: 50) // ボタンの縦幅を50pxに設定
                                .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 20))
                        }
                    }
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .onTapGesture {
                                UIApplication.shared.closeKeyboard()
                            }
                    }
                    Spacer()
                        .frame(height: 20)
                    HStack{
                        Button(action: {
                            status = .global
                            globeColor = true
                            friendsColor = false
                            privacyColor = false
                        }) {
                            Image(systemName: "globe")
                                .padding(.horizontal)
                                .font(.system(size: 20))
                                .frame(height: 50) // ボタンの縦幅を50pxに設定
                                .foregroundColor(globeColor ? Color(0xB6CC77, alpha: 1.0) : Color.black)
                        }
                        Button(action: {
                            status = .friends
                            globeColor = false
                            friendsColor = true
                            privacyColor = false
                        }) {
                            Image(systemName: "person.2")
                                .padding(.horizontal)
                                .font(.system(size: 20))
                                .frame(height: 50) // ボタンの縦幅を50pxに設定
                                .foregroundColor(friendsColor ? Color(0xB6CC77, alpha: 1.0) : Color.black)
                        }
                        Button(action: {
                            status = .privatePost
                            globeColor = false
                            friendsColor = false
                            privacyColor = true
                        }) {
                            Image(systemName: "lock")
                                .padding(.horizontal)
                                .font(.system(size: 20))
                                .frame(height: 50) // ボタンの縦幅を50pxに設定
                                .foregroundColor(privacyColor ? Color(0xB6CC77, alpha: 1.0) : Color.black)
                        }
                    }
                    Spacer()
                        .frame(height: 30)
                    //テキストフィールドを作成
                    TextField("ひとこと(20字まで)", text: $comment)
                        .foregroundColor(Color.black)
                        .padding()
                        .frame(height: 50) // ボタンの縦幅を50pxに設定
                        .frame(maxWidth: .infinity) // ボタンの横幅を画面いっぱいに広げる
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom, 15)
                    Spacer()
                        .frame(height: 30)
                        .onReceive(Just(comment)) { _ in
                            //最大文字数を超えたら、最大文字数までの文字列を代入する
                            if comment.count > textLimit {
                                comment = String(comment.prefix(textLimit))
                            }
                        }
                }
            }
        }
    }
}
    extension UIApplication {
        func closeKeyboard() {
            sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

