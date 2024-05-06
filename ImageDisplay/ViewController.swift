//
//  ViewController.swift
//  ImageDisplay
//
//  Created by Arihant Jain on 02/05/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    let apiURL = "https://acharyaprashant.org/api/v2/content/misc/media-coverages?"
    let limit = 100
    var imageUrls = [String]()
    var imageLoadTasks = [IndexPath: URLSessionDataTask]()
    var currentOffset = 0
    var isLoadingData = false // Flag to prevent multiple API calls
    
    // Initialize ImageManager
    let imageManager = ImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewOutlet.dataSource = self
        collectionViewOutlet.delegate = self
        fetchImageUrlsFromAPI()
    }
    
    func fetchImageUrlsFromAPI() {
        guard !isLoadingData else { return } // Prevent multiple API calls
        
        isLoadingData = true
        
        let urlString = "\(apiURL)limit=\(limit)&offset=\(currentOffset)"
        guard let url = URL(string: urlString) else {
            print("Invalid API URL")
            isLoadingData = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            defer { self?.isLoadingData = false } // Reset the flag
            
            guard let data = data else {
                print("No data received from API")
                return
            }
            
            do {
                let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                guard let items = jsonArray else {
                    print("Failed to parse JSON or JSON is empty")
                    return
                }
                
                for item in items {
                    guard let thumbnail = item["thumbnail"] as? [String: Any],
                          let domain = thumbnail["domain"] as? String,
                          let basePath = thumbnail["basePath"] as? String,
                          let key = thumbnail["key"] as? String else {
                        print("Invalid thumbnail object in JSON")
                        continue
                    }
                    
                    let imageUrl = "\(domain)/\(basePath)/0/\(key)"
                    self?.imageUrls.append(imageUrl)
                }
                
                DispatchQueue.main.async {
                    self?.collectionViewOutlet.reloadData()
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
        currentOffset += limit
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCell
            
        // Reset cell's image to placeholder while waiting for the image to load
        cell.cellDisplayImage.image = UIImage(named: "placeholder")
        
        // Cancel previous task for the cell if any
        if let previousTask = cell.task {
            previousTask.cancel()
        }
        
        let imageUrl = imageUrls[indexPath.item]
        
        // Use ImageManager to retrieve image lazily
        imageManager.retrieveImage(withUrl: imageUrl, for: indexPath, into: cell)
        
        // Check if reached the end of content to fetch more data
        let lastItem = indexPath.item
        if lastItem == imageUrls.count - 1 {
            fetchImageUrlsFromAPI() // Fetch more data
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Cancel the image loading task for the cell that is being scrolled out of view
        if let task = imageLoadTasks[indexPath] {
            task.cancel()
            imageLoadTasks.removeValue(forKey: indexPath)
        }
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = CGFloat(10)
        let availableWidth = collectionView.frame.width - paddingSpace * 4
        let itemWidth = availableWidth / 3
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}


