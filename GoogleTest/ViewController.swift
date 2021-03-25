//
//  ViewController.swift
//  GoogleTest
//
//  Created by Mehmed Tukulic on 25/03/2021.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var videoList: [Video] = []
    
    private var videoModels: [VideoModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        getVideoList { (videos) in
            self.videoList = videos
            self.processCells()
        }
    }
    
    private func setupTableView(){
        let xib = UINib(nibName: "VideoCell", bundle: nil)
        tableView.register(xib, forCellReuseIdentifier: "VideoCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect())
    }
    
    private func processCells(){
        for video in videoList {
            let urlString = video.sources.first?.replacingOccurrences(of: "http", with: "https")
            
            if let image = getThumbnailImage(forUrl: URL(string: urlString!)!) {
                videoModels.append(.init(title: video.title, thumbnail: image))
            }
        }
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        let video = videoModels[indexPath.row]
        cell.setup(model: video)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }

}


extension ViewController {
    
    private func getVideoList(success: @escaping ([Video]) -> Void){
        if let url = URL(string: "https://api.mocki.io/v1/3aaab3e6") {
            // Create the url request
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
           URLSession.shared.dataTask(with: request) { data, response, error in
              if let data = data {
                  do {
                    let videos = try JSONDecoder().decode(Videos.self, from: data)
                    success(videos.videos)
                  } catch let error {
                     print(error)
                  }
               }
           }.resume()
        }
    }
    
    private func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }

        return nil
    }


}

