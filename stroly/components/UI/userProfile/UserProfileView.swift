//
//  UserProfileView.swift
//  stroly
//
//  Created by 大坪雄也 on 2023/12/08.
//

// 参考URL: https://www.yururiwork.net/archives/1404 (ImagePickerの使用例)
//        https://stackoverflow.com/questions/64551580/swiftui-sheet-doesnt-access-the-latest-value-of-state-variables-on-first-appear (sheet上でStateを正しく反映させる方法)
//        https://ja.stackoverflow.com/questions/63943/state%E4%BB%98%E3%81%8D%E3%81%AE%E5%A4%89%E6%95%B0%E3%81%AE%E5%80%A4%E3%81%AE%E5%88%9D%E6%9C%9F%E5%8C%96%E3%81%8C%E7%84%A1%E5%8A%B9%E3%81%AB%E3%81%AA%E3%82%8B (State変数を正しくinit()内で初期化する方法)

import SwiftUI
import SwiftData

// 装飾用の定数
struct DecorationSettings {
    //両端のスペース
    let sideWidth: CGFloat = 16
    //「ユーザーネーム」などの文字列とnameなどの文字列との幅
    let heightBetweenString: CGFloat = 10
    //各cellの上下幅
    let cellHalfHeight: CGFloat = 18
    //rectangleの透過度・太さ
    let opacity: CGFloat = 0.5
    let rectangleHeight: CGFloat = 1
    
    //アイコンの大きさ
    let iconWidth: CGFloat = 100
    let iconHeight: CGFloat = 100
    
    //下線の横幅
    let lineWidth: CGFloat = 7
    
    //画面の大きさ
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    //並び替えと絞り込みボタンの大きさ
    let buttonWidth: CGFloat = 25
    let buttonHeight: CGFloat = 25
}

struct UserProfileView: View {
    
    private let decoSet = DecorationSettings()

    private let iconURL: URL?
    @State private var iconImage: UIImage?
    @State private var userName = UserDefaults.standard.string(forKey: "name") ?? "ユーザー名"
    @State private var QrCodeStr = ""

    @State private var isIconChangeTapped = false
    @State private var isScanButtonTapped = false
    @State private var isGenQRButtonTapped = false
    @State private var isSettingButtonTapped = false
    @State private var isAlbumTapped = false
    @State private var isPostTapped = false
    @State private var selectedImage: UIImage? = nil
    @State private var selectedPost: MyPosts? = nil
    
    @State private var qrimage: UIImage?
    
    // swiftDataからMyPostを取ってくる
    @Environment(\.modelContext) private var context
    @Query private var myPosts: [MyPosts]
    // LazyVGridの設定

    // 自分のpostはドキュメントディレクトリから取る
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    let fetchDescriptor = FetchDescriptor<MyPosts>()
    
    public init () {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        iconURL = documentsURL.appendingPathComponent("userIcon.jpeg")
        let tmpIconImage = convertURLToImage(iconURL: iconURL!)
        _iconImage = State(initialValue: tmpIconImage)
    }
    
    var body: some View {
        NavigationStack() {
            VStack {
                
                Spacer()
                    .frame(height: 20)
                
                //ユーザー追加・QRコード表示ボタン
                HStack {
                    //オプションボタン
                    HStack {
                        Spacer()
                        Spacer()
                        Button(action: {
                            isSettingButtonTapped = true
                        }, label: {
                            Image(systemName: "gearshape")
                                .resizable()
                                .foregroundColor(.gray)
                                .frame(width: 35, height: 35)
                        })
                        Spacer()
                            .frame(alignment : .topLeading)
                        
                    }
                    Spacer()
                    Button(action: {
                        isScanButtonTapped = true
                    }, label: {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .resizable()
                            .foregroundColor(Color(0xB6CC77, alpha: 1.0))
                            .frame(width: 40, height: 35)
                    })
                    Spacer()
                        .frame(width: decoSet.sideWidth)
                }
                Spacer()
                    .frame(height: 15)
                HStack {
                    VStack{
                        HStack{
                            //ユーザーアイコン
                            Spacer()
                                .frame(width: decoSet.sideWidth)
                            Button (action: {
                                isIconChangeTapped = true
                            }, label: {
                                if let image = iconImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: decoSet.iconWidth, height: decoSet.iconHeight)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: decoSet.iconWidth, height: decoSet.iconHeight)
                                }
                            })
                            // 周りを灰色で囲む
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1.0) // 1.0やそれ以下の値に調整
                            )
                            Spacer()
                                .frame(height: 20)
                            Spacer()
                                .frame(width: decoSet.sideWidth)
                            //                    Text("ユーザーネーム")
                            //                        .font(.caption)
                            //                        .foregroundColor(.gray)
                            Spacer()
                        }
                        
                        
                        //ユーザーネームの行
                        Spacer()
                            .frame(height: decoSet.heightBetweenString)
                        HStack {
                            Spacer()
                                .frame(width: decoSet.sideWidth)
                            Text(userName)
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
//                    ここに投稿数、解放したピンの数、歩いた歩数
                    Spacer()
                    VStack {
                        Button(action: {
                            //QRの表示
                            let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
                            qrimage = QRCodeGenerator().generate(with: userId)
                            isGenQRButtonTapped = true
                        }, label: {
                            Image(systemName: "qrcode")
                                .resizable()
                                .foregroundColor(Color(0xB6CC77, alpha: 1.0))
                                .frame(width: 30, height: 30)
                        })
                        Spacer()
                            .frame(height: 100)
                    }
                    Spacer()
                        .frame(width: decoSet.sideWidth + 2)
                    
                }
                
