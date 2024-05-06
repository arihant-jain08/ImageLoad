//
//  ImageCell.swift
//  ImageDisplay
//
//  Created by Arihant Jain on 02/05/24.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var cellDisplayImage: UIImageView!
    var task: URLSessionDataTask?
        
    override func prepareForReuse() {
        super.prepareForReuse()
        // Cancel the task when the cell is reused
        task?.cancel()
        cellDisplayImage.image = nil // Clear the image
    }
}
