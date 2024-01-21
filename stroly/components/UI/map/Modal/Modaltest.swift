//
//  Modaltest.swift
//  stroly
//
//  Created by 大沼優希人 on 2023/12/21.
//

import SwiftUI
import Foundation
import CoreLocation

class SharedLocationManager: ObservableObject {
    @Published var selectedLocation: CLLocationCoordinate2D?
}
extension Notification.Name {
    static let coordinateUpdated = Notification.Name("coordinateUpdated")
}


enum Season {
    case Spring
    case Summer
    case Autumn
    case Winter
}

enum Time {
    case Morning
    case Noon
    case Night
}

// １つのピンがタップされた時のモーダル
struct AnnotationModalView: View {
    @ObservedObject var sharedData: SharedAnnotationData
    @Environment(\.dismiss) var dismiss
    @State private var showingAlert = false
    let imageUrlPrefix = "https://backend.2xseitest.workers.dev/api/"
    let iconUrlPrefix = "https://backend.2xseitest.workers.dev/api/user/icon?userId="

    var body: some View {
        ScrollView {
            if let annotation = sharedData.selectedAnnotation {
                // VStackを以下の書き方すると左揃えできる便利！
                VStack(alignment: .leading, spacing: 10) {
                    Spacer()
                    HStack{
                        if let iconImage = loadImageIfNeeded(imageUrl: iconUrlPrefix + annotation.userId) {
                            Image(uiImage: iconImage)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1.0) // 1.0やそれ以下の値に調整
                                )
                                .frame(width: 60, height: 60, alignment: .leading)
                        } else {
                            Image(systemName: "person.circle")
                                .resizable()
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1.0) // 1.0やそれ以下の値に調整
                                )
                                .frame(width: 60, height: 60, alignment: .leading)
                        }
                        Spacer()
                            .frame(width: 10)
                        VStack(alignment: .leading, spacing: 0){
                            Text("@\(annotation.userName )")
                                .font(.headline)
                            Text("\(formattedDate(from: annotation.createdAt))")
                                .font(.subheadline)
                        }
                        Spacer()
                        Menu {
                            Button(action: {
                                showingAlert = true
                                print("Deleteボタンが押されました")
                            }) {
                                Text("削除する")
                                    .font(.headline)
                                    .padding()
                                    .background(Color.pink)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        } label: {
                            Image(systemName:"ellipsis")
                                .padding()
                                .foregroundColor(.gray)
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("確認"),
                                message: Text("本当に削除しますか？"),
                                primaryButton: .destructive(Text("削除")) {
                                    // 削除処理
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                    CustomImageView(imageUrl: annotation.imageUrl)
                    Text("\(annotation.title ?? "不明")")
                        .font(.headline)
                }
                .background(Color.white)
                .padding(.horizontal)
                .padding(.bottom, 5)
                .onAppear(){
                    print("userId: \(annotation.userId)")
                    print("icon: \(iconUrlPrefix + annotation.userId)")
                }
            }
        }
    }
    // ISO8601の日付文字列から月、日、時間を抽出する関数
    func formattedDate(from isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime] // 時間も含めるためのオプション
        if let date = isoFormatter.date(from: isoDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM月dd日HH時mm分" // 日付と時間のフォーマット
            return dateFormatter.string(from: date)
        } else {
            return "日付不明"
        }
    }
}

