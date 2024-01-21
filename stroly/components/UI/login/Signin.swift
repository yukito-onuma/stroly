//
//  Signin.swift
//  stroly
//
//  Created by 大坪雄也 on 2023/12/01.
//

import SwiftUI

struct loginResponse: Decodable {
    let name: String
    let userId: String
    let email: String
}

struct Signin: View {
    
    @State private var userName: String = ""
    @State private var password: String = ""
    @State private var mailAdress: String = ""
    @State private var isFilled: Bool = false
    @State private var isShowAlert: Bool = false
    @Binding private var navigationPath: NavigationPath
    @Environment(\.presentationMode) var presentation
    @AppStorage("isLogined") var isLogined = UserDefaults.standard.bool(forKey: "isLogined")
    
    public init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }
    
    public func resister () {
        let url = URL(string: "https://backend.2xseitest.workers.dev/api/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let body: [String: Any] = [
            "userName": userName,
            "email": mailAdress,
            "password": password
        ]
        let finalBody = try! JSONSerialization.data(withJSONObject: body)
        request.httpBody = finalBody
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                _ = JSONDecoder()
                print(String(data: data, encoding: .utf8)!)
                do {
                    let decodedData = try JSONDecoder().decode(loginResponse.self, from: data)
                    print(decodedData)
                    let ud = UserDefaults.standard
                    ud.set(decodedData.userId, forKey: "userId")
                    ud.set(decodedData.name, forKey: "name")
                    ud.set(mailAdress, forKey: "email")
                    ud.set(true, forKey: "isLogined")
                    isLogined = true
                } catch {
                    isLogined = false
                    isShowAlert = true
                }
            }
        }.resume()
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 15) {
                
                Text("サインイン")
                    .font(.system(size: 40, weight: .black, design: .default))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading) // テキストを左寄せ
                    .padding(.horizontal, 10)
                Spacer()
                
                if(isShowAlert){
                    Text("入力されていない項目があります。")
                        .foregroundColor(Color.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                }
                
                
                
                VStack {
                    HStack {
                        Spacer()
                        Image("mark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                        TextField("ユーザー名", text: $userName)
                    }
                    //下線
                    Divider()
                            .background(Color.black)
                            .padding(.horizontal, 10) // 左右に5pxの余白を追加
                    
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 10)
                
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "lock")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .opacity(0.8)
                        TextField("パスワード", text: $password)
                    }
                    //下線
                    Divider()
                            .background(Color.black)
                            .padding(.horizontal, 10) // 左右に5pxの余白を追加
                }
                .padding(.horizontal, 10)
                
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "envelope")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 25)
                            .opacity(0.8)

                        TextField("メールアドレス", text: $mailAdress)
                    }
                    //下線
                    Divider()
                            .background(Color.black)
                            .padding(.horizontal, 10) // 左右に5pxの余白を追加
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 10)
                
                Button(action: {
                    if (userName != "" && password != "" && mailAdress != "") {
                        isFilled = true
                        isShowAlert = false
                    } else {
                        isFilled = false
                        isShowAlert = true
                    }
                    if (isFilled) {
                        self.resister()
                        isLogined = true
                        print(isLogined)
                        self.presentation.wrappedValue.dismiss()
                    }
                }) {
                    Text("作成")
                        .padding()
                        .frame(height: 50) // ボタンの縦幅を50pxに設定
                        .frame(maxWidth: .infinity) // ボタンの横幅を画面いっぱいに広げる
                        .accentColor(Color.black)
                        .background(Color(0xB6CC77, alpha: 1.0))
                        .cornerRadius(25)
                        .padding(.horizontal, 20) // 左右に10pxの余白を追加
                }
                
                Spacer()
            }
        }
    }
}
