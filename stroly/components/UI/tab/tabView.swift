//
//  tabView.swift
//  stroly
//
//  Created by 長濱聖英 on 2023/12/25.
//

import SwiftUI

struct tabView: View {
    
    @Binding var index : Int
    @State private var isPresented: Bool = false
    @State private var image: UIImage?
    @State var isExitImage: Bool = false
    
    @AppStorage("isLogined") var isLogined = UserDefaults.standard.bool(forKey: "isLogined")
    
    
    
    var body: some View {
        ZStack{
            Button(action: {
                isPresented = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 75, height: 75)
                        .shadow(radius: 5, y: 5)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                .frame(width: 75, height: 75)
                        )
                    
                    Image(systemName: "camera")
                        .font(.system(size: 35))
                        .foregroundColor(Color(hue: 80 / 360, saturation: 1.0, brightness: 0.596))
                }
                .offset(y: -25)
                .fullScreenCover(isPresented: $isPresented) { //フルスクリーンの画面遷移
                    CameraView(image: $image, isExitImage: $isExitImage ).ignoresSafeArea() //カメラ起動
                }
                .fullScreenCover(isPresented: $isExitImage) { //フルスクリーンの画面遷移
                    CreatePost(image: $image).ignoresSafeArea()
                }
            }
            HStack {
                Button(action: {
                    self.index = 0
                }) {
                    VStack{
                        Image(systemName: "person.fill")
                            .font(.system(size: 25))
                        Text("アカウント")
                            .font(.system(size: 10))
                    }
                }
                .foregroundColor(Color.black.opacity(self.index == 0 ? 1 : 0.2))
                
                Spacer(minLength: 0)
                
                Button(action: {
                    self.index = 1
                }) {
                    VStack{
                        Image(systemName: "map.fill")
                            .font(.system(size: 25))
                        Text("地図")
                            .font(.system(size: 10))
                    }
                }
                .foregroundColor(Color.black.opacity(self.index == 1 ? 1 : 0.2))
                
                Spacer(minLength: 100)
                
                Button(action: {
                    self.index = 3
                }) {
                    VStack{
                        Image(systemName: "mail.stack")
                            .font(.system(size: 25))
                        Text("タイムライン")
                            .font(.system(size: 10))
                    }
                }
                .foregroundColor(Color.black.opacity(self.index == 3 ? 1 : 0.2))
                
                Spacer(minLength: 0)
                
                Button(action: {
                    self.index = 4
                }) {
                    VStack{
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 25))
                        Text("フレンド")
                            .font(.system(size: 10))
                    }
                }
                .foregroundColor(Color.black.opacity(self.index == 4 ? 1 : 0.2))
                
            }
            .padding(.bottom, 10)
            .padding(.horizontal, 35)
            .frame(height: 60)
        }
    }
}

#Preview {
    tabView(index: .constant(0))
}
