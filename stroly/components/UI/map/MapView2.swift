//
//  MapView2.swift
//  stroly
//
//  Created by 大沼優希人 on 2023/12/16.
//


// **************************************
//
//    このファイル実験として作っただけだから
//    後でファイル名とか色々整理します！！！
//
// **************************************

import SwiftUI
import MapKit
import CoreLocation
import Combine

// swiftUIにデータを渡す用のモデル
class SharedAnnotationData: ObservableObject {
    @Published var selectedAnnotation: CustomPointAnnotation?
    @Published var clusterAnnotations: [CustomPointAnnotation] = []
}

// newLocationに新しい値を渡したい場合は以下で定義する
class CustomPointAnnotation: MKPointAnnotation, Identifiable {
    var imageUrl: String
    var userName: String
    var latitude: Double
    var longitude: Double
    var createdAt: String
    var polygonCenter: CLLocationCoordinate2D
    var polygonRadius: CLLocationDistance
    var isPublic: Bool
    var userId: String

    // isInPolygon は UserDefaults から取得する
    private var _isInPolygon: Bool = false
    var isInPolygon: Bool {
        get {
            _isInPolygon
        }
        set {
            _isInPolygon = newValue
            UserDefaultsManager.shared.setIsInPolygon(newValue, forKey: imageUrl)
        }
    }

    init(imageUrl: String, userName: String, latitude: Double, longitude: Double, createdAt: String, polygonCenter: CLLocationCoordinate2D, polygonRadius: CLLocationDistance, isInPolygon: Bool, isPublic: Bool, userId: String) {
        self.imageUrl = imageUrl
        self.userName = userName
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
        self.polygonCenter = polygonCenter
        self.polygonRadius = polygonRadius
        self.isPublic = isPublic
        self.userId = userId
        super.init()
        // UserDefaultsからの初期値の設定
        self.isInPolygon = isInPolygon
    }
}

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private init() {}
    
    private var isInPolygonUpdates: [String: Bool] = [:]
    private var timer: Timer?
    
    func setIsInPolygon(_ value: Bool, forKey key: String) {
        isInPolygonUpdates[key] = value
        startTimerIfNeeded()
    }
    
    private func startTimerIfNeeded() {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: false) { [weak self] _ in
            self?.commitChanges()
        }
    }
    
    private func commitChanges() {
        isInPolygonUpdates.forEach { key, value in
            UserDefaults.standard.set(value, forKey: key)
        }
        isInPolygonUpdates.removeAll()
        timer = nil
    }
}

struct Location: Identifiable {
    let id = UUID()
    let imageUrl: String
    let latitude: Double
    let longitude: Double
    let title: String
    let subtitle: String
    let comment: String
}

// キャッシュ用
class ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSString, UIImage>()

    private init() {}

    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func hasImage(forKey key: String) -> Bool {
        return cache.object(forKey: key as NSString) != nil
    }
}

