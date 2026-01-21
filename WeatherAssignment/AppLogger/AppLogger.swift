//
//  AppLogger.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 20/01/26.
//

import os
import Foundation

final class AppLogger {

    // MARK: - Shared
    static let shared = AppLogger()

    // MARK: - Subsystem
    private let subsystem =
        Bundle.main.bundleIdentifier ?? "com.weather.app"

    // MARK: - Loggers
    let location: Logger
    let network: Logger
    let weather: Logger
    let ui: Logger

    // MARK: - Init
    private init() {
        location = Logger(subsystem: subsystem, category: "Location")
        network  = Logger(subsystem: subsystem, category: "Network")
        weather  = Logger(subsystem: subsystem, category: "Weather")
        ui       = Logger(subsystem: subsystem, category: "UI")
    }
}

extension Logger {
    func debugOnly(_ message: String) {
        #if DEBUG
        self.debug("\(message)")
        #endif
    }
}

extension Logger {
    func privateInfo(_ message: String) {
        self.info("\(message, privacy: .private)")
    }
}


