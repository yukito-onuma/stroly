//
//  customMapPin.swift
//  stroly
//
//  Created by 大沼優希人 on 2023/12/07.
//

import SwiftUI

struct customMapPin: View {
    @State private var isPinVisible = true
    
    var imageURL : URL?
    
    init(imageURL: URL?) {
        self.imageURL = imageURL
    }

    var body: some View {
        ZStack {
            if isPinVisible {
                // 丸ピン
                pin(isPinVisible: $isPinVisible, imageURL: imageURL)

            } else {
                // 詳細画面ピン
                pin2(isPinVisible: $isPinVisible, imageURL: imageURL)
            }
        }
        .padding()
    }
}


struct customMapPin_Previews: PreviewProvider {
    static var previews: some View {
        customMapPin(
            imageURL: URL(string: "https://i0.wp.com/girlydrop.com/wp-content/uploads/2023/04/IMG_6337_jpg.jpg")
        )
    }
}
