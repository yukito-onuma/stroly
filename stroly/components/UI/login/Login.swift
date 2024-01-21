//
//  Login.swift
//  stroly
//
//  Created by 大坪雄也 on 2023/12/01.
//

//参考URL：https://www.yururiwork.net/archives/144 (コードでNavigationLink「back」実行)
//        https://blog.code-candy.com/swiftui_navigationstack/#2 (navigationStackの使い方)

import SwiftUI



struct Login: View {

    @State private var mailAdress: String = ""
    @State private var password: String = ""
    @State private var isFilled: Bool = false
    @State private var isShowAlert: Bool = false
    @State private var isShowAlert2: Bool = false
    @State private var isTransSignin: Bool = false
    @State private var isSignined: Bool = false
    @State private var responseMessage: String = ""
    @Binding private var navigationPath: NavigationPath
    @AppStorage("isLogined") var isLogined = UserDefaults.standard.bool(forKey: "isLogined")

    //NavigationLinkを戻すのに使う。
    @Environment(\.presentationMode) var presentation
    
    @Environment(\.modelContext) private var context

    //PreLoginViewから与えられたisLogined変数と、このViewのisLogined変数と紐付ける。
    public init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }
    
    public func login() {
        let url = URL(string: "https://backend.2xseitest.workers.dev/api/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let body: [String: Any] = [
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
                    ud.set(decodedData.email, forKey: "email")
                    ud.set(true, forKey: "isLogined")
                    isLogined = true
                    DispatchQueue.global().async {
                        saveMyPostsData(context: context)
                        DispatchQueue.main.async {
                            print("saved")
                        }
                    }
                } catch {
                    isLogined = false
                    isShowAlert2 = true
                    responseMessage = "ログインに失敗しました。"
                }
            }
        }.resume()
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 15) {
                    
                Text("ログイン")
                    .font(.system(size: 40, weight: .black, design: .default))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading) // テキストを左寄せ
                    .padding(.horizontal, 10)
                    
                Spacer()
                Spacer()
                
                if(isShowAlert){
                    Text("入力されていない項目があります。")
                        .foregroundColor(Color.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                }
                if(isShowAlert2){
                    Text(responseMessage)
                        .foregroundColor(Color.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                }
                
                
                //ユーザー名のテキストフィールド
                VStack{
                    HStack {
                        Spacer()
                        Image("mark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
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
                    
                //パスワードのテキストフィールド
                VStack{
                    HStack {
                        Spacer()
                        Image(systemName: "lock")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .opacity(0.8)
                        SecureField("パスワード", text: $password)
                    }
                    //下線
                    Divider()
                            .background(Color.black)
                            .padding(.horizontal, 10) // 左右に5pxの余白を追加
                                
                }
                .padding(.horizontal, 10)
                
                Spacer()
                    
                // 「ログイン」ボタンは項目を埋めたら押せるようにしたい。
                Button(action: {
                if (password != "" && mailAdress != "") {
                    isFilled = true
                    isShowAlert = false
                } else {
                    isFilled = false
                    isShowAlert = true
                }
                if (isFilled) {
                    self.login()
                    print(isLogined)
                    if(isLogined){
                        self.presentation.wrappedValue.dismiss()
                    }
                }
                }) {
                    Text("ログイン")
                        .padding()
                        .frame(height: 50) // ボタンの縦幅を50pxに設定
                        .frame(maxWidth: .infinity) // ボタンの横幅を画面いっぱいに広げる
                        .accentColor(Color.black)
                        .background(Color(0xB6CC77, alpha: 1.0))
                        .cornerRadius(25)
                        .padding(.horizontal, 20) // 左右に10pxの余白を追加
                }
                    
                //「アカウントを作成する」ボタンが押されたら、isTransSigninをTrueにする。
                Button(action: {
                    isTransSignin.toggle()
                }) {
                    Text("アカウントを作成する")
                        .foregroundColor(Color.black)
                }
                
                Spacer()
                
                if isLogined {
                    let _ = self.presentation.wrappedValue.dismiss()
                }

                
                //isTransSigninがTrueになったら、SigninViewに遷移する。
                NavigationLink(destination: Signin(navigationPath: $navigationPath), isActive: $isTransSignin, label: {EmptyView()})
                
            }
            
            Spacer()
        }
    }
}
