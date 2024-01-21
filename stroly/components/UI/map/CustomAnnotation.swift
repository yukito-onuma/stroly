//
//  CustomAnnotation.swift
//  stroly
//
//  Created by 大沼優希人 on 2023/12/16.
//

import SwiftUI
import UIKit

struct CustomAnnotation: View {
    var count: Int
    var imageUrl: String

    @State private var image: UIImage? = nil
    let imageSize: CGFloat = 50.0

    // UserDefaultsから isInPolygon の状態を取得する
    @State private var isInPolygon: Bool
    init(count: Int, imageUrl: String) {
        self.count = count
        self.imageUrl = imageUrl
        // UserDefaultsからisInPolygonの値を取得
        self._isInPolygon = State(initialValue: UserDefaults.standard.bool(forKey: imageUrl))
    }

    var body: some View {
        VStack {
            ZStack {
                if isInPolygon {
                    // isInPolygonがtrueの場合、ピンが保持している画像を表示
                    if let uiImage = image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageSize, height: imageSize)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(radius: 7)
                    } else {
                        // 読み込むまでぐるぐる回転するやつ
                        ProgressView()
                            .frame(width: imageSize, height: imageSize)
                            .foregroundColor(Color(0xB6CC77, alpha: 1.0))
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(radius: 7)
                    }
                } else {
                    // isInPolygonがfalseの場合、?マークを表示
                    // これtrueの時にしか画像読み込まないから通信量削減にもなっていいですね
                    Text("?")
                        .font(.system(size: 30))
                        .frame(width: imageSize, height: imageSize)
                        .foregroundColor(Color(0xB6CC77, alpha: 1.0))
                        .background(Color.white)
                        .clipShape(Circle())
//                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(radius: 7)
                }

                // クラスタリングされた場合のテキスト表示
                if count > 1 {
                    Text(String(count))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.black)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 1))
                        .offset(x: countCoordinate, y: -countCoordinate)
                        .zIndex(1)
                }
            }
        }
        .onAppear {
            loadImageIfNeeded()
        }
    }

    private func loadImageIfNeeded() {
        guard let url = URL(string: imageUrl), isInPolygon else { return }

        // ディスクキャッシュをチェック
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let hashValue = imageUrl.hash
        let fileURL = cacheDirectory.appendingPathComponent("\(hashValue)")

        if let diskCachedImage = UIImage(contentsOfFile: fileURL.path) {
            // ディスクキャッシュから画像を読み込む
            self.image = diskCachedImage
        } else {
            // 画像がディスクキャッシュにない場合は、URLSessionでダウンロード
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let downloadedImage = UIImage(data: data) {
                    try? data.write(to: fileURL, options: [.atomicWrite]) // ダウンロードした画像をディスクキャッシュに保存

                    DispatchQueue.main.async {
                        self.image = downloadedImage // ダウンロードした画像をセット
                    }
                }
            }
            task.resume()
        }
    }

    var countCoordinate: CGFloat {
        return imageSize * sqrt(2) / 4 + 2
    }
}

//struct CustomAnnotation_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomAnnotation(count: 5, imageUrl: "https://backend.2xseitest.workers.dev/api/5131fc50fa0a39e82d8b326b304af66f72ca9ea768cdff2b274c95a025379285.jpg")
//    }
//}