struct MapView: UIViewRepresentable {
    @State var centerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 35.68154, longitude: 139.752498)
    @ObservedObject var sharedLocationManager: SharedLocationManager
    var annotations = [MKAnnotation]()
    private let locationManager = CLLocationManager()
    private let view = MKMapView(frame: .zero)
    
    var showUpdateButton = false

    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // 明示的にマップをクリーンアップする
    static func dismantleUIView(_ uiView: MKMapView, coordinator: ()) {
        // マップビューのクリーンアップ
        uiView.removeAnnotations(uiView.annotations)
        uiView.delegate = nil
        uiView.removeFromSuperview()
    }

    // 座標が変更されたら通知を受け取る
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(forName: .coordinateUpdated, object: nil, queue: .main) { [unowned view] notification in
            self.setupMyView(notification: notification)
        }
    }
    
    private func setupMyView(notification: Notification) {
        if let newCoordinate = notification.object as? CLLocationCoordinate2D {
            let region = MKCoordinateRegion(center: newCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            view.setRegion(region, animated: true)
        }
    }

    private func updateMapViewCoordinate(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        view.setRegion(region, animated: true)
    }

    // 新しい座標に視点を移動させるメソッドを追加
    func moveToNewCoordinate(_ coordinate: CLLocationCoordinate2D) {
        updateMapViewCoordinate(coordinate: coordinate)
    }
    
    init() {
        // CLLocationManagerを初期化して、現在の位置を取得
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        if let currentLocation = locationManager.location {
            self.centerCoordinate = currentLocation.coordinate
        }  else {
            // 位置情報が取得できない場合のデフォルトの座標
            // 都心です
            self.centerCoordinate = CLLocationCoordinate2D(latitude: 35.68154, longitude: 139.752498)
        }
        
        // モーダルにてピンがタップされた際に座標を受け取って視点を移動する
        self.sharedLocationManager = SharedLocationManager()
        self.sharedLocationManager = sharedLocationManager
        setupLocationManager()
        setupNotificationObserver()
        
        // 通知
        checkUserDefaultsForFalseAndScheduleNotification()
    }
    
    func makeAnnotationArry (posts: [postResponse]) -> [MKAnnotation] {
        var annotations = [MKAnnotation]()
        for post in posts {
            let imageUrl = "https://backend.2xseitest.workers.dev/api/" + post.key
            print("index \(post.id) imageUrl \(imageUrl)")
            let newLocation = CustomPointAnnotation(imageUrl: imageUrl, userName: post.userName, latitude: post.latitude, longitude: post.longitude, createdAt: post.createdAt, polygonCenter: CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude), polygonRadius: 400, isInPolygon: UserDefaults.standard.bool(forKey: imageUrl), isPublic: post.isPublic, userId: post.userId)
            newLocation.coordinate = CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude)
            newLocation.title = post.title.isEmpty ? "不明" : post.title
            newLocation.subtitle = ""
            annotations.append(newLocation)
        }
        return annotations
    }
    
    func makeUIView(context: Context) -> MKMapView {
        view.pointOfInterestFilter = .excludingAll
        view.delegate = context.coordinator
        view.showsUserLocation = true // ユーザーの位置を表示
        view.showsCompass = false     // コンパスoff(下で設定する)
        // CustomAnnotationViewの設定
        view.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        view.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        view.mapType = .mutedStandard
        
        // CustomAnnotationViewクラスを識別子と共に登録
        view.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            

        // 現在位置に視点を移動
        if let currentLocation = locationManager.location {
            let region = MKCoordinateRegion(
                center: currentLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            view.setRegion(region, animated: true)
        }
        
        // SharedLocationManagerから座標を取得して視点を更新
        if let coordinate = sharedLocationManager.selectedLocation {
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            view.setRegion(region, animated: true)
        }

        // ユーザートラッキングボタンの追加
        let userTrackingButton = MKUserTrackingButton(mapView: view)
        userTrackingButton.backgroundColor = UIColor(white: 1, alpha: 1)

        // ボタンに影を追加
        userTrackingButton.layer.shadowColor = UIColor.black.cgColor
        userTrackingButton.layer.shadowOpacity = 0.5
        userTrackingButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        userTrackingButton.layer.shadowRadius = 5

        // コンパスボタンの追加
        let compassButton = MKCompassButton(mapView: view)
        compassButton.compassVisibility = .adaptive

        // コンパスにも同様のスタイリングを適用
        compassButton.layer.shadowColor = UIColor.black.cgColor
        compassButton.layer.shadowOpacity = 0.5
        compassButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        compassButton.layer.shadowRadius = 5
        
        // ユーザートラッキングボタンとコンパスボタンのレイアウトを設定
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userTrackingButton)
        view.addSubview(compassButton)
        
        // 更新ボタンの設定
        let updateButton = UIButton(type: .system)
        updateButton.setTitle("   画面を更新する   ", for: .normal) // ボタンのテキストを設定
        updateButton.tintColor = .black // アイコンの色を設定
        updateButton.backgroundColor = UIColor.white
        updateButton.layer.cornerRadius = 20
        // ボタンに影を追加
        updateButton.layer.shadowColor = UIColor.black.cgColor
        updateButton.layer.shadowOpacity = 0.5
        updateButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        updateButton.layer.shadowRadius = 5
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        updateButton.addTarget(context.coordinator, action: #selector(Coordinator.updateButtonTapped), for: .touchUpInside)

        view.addSubview(updateButton)

        // Auto Layoutの制約を設定
        NSLayoutConstraint.activate([
            userTrackingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            userTrackingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            userTrackingButton.widthAnchor.constraint(equalTo: userTrackingButton.heightAnchor),

            compassButton.topAnchor.constraint(equalTo: updateButton.bottomAnchor, constant: 10),
            compassButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            updateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            updateButton.heightAnchor.constraint(equalTo: userTrackingButton.heightAnchor) 
        ])

        return view
    }

    // annotations 配列内の全てのアノテーションを MKMapView に追加
    func updateUIView(_ view: MKMapView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var sharedData = SharedAnnotationData()
        var previousPosts = [postResponse]()

        init(_ parent: MapView) {
            self.parent = parent
        }
        
        // 2sei !!!!!!  ここ！！！！！！！！
        @objc func updateButtonTapped() {
            // ここにボタンがタップされた時の処理を記述
            print("更新ボタンがタップされました")
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // ユーザーの現在位置を取得
             guard let userLocation = mapView.userLocation.location else {
                 print("現在位置を取得できません")
                 return nil
             }

             let currentLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)

            for annotation in mapView.annotations {
                if let customAnnotation = annotation as? CustomPointAnnotation {
                    let isInPolygon = isCoordinate(currentLocation, insidePolygonWithCenter: customAnnotation.polygonCenter, radius: customAnnotation.polygonRadius, imageUrl: customAnnotation.imageUrl)
                    
                    // UserDefaultsに状態を保存
                    UserDefaults.standard.set(isInPolygon, forKey: customAnnotation.imageUrl)
                    
                    // UserDefaultsから状態を読み込む
                    let savedState = UserDefaults.standard.bool(forKey: customAnnotation.imageUrl)
                    // ここでsavedStateに基づいてview.canShowCalloutを設定
                    if let view = mapView.view(for: customAnnotation) {
                        view.canShowCallout = savedState
                    }
                }
            }
            
            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: annotation)
                view.clusteringIdentifier = "cluster"
                
                view.canShowCallout = true
                
                // クラスタに含まれるアノテーションの数のみを表示...にならない！！
                // これってタイトル消せないんですか？？　検証します！！
                let countLabel = UILabel()
                countLabel.text = "ピンの数: \(cluster.memberAnnotations.count)"
                view.detailCalloutAccessoryView = countLabel
                
                // callOutの右側にボタンを追加
                // こいつの存在消してcalloutだけに判定つけたいな
                let infoButton = UIButton(type: .detailDisclosure)
                view.rightCalloutAccessoryView = infoButton
                
                // collisionModeを.circleに設定
                view.collisionMode = .circle
                
                return view
            } else if let customAnnotation = annotation as? CustomPointAnnotation {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation) as? CustomAnnotationView ?? CustomAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
                
                view.clusteringIdentifier = "cluster"
                view.collisionMode = .circle
                                
                let imageView = view.leftCalloutAccessoryView as? UIImageView ?? UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                
                view.canShowCallout = true
                
