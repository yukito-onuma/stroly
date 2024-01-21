//
//  map.swift
//  stroly
//
//  Created by 小平暖太 on 2023/11/10.
//

import SwiftUI
import MapKit //地図や位置情報を扱うためのクラスや機能を提供

import AVFoundation

struct map: View {
    @State private var locationManager = CLLocationManager()//デバイスの位置情報や方向を管理するクラス
    @State private var position: MapCameraPosition = .automatic //カメラの位置を指定するための状態変数
    @State private var positionPin: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.33500, longitude: -122.00889)
    // appleParkの座標(例)
    
    @State private var pinVisibilityStates: [Bool] = Array(repeating: true, count: 100)

    @State private var isPinVisible = true
    @State private var visibleCamera: MapCamera? = nil
    
    

    let size: CGFloat = 50
    let outerWidth: CGFloat = 2

    var body: some View {
        Map(position: $position, interactionModes: .all) {
            // 現在地を示すピン
            UserAnnotation()
        }
        .mapControls { //地図のコントロールを指定
            MapUserLocationButton() //現在位置ボタン
            MapCompass()
                .padding(.leading) //コンパス
        }
        .onAppear{
            locationManager.requestWhenInUseAuthorization() //位置情報を使用する許可を求める為に使用
            locationManager.startUpdatingLocation() //デバイスの現在位置の更新を開始するために使用
            position = .userLocation(fallback: .automatic) //現在地を表示
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
