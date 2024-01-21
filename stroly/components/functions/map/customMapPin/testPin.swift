//
//  testPin.swift
//  stroly
//
//  Created by 大沼優希人 on 2023/12/13.
//

import SwiftUI

struct testPin: View {
    @State private var isButton1Visible = true

    var body: some View {
        VStack {
            if isButton1Visible {
                Button(action: {
                    isButton1Visible.toggle()
                }, label: {
                    /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
                })
                .zIndex(1)
            } else {
                Button(action: {
                    isButton1Visible.toggle()
                }, label: {
                    Text("Button2")
                })
                .zIndex(1)
            }

            Spacer()
        }
        .padding()
    }
}

struct testPin_Previews: PreviewProvider {
    static var previews: some View {
        testPin()
    }
}

