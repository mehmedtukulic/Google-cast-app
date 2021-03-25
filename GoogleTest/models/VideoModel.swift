//
//  VideoModel.swift
//  GoogleTest
//
//  Created by Mehmed Tukulic on 25/03/2021.
//

import Foundation
import UIKit

struct Videos: Decodable{
    let videos: [Video]
}

struct Video: Decodable {
    let title: String
    let sources: [String]
}


struct VideoModel {
    let title: String
    let thumbnail: UIImage
}
