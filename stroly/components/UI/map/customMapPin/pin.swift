//
//  pin.swift
//  stroly
//
//  Created by 大沼優希人 on 2023/12/07.
//

import SwiftUI

//　地図上にピンを表示する
struct pin: View {
    @Binding var isPinVisible: Bool
    
    var imageURL: URL?
    // ピン自体のサイズ
    var size: CGFloat = 50
    // 縁のサイズ
    var outerWidth: CGFloat = 2
    
    init(isPinVisible: Binding<Bool>, imageURL: URL?) {
        self._isPinVisible = isPinVisible
        self.imageURL = imageURL
    }
    
    var body: some View {
        Button(action: {
            isPinVisible.toggle()
            print("1")
        }) {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
            } placeholder: {
                ProgressView()
                    .frame(width: size, height: size)
                    .background(Color.gray)
            }
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: outerWidth)
            )
            .shadow(radius: 7)
        }
        .opacity(isPinVisible ? 1 : 0)
        .zIndex(isPinVisible ? 1 : 0)
    }
}

//struct pin_Previews: PreviewProvider {
//    static var previews: some View {
//        pin(isPinVisible: .constant(true), imageURL: URL(string: "https://i0.wp.com/girlydrop.com/wp-content/uploads/2023/04/IMG_6337_jpg.jpg"))
//    }
//}
