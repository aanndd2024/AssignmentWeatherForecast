//
//  ImageCache.swift
//  WeatherAssignment
//
//  Created by Anand Yadav on 17/01/26.
//
import Foundation
import UIKit

class ImageCache {
    private let cache = NSCache<NSString, UIImage>()
    
    func loadImage(from url: URL) async throws -> UIImage {
        if let cached = cache.object(forKey: url.absoluteString as NSString) {
            return cached
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw WeatherError.invalidImageData
        }
        
        cache.setObject(image, forKey: url.absoluteString as NSString)
        return image
    }
}