// クラスタリングされたピンがタップされた時のモーダル
struct ClusterAnnotationModalView: View {
    @ObservedObject var sharedData: SharedAnnotationData
    @EnvironmentObject var sharedLocationManager: SharedLocationManager
    @Environment(\.dismiss) var dismiss
    @State private var showingAlert = false
    @State private var isNavigating = false
    let iconUrlPrefix = "https://backend.2xseitest.workers.dev/api/user/icon?userId="

    
    var body: some View {
        NavigationView {
            VStack{
                Spacer()
                ZStack{
                    NavigationLink(destination: SeasonAndTime(sharedData: sharedData), isActive: $isNavigating) {
                        EmptyView()
                    }
                    .hidden()
                    // ページ遷移ボタン
                    Spacer()
                    Button {
                        isNavigating = true
                    } label: {
                        Text("季節・時間帯別で見る")
                            .font(.headline)
                            .padding()
                            .background(Color(hue: 80 / 360, saturation: 1.0, brightness: 0.596))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Spacer()
                    HStack{
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .imageScale(.small)
                                .foregroundColor(.white)
                        }
                        .frame(width: 30, height: 30)  // ボタンのサイズを設定
                        .background(Color.gray)  // ボタンの背景色
                        .clipShape(Circle())  // ボタンを丸形にする
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 2)  // ボタンの枠線
                        )
                        .padding(.horizontal, 10)
                    }
                }
                Spacer()
                Divider()
                ScrollView {
                    if sharedData.clusterAnnotations.isEmpty {
                        Text("表示できる画像がありません")
                    } else {
                        VStack {
                            ForEach(sharedData.clusterAnnotations, id: \.id) { annotation in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack{
                                        if let iconImage = loadImageIfNeeded(imageUrl: iconUrlPrefix + annotation.userId) {
                                            Image(uiImage: iconImage)
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle().stroke(Color.white, lineWidth: 4))
                                                .frame(width: 60, height: 60, alignment: .leading)
                                        } else {
                                            Image(systemName: "person.circle")
                                                .resizable()
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle().stroke(Color.white, lineWidth: 4))
                                                .frame(width: 60, height: 60, alignment: .leading)
                                        }
                                        VStack(alignment: .leading, spacing: 0){
                                            Text("@\(annotation.userName )")
                                                .font(.headline)
                                            Text("\(formattedDate(from: annotation.createdAt))")
                                                .font(.subheadline)
                                        }
                                        Spacer()
                                        Menu {
                                            Button(action: {
                                                showingAlert = true
                                                print("Deleteボタンが押されました")
                                            }) {
                                                Text("削除する")
                                                    .font(.headline)
                                                    .padding()
                                                    .background(Color.pink)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(10)
                                            }
                                        } label: {
                                            Image(systemName:"ellipsis")
                                                .padding()
                                        }
                                        .alert(isPresented: $showingAlert) {
                                            Alert(
                                                title: Text("確認"),
                                                message: Text("本当に削除しますか？"),
                                                primaryButton: .destructive(Text("削除")) {
                                                    // 削除処理
                                                },
                                                secondaryButton: .cancel()
                                            )
                                        }
                                    }
                                    CustomImageView(imageUrl: annotation.imageUrl)
                                    Text("\(annotation.title ?? "不明")")
                                        .font(.headline)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                                .onTapGesture {
                                    dismiss()
                                    let newCoordinate = CLLocationCoordinate2D(
                                        latitude: annotation.latitude,
                                        longitude: annotation.longitude
                                    )
                                    print("タップされた座標: \(newCoordinate.latitude), \(newCoordinate.longitude)")
                                    NotificationCenter.default.post(name: .coordinateUpdated, object: newCoordinate)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    // ISO8601の日付文字列から月、日、時間を抽出する関数
    func formattedDate(from isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime] // 時間も含めるためのオプション
        if let date = isoFormatter.date(from: isoDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM月dd日HH時mm分" // 日付と時間のフォーマット
            return dateFormatter.string(from: date)
        } else {
            return "日付不明"
        }
    }
}

struct CustomImageView: View {
    @StateObject private var imageLoader: ImageLoader
    
    init(imageUrl: String) {
        _imageLoader = StateObject(wrappedValue: ImageLoader(imageUrl: imageUrl))
    }
    
    var body: some View {
        if let image = imageLoader.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else if imageLoader.isLoading {
            ProgressView()
                .frame(width: 50, height: 50)
        } else {
            Text("Image not available")
                .frame(width: 50, height: 50)
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
        @Published var isLoading = false
        var imageUrl: String
    
    init(imageUrl: String) {
        self.imageUrl = imageUrl
        loadImage()
    }
    
    func loadImage() {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let hashValue = imageUrl.hash
        let fileURL = cacheDirectory.appendingPathComponent("\(hashValue)")
        
        // ディスクキャッシュから画像を読み込む
        if let diskCachedImage = UIImage(contentsOfFile: fileURL.path) {
            print("キャッシュから読み込みました")
            DispatchQueue.main.async {
                self.image = diskCachedImage
            }
        } else {
            // キャッシュにない場合はダウンロード
            print("ダウンロードしました")
            guard let url = URL(string: imageUrl) else { return }
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let downloadedImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = downloadedImage
                        self.isLoading = false
                    }
                    try? data.write(to: fileURL, options: [.atomicWrite])
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
            task.resume()
        }
    }
}



//#Preview {
//    AnnotationModalView(sharedData: <#SharedAnnotationData#>)
//}
