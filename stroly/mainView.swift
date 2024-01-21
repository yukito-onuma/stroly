//
//  customTabView.swift
//  CustomView
//
//  Created by 大沼優希人 on 2023/11/03.
//

import SwiftUI
import AVFoundation
import SwiftData
import Combine



struct mainView: View {
    @State var index = 1  //押されたボタンの情報
    
    
    init () {
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 以下に遷移先ページ記入。左から順に0,1,(camera),3,4
            if self.index == 0 {
                UserProfileView()
                Divider()
                tabView(index: self.$index)
                    .foregroundColor(Color.white)
            } else if self.index == 1 {
                MapView()
                    .ignoresSafeArea(.all)
                Divider()
                tabView(index: self.$index)
                    .foregroundColor(Color.white)
            } else if self.index == 3 {
                // ここに記入
                Divider()
                tabView(index: self.$index)
                    .foregroundColor(Color.white)
            } else if self.index == 4 {
                FriendList()
                Divider()
                tabView(index: self.$index)
                    .foregroundColor(Color.white)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }

}

#Preview {
    mainView()
}



