//
//  PreLogin.swift
//  stroly
//
//  Created by 大坪雄也 on 2023/12/01.
//

import SwiftUI

enum Path {
    case PreLogin, Login, Signin
}

//16進数を扱うため
extension Color {
  init(_ hex: UInt, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255,
      opacity: alpha
    )
  }
}

struct PreLogin: View {
    
    @State private var page :Bool = false
    @State private var navigationPath = NavigationPath()
    @AppStorage("isLogined") var isLogined = UserDefaults.standard.bool(forKey: "isLogined")
    
    var body: some View {
        if !isLogined {
            NavigationStack(path: $navigationPath) {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        Image("splash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: geometry.size.height * 0.6) // 画面縦幅の60%に制約
                            .padding()
                            .offset(y: 50)
                        
                        Spacer()
                        
                        NavigationLink(destination: Login(navigationPath: $navigationPath), isActive: $page, label: {EmptyView()})
                                            
                        
                        Button(action: {
                            page.toggle()
//                            navigationPath.append(0)
                        }) {
                            Text("アカウント作成　/　ログイン")
                                .padding()
                                .frame(height: 50) // ボタンの縦幅を50pxに設定
                                .frame(maxWidth: .infinity) // ボタンの横幅を画面いっぱいに広げる
                                .accentColor(Color.black)
                                .background(Color(0xB6CC77, alpha: 1.0))
                                .cornerRadius(25)
                                .padding(.horizontal, 20) // 左右に10pxの余白を追加
                                            
                        }
                        .padding(.bottom, 50)  //下に50px分の余白
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else {
            mainView()
        }
    }
}

#Preview {
    PreLogin()
}

