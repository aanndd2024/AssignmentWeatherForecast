//
//  LocationManager.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 20/01/26.
//
import CoreLocation
import Foundation
import os.log

// MARK: - Errors

enum LocationServiceError: Error {
    case notAuthorized
    case locationRequestInProgress
}

// MARK: - Protocol

@MainActor
protocol LocationServiceProtocol: AnyObject {
    /// Current authorization status
    var authorizationStatus: CLAuthorizationStatus { get }

    /// Called whenever authorization changes
    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)? { get set }

    /// Requests When-In-Use permission
    func requestLocationPermission()

    /// Returns the current device location
    func getCurrentLocation() async throws -> CLLocationCoordinate2D
}

// MARK: - Implementation

@MainActor
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
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func getCurrentLocation() async throws -> CLLocationCoordinate2D {
        let status = authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            throw LocationServiceError.notAuthorized
        }

        // Prevent concurrent calls to avoid lost continuations
        guard continuation == nil else {
            throw LocationServiceError.locationRequestInProgress
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            locationManager.requestLocation()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            Task { @MainActor in
                self.continuation?.resume(throwing: LocationServiceError.notAuthorized)
                self.continuation = nil
            }
            return
        }
        let coordinate = location.coordinate
        // Inside the nonisolated method, after getting coordinate:
        os_log("📍 Received location - Lat: %f, Lng: %f", log: .default, type: .info, coordinate.latitude, coordinate.longitude)
        
        Task { @MainActor in
            self.continuation?.resume(returning: location.coordinate)
            self.continuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.continuation?.resume(throwing: error)
            self.continuation = nil
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.onAuthorizationChange?(status)
        }
    }
}
