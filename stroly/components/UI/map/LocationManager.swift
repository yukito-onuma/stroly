//
//  LocationManager.swift
//  stroly
//
//  Created by 小平暖太 on 2023/11/06.
//

import UIKit
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation? = nil

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }

    // 現在地を更新するメソッドを追加
    func updateLocation() {
        locationManager.startUpdatingLocation()
    }
}

