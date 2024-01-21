//
//  LaunchScreen.swift
//  stroly
//
//  Created by 小平暖太 on 2023/11/17.
//

import SwiftUI

struct LaunchScreen: View {
    @State private var isLoading = true
    @AppStorage("isLogined") var isLogined = false
    
    var body: some View {
        if isLoading {
            ZStack {
                Color("Primary")
                    .ignoresSafeArea() // ステータスバーまで塗り潰すために必要
                Image("splash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        isLoading = false
                    }
                }
            }
        } else if isLogined {
            mainView()
        } else {
            PreLogin()
        }
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
