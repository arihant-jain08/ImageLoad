//
//  ImageManager.swift
//  ImageDisplay
//
//  Created by Arihant Jain on 06/05/24.
//

import Foundation
import UIKit

class ImageManager {
    // NSCache for in-memory caching
    private let imageCache = NSCache<NSString, UIImage>()
    
    // URLCache for disk caching
    private let urlCache: URLCache = {
        let cache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "imageCache")
        return cache
    }()
    
    // Function to retrieve image from cache or fetch it if not cached
    func retrieveImage(withUrl imageUrl: String, for indexPath: IndexPath, into cell: ImageCell) {
        // Check if image is in memory cache
        if let cachedImage = imageCache.object(forKey: imageUrl as NSString) {
            cell.cellDisplayImage.image = cachedImage
            return
        }
        
        // If not in memory cache, check disk cache
        if let url = URL(string: imageUrl),
           let cachedResponse = urlCache.cachedResponse(for: URLRequest(url: url)),
           let image = UIImage(data: cachedResponse.data) {
            // Cache image in memory
            imageCache.setObject(image, forKey: imageUrl as NSString)
            // Update cell with cached image
            cell.cellDisplayImage.image = image
            return
        }
        
        // If not in disk cache, fetch from URL
        loadImage(from: imageUrl, for: indexPath, into: cell)
    }
    
    // Function to load image from URL
    private func loadImage(from imageUrl: String, for indexPath: IndexPath, into cell: ImageCell) {
        guard let url = URL(string: imageUrl) else {
            // Handle invalid URL
            cell.cellDisplayImage.image = UIImage(named: "placeholder")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let data = data, let image = UIImage(data: data) {
                // Cache image in memory
                self.imageCache.setObject(image, forKey: imageUrl as NSString)
                // Cache image in URL cache
                let cachedData = CachedURLResponse(response: response!, data: data)
                self.urlCache.storeCachedResponse(cachedData, for: URLRequest(url: url))
                
                DispatchQueue.main.async {
                    cell.cellDisplayImage.image = image
                }
            } else {
                // Handle error or set placeholder image if loading fails
                DispatchQueue.main.async {
                    cell.cellDisplayImage.image = UIImage(named: "placeholder")
                }
            }
        }
        
        task.resume()
    }
}

