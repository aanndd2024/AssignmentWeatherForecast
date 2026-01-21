//
//  LocationManager.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 20/01/26.
//
import CoreLocation
import Foundation

protocol LocationServiceProtocol {
    var authorizationStatus: CLAuthorizationStatus { get }
    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)? { get set }
    func requestLocationPermission()
    func getCurrentLocation() async throws -> CLLocationCoordinate2D
}

final class LocationService: NSObject, LocationServiceProtocol {

    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?

    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestLocationPermission() {
        AppLogger.shared.location.info("Requesting location permission: \(self.locationManager.authorizationStatus.rawValue)" )
        locationManager.requestWhenInUseAuthorization()
    }

    func getCurrentLocation() async throws -> CLLocationCoordinate2D {
        // Check authorization first
        let status = locationManager.authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            throw WeatherError.locationPermissionDenied
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            locationManager.requestLocation()
        }
    }
}

extension LocationService: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        AppLogger.shared.location.info("Authorization status changed: \(status.rawValue)" )

        switch status {
        case .notDetermined:
            AppLogger.shared.location.info("Not Determined" )

        case .restricted:
            AppLogger.shared.location.info("Restricted" )

        case .denied:
            AppLogger.shared.location.info("Denied" )

        case .authorizedAlways:
            AppLogger.shared.location.info("Authorized Always" )

        case .authorizedWhenInUse:
            AppLogger.shared.location.info("Authorized When In Use" )

        @unknown default:
            AppLogger.shared.location.info("Unknown" )

        }
        
        onAuthorizationChange?(status)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            continuation?.resume(throwing: WeatherError.locationError)
            continuation = nil
            return
        }
        AppLogger.shared.location.privateInfo("Coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")

        continuation?.resume(returning: location.coordinate)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AppLogger.shared.network.error("Location error: \(error.localizedDescription)")

        continuation?.resume(throwing: error)
        continuation = nil
    }
}