//                // IsInPolygonの値に応じて処理が変わるやつ
//                if UserDefaults.standard.bool(forKey: customAnnotation.imageUrl) {
                    let infoButton = UIButton(type: .detailDisclosure)
                    view.rightCalloutAccessoryView = infoButton
                    // イメージビューの設定
                    imageView.contentMode = .scaleAspectFill
                    view.leftCalloutAccessoryView = imageView
                    // 画像をクリア
                    imageView.image = nil
//                }
                
                let titleText = UILabel()
                view.detailCalloutAccessoryView = titleText
                
                // ピンを表示するときに正しいURLかどうかを確認するため
                view.imageUrl = customAnnotation.imageUrl
                
                // キャッシュを確認
                let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                let hashValue = customAnnotation.imageUrl.hash
                let fileURL = cacheDirectory.appendingPathComponent("\(hashValue)")
                
                if let diskCachedImage = UIImage(contentsOfFile: fileURL.path) {
                    // ディスクキャッシュから画像を読み込む
                    imageView.image = diskCachedImage
                } else {
                    if let url = URL(string: customAnnotation.imageUrl) {
                        let task = URLSession.shared.dataTask(with: url) { data, response, error in
                            if let data = data, let downloadedImage = UIImage(data: data) {
                                // ダウンロードした画像をディスクキャッシュに保存
                                try? data.write(to: fileURL, options: [.atomicWrite])
                                
                                DispatchQueue.main.async {
                                    // アノテーションビューが再利用されていないことを確認
                                    if view.imageUrl == customAnnotation.imageUrl {
                                        imageView.image = downloadedImage
                                    }
                                }
                            }
                        }
                        task.resume()
                    }
                }
                return view
            }
            return nil
        }
        
        // ポリゴン内に現在位置が入っているかチェックする
        func isCoordinate(_ coordinate: CLLocationCoordinate2D, insidePolygonWithCenter center: CLLocationCoordinate2D, radius: CLLocationDistance, imageUrl: String) -> Bool {
            // UserDefaultsから状態を読み込む
            let savedState = UserDefaults.standard.bool(forKey: imageUrl)

            // すでにポリゴン内にいると判定されている場合は常にtrueを返す
            if savedState {
                return true
            }

            let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
            let coordinateLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

            let distance = centerLocation.distance(from: coordinateLocation)

            // 距離が半径以下ならtrueを返す
            return distance <= radius
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let region = mapView.region

            let maxLatitude = region.center.latitude + (region.span.latitudeDelta / 2.0)
            let minLatitude = region.center.latitude - (region.span.latitudeDelta / 2.0)
            let maxLongitude = region.center.longitude + (region.span.longitudeDelta / 2.0)
            let minLongitude = region.center.longitude - (region.span.longitudeDelta / 2.0)

            let latitudeDifference = maxLatitude - minLatitude
            let longitudeDifference = maxLongitude - minLongitude

            // 左下の座標
            let bottomLeftLatitude = minLatitude
            let bottomLeftLongitude = minLongitude
            
        
            print("緯度の差: \(latitudeDifference)")
            print("経度の差: \(longitudeDifference)")
            print("左下の座標: \(bottomLeftLatitude), \(bottomLeftLongitude)")
            
            fetchPostsDataByArea(latitude: bottomLeftLatitude, longitude: bottomLeftLongitude, latitudeDelta: latitudeDifference, longitudeDelta: latitudeDifference, completion: { data in
                let postsData = data
//                print("postsData: \(postsData)")
//                print("previousPosts: \(self.previousPosts)")
                let newPosts = self.comparePostsData(postsData: postsData, previousPosts: self.previousPosts)
                print("newPosts: \(newPosts)")
                let newAnnotations = self.makeAnnotationArry(posts: newPosts)
                print("前のピンの数: \(self.previousPosts.count)")
                print("新しいピンの数: \(newAnnotations.count)")
                // mapView.annotationsのうち、newAnnotationsに含まれていないものを削除
                for annotation in mapView.annotations {
                    // 画面外のアノテーションは削除する
                    if !mapView.visibleMapRect.contains(MKMapPoint(annotation.coordinate)) {
                        mapView.removeAnnotation(annotation)
                    }
                }
                mapView.addAnnotations(newAnnotations)
                print("ピンの数: \(mapView.annotations.count)")
                // ビューを更新
                mapView.setNeedsDisplay()
                self.previousPosts = postsData
            })
        }
        
        // postsDataとpreviousPostsを比較して、新しいものとpreviousPostsにないものを返す
        func comparePostsData(postsData: [postResponse], previousPosts: [postResponse]) -> [postResponse] {
            var newPosts: [postResponse] = []
            for post in postsData {
                if !previousPosts.contains(where: { $0.id == post.id }) {
                    newPosts.append(post)
                }
            }
            return newPosts
        }
        
        func makeAnnotationArry (posts: [postResponse]) -> [MKAnnotation] {
            var annotations = [MKAnnotation]()
            for post in posts {
                let imageUrl = "https://backend.2xseitest.workers.dev/api/" + post.key
                print("index \(post.id) imageUrl \(imageUrl)")
                let newLocation = CustomPointAnnotation(imageUrl: imageUrl, userName: post.userName, latitude: post.latitude, longitude: post.longitude, createdAt: post.createdAt, polygonCenter: CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude), polygonRadius: 400, isInPolygon: UserDefaults.standard.bool(forKey: imageUrl), isPublic: post.isPublic, userId: post.userId)
                newLocation.coordinate = CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude)
                newLocation.title = post.title.isEmpty ? "不明" : post.title
                newLocation.subtitle = ""
                annotations.append(newLocation)
            }
            return annotations
        }
            
        // calloutのボタンがタップされた時に呼ばれる
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if control == view.rightCalloutAccessoryView {
                if let cluster = view.annotation as? MKClusterAnnotation {
                    // クラスタに含まれるアノテーションの情報を集める
                    let annotations = cluster.memberAnnotations.compactMap { $0 as? CustomPointAnnotation }
                    
                    // UserDefaultsから指定されたキーのbool値を取得する
                    func isAnnotationEnabled(annotation: CustomPointAnnotation) -> Bool {
                        return UserDefaults.standard.bool(forKey: annotation.imageUrl)
                    }

                    // UserDefaultsに保存されたboolがtrueのアノテーションだけをフィルタリング
                    let filteredAnnotations = annotations.filter(isAnnotationEnabled)

                    // クラスタ内のフィルタリングされたピンの情報を SharedAnnotationData にセット
                    DispatchQueue.main.async {
                        self.sharedData.clusterAnnotations = filteredAnnotations
                        
                        // SwiftUI モーダルビューを表示
                        let modalView = ClusterAnnotationModalView(sharedData: self.sharedData)
                        let hostingController = UIHostingController(rootView: modalView)
                        if let topController = self.getTopViewController() {
                            topController.present(hostingController, animated: true, completion: nil)
                        }
                    }
                } else if let customAnnotation = view.annotation as? CustomPointAnnotation {
                    sharedData.selectedAnnotation = customAnnotation
                    
                    DispatchQueue.main.async {
                        let modalView = AnnotationModalView(sharedData: self.sharedData)
                        let hostingController = UIHostingController(rootView: modalView)
                        
                        if let topController = self.getTopViewController() {
                            topController.present(hostingController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }

        //  アプリケーションの最上位の UIViewController を取得することによって modal 表示を可能にする
        //  present呼び出せない問題解決！！！！ (非推奨だけど...)
        func getTopViewController() -> UIViewController? {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                return topController
            }
            return nil
        }

        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
        }
    }
}

//
//#Preview{
//    MapView()
//        .edgesIgnoringSafeArea(.all)
//}