                Divider()
                
                // 写真一覧表示のView
                AlbumView(isPostTapped: $isPostTapped, selectedPost: $selectedPost, selectedImage: $selectedImage)
            }
            .sheet(isPresented: $isIconChangeTapped, onDismiss: {
                if let image = iconImage {
                    storeImage(iconImage: image, iconURL: iconURL!)
                    iconImage = convertURLToImage(iconURL: iconURL!)
                    uploadIcon(iconImage: image)
                }
            }) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $iconImage)
            }
            .sheet(isPresented: $isGenQRButtonTapped)
            {
                QRSheetView(QRImage: $qrimage)
            }
            
            NavigationLink(destination: SettingView(), isActive: $isSettingButtonTapped, label: {EmptyView()})
                
            .fullScreenCover(isPresented: $isScanButtonTapped) {
                ZStack {
                    //フルスクリーンの画面遷移
                    QrCodeScanner()
                        .ignoresSafeArea(.all)
                    VStack {
                        Spacer()
                    Button {
                        isScanButtonTapped = false
                    } label: {
                        HStack {
                            Image(systemName: "x.circle")
                                .resizable()
                                .background(.pink)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .frame(width: 50, height: 50)
                        }
                    }
                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
            .sheet(isPresented: $isPostTapped)
            {
                MyPostView(post: $selectedPost, postImage: $selectedImage)
            }
        }
    }
    
    
    // documents directoryから古いデータを削除して、新しいデータを入れる処理
    private func storeImage(iconImage: UIImage, iconURL: URL) {
            if let data = iconImage.jpegData(compressionQuality: 100) {
                do {
                    do {
                        // 前のiconのデータを一旦削除する部分
                        try FileManager.default.removeItem(at: iconURL)
                    } catch {
                    }
                    // 新しいデータの書き込み
                    try data.write(to: iconURL)
                } catch {
                }
            }
        }
    
    private func uploadIcon(iconImage: UIImage)
    {
        let key = iconImage.jpegData(compressionQuality: 0.2)?.base64EncodedString()
        let userId = UserDefaults.standard.string(forKey: "userId")
        // PUTリクエストで、bodyにuserIdとkeyを入れて送る
        let url = URL(string: "https://backend.2xseitest.workers.dev/api/user/icon")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        let body: [String: String] = ["userId": userId!, "key": key!]
        let uploadData = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = uploadData
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print(String(data: data, encoding: .utf8)!)
            }
        }.resume()
    }
}


// QRコードを表示するためのSheet
// これを作らないとSheet上で正しくState変数が反映されない
struct QRSheetView: View {
    @Binding var QRImage: UIImage?
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        if let image = QRImage {
            VStack {
                Image(uiImage: image)
                Spacer()
                    .frame(height: 20)
                Button {
                    presentation.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Spacer()
                            .frame(width: 10)
                        Text("戻る")
                    }
                }
            }
        } else {
            Button {
                presentation.wrappedValue.dismiss()
            } label: {
                Text("もう一度QRボタンを押してください")
            }
        }
    }
}


extension CIImage {
    func toCGImage() -> CGImage? {
        let context = { CIContext(options: nil) }()
        return context.createCGImage(self, from: self.extent)
    }

    func toUIImage(orientation: UIImage.Orientation) -> UIImage? {
        guard let cgImage = self.toCGImage() else { return nil }
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
    }
}
