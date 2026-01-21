//
//  ImageCache.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 17/01/26.
//
import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100 // Max 100 images
        cache.totalCostLimit = 20 * 1024 * 1024 // ~20 MB
    }
    
    func loadImage(from url: URL) async throws -> UIImage {
        let key = url.absoluteString as NSString
        
        // ✅ 1. Check cache first
        if let cached = cache.object(forKey: key) {
            AppLogger.shared.location.info("Loaded image from cache: \(key))")
            return cached
        }
        
        // ✅ 2. Validate URL scheme (security best practice)
        guard url.scheme == "https" else {
            throw WeatherError.invalidImageData // or a more specific error
        }
        
        // ✅ 3. Fetch data
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // ✅ 4. Validate HTTP status (optional but recommended)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw WeatherError.invalidImageData
        }
        
        // ✅ 5. Decode image on a background queue to avoid blocking main thread
        guard let image = await decodeImage(from: data) else {
            throw WeatherError.invalidImageData
        }
        
        // ✅ 6. Cache and return
        cache.setObject(image, forKey: key, cost: data.count)
        return image
    }
    
    // ✅ Decode off-main-thread to prevent UI jank
    private func decodeImage(from data: Data) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let image = UIImage(data: data, scale: UIScreen.main.scale)
                continuation.resume(returning: image)
            }
        }
    }
}
