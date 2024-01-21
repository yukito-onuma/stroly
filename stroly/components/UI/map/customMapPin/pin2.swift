//
//  pin2.swift
//  stroly
//
//  Created by 大沼優希人 on 2023/12/07.
//

import SwiftUI

//　地図上にピンを表示する
struct pin2: View {
    @Binding var isPinVisible: Bool
    @State private var isSheetPresented = false
    
    @State private var season = Season.Spring
    @State private var time = Time.Morning
    
    init(isPinVisible: Binding<Bool>, imageURL: URL?) {
        self._isPinVisible = isPinVisible
        self.imageURL = imageURL
    }
    
    var imageURL: URL?
    // 吹き出しのサイズ
    var Recsize: CGFloat = 300
    // 縁のサイズ
    var outerWidth: CGFloat = 2
    
    var body: some View {
        Button(action: {
            isPinVisible.toggle()
            print("2d")
        }) {
            ZStack{
                Image("hukidashi")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Recsize,height: Recsize)
                    .shadow(radius: 32)
                VStack{
                    VStack{
                        HStack{
                            Image("mark")
                                .resizable()
                                .scaledToFit()
                                .frame(width:40,height: 40)
                            Text("aaaaaa")
                        }
                        Text("綺麗な桜！！！")
                    }
                    //ボタンをタップするとそこの投稿が表示される
                    Button(action: {
                        isSheetPresented.toggle()
                    }) {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: Recsize/2, height: Recsize/2)
                                .clipShape(Rectangle())
                        } placeholder: {
                            ProgressView()
                                .scaledToFill()
                                .frame(width: Recsize/2, height: Recsize/2)
                                .background(Color.gray)
                                .clipShape(Rectangle())
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
        }
        .padding(.bottom,300)
        .sheet(isPresented: $isSheetPresented) {
            VStack{
                // Deleteボタン(仮)
                Button {
                    print("Delete")
                } label: {
                    Image(systemName: "eraser.line.dashed.fill")
                        .padding()
                        .background(Color.black)
                }
                
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                } placeholder: {
                    ProgressView()
                }
                .presentationDetents([
                    .large,
                ])
            }
            VStack{
                HStack{
                    Button(action: {
                        withAnimation {
                            season = .Spring
                        }
                    }, label: {
                        Text("春")
                            .padding()
                            .background(season == .Spring ? Color.green : Color.clear)
                            .cornerRadius(10)
                    })
                    
                    Button(action: {
                        withAnimation {
                            season = .Summer
                        }
                    }, label: {
                        Text("夏")
                            .padding()
                            .background(season == .Summer ? Color.blue : Color.clear)
                            .cornerRadius(10)
                    })
                    
                    Button(action: {
                        withAnimation {
                            season = .Autumn
                        }
                    }, label: {
                        Text("秋")
                            .padding()
                            .background(season == .Autumn ? Color.orange : Color.clear)
                            .cornerRadius(10)
                    })
                    
                    Button(action: {
                        withAnimation {
                            season = .Winter
                        }
                    }, label: {
                        Text("冬")
                            .padding()
                            .background(season == .Winter ? Color.gray : Color.clear)
                            .cornerRadius(10)
                    })
                }
                HStack{
                    Button(action: {
                        withAnimation {
                            time = .Morning
                        }
                    }, label: {
                        Text("朝")
                            .padding()
                            .background(time == .Morning ? Color.yellow : Color.clear)
                            .cornerRadius(10)
                    })
                    
                    Button(action: {
                        withAnimation {
                            time = .Noon
                        }
                    }, label: {
                        Text("昼")
                            .padding()
                            .background(time == .Noon ? Color.orange : Color.clear)
                            .cornerRadius(10)
                    })
                    
                    Button(action: {
                        withAnimation {
                            time = .Night
                        }
                    }, label: {
                        Text("夜")
                            .padding()
                            .background(time == .Night ? Color.blue : Color.clear)
                            .cornerRadius(10)
                    })
                }
            }
        }
        .opacity(isPinVisible ? 0 : 1)
        .zIndex(isPinVisible ? 0 : 1)
    }
}

struct pin2_Previews: PreviewProvider {
    static var previews: some View {
        pin2(
            isPinVisible: .constant(false), imageURL: URL(string: "https://i0.wp.com/girlydrop.com/wp-content/uploads/2023/04/IMG_6337_jpg.jpg")
        )
    }
}

