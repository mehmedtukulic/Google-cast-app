//
//  ViewController.swift
//  GoogleTest
//
//  Created by Mehmed Tukulic on 25/03/2021.
//

import UIKit
import AVFoundation
import GoogleCast

class ViewController: UIViewController, GCKSessionManagerListener, GCKRemoteMediaClientListener, GCKRequestDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var castButton: GCKUICastButton!
    
    private var sessionManager: GCKSessionManager!
    private var selectedItem: MediaItem!
    
    var mediaList: MediaListModel?
    var rootItem: MediaItem? {
        didSet {
            tableView.reloadData()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sessionManager = GCKCastContext.sharedInstance().sessionManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sessionManager.add(self)
        setupTableView()
        loadMediaList()
        setPlayButtonEnabled()
    }
    
    private func setPlayButtonEnabled(){
        castButton.layer.cornerRadius = 12
        castButton.layer.borderWidth = 1
        castButton.layer.borderColor = UIColor.buttonBlue.cgColor
        castButton.backgroundColor = .white
        castButton.setTitleColor(.buttonBlue, for: .normal)
    }
    
}

// MARK: - STREAMING METHODS

extension ViewController {
    private func switchToLocalPlayback() {
        sessionManager.currentCastSession?.remoteMediaClient?.remove(self)
    }
    
    
    private func switchToRemotePlayback() {
        sessionManager.currentCastSession?.remoteMediaClient?.add(self)
    }
    
    private func playSelectedItemRemotely() {
        loadSelectedItem(byAppending: false)
        GCKCastContext.sharedInstance().presentDefaultExpandedMediaControls()
    }
    
    private func loadSelectedItem(byAppending appending: Bool) {
        print("enqueue item \(String(describing: selectedItem.mediaInfo))")
        if let remoteMediaClient = sessionManager.currentCastSession?.remoteMediaClient {
            let mediaQueueItemBuilder = GCKMediaQueueItemBuilder()
            mediaQueueItemBuilder.mediaInformation = selectedItem.mediaInfo
            mediaQueueItemBuilder.autoplay = true
            mediaQueueItemBuilder.preloadTime = TimeInterval(0)
            let mediaQueueItem = mediaQueueItemBuilder.build()
            
            if appending {
                let request = remoteMediaClient.queueInsert(mediaQueueItem, beforeItemWithID: kGCKMediaQueueInvalidItemID)
                request.delegate = self
            } else {
                let queueDataBuilder = GCKMediaQueueDataBuilder(queueType: .generic)
                queueDataBuilder.items = [mediaQueueItem]
                queueDataBuilder.repeatMode = remoteMediaClient.mediaStatus?.queueRepeatMode ?? .off
                
                let mediaLoadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
                mediaLoadRequestDataBuilder.queueData = queueDataBuilder.build()
                
                let request = remoteMediaClient.loadMedia(with: mediaLoadRequestDataBuilder.build())
                request.delegate = self
            }
        }
    }
    
    
// MARK: - GCKSessionManagerListener
    
    func sessionManager(_: GCKSessionManager, didStart session: GCKSession) {
        print("MediaViewController: sessionManager didStartSession \(session)")
        switchToRemotePlayback()
        
        //SESSION IS SUCCESSFULY CONNECTED, PLAY VIDEO IF ANY SELECTED
        if selectedItem != nil {
            playSelectedItemRemotely()
        }
    }
    
    func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?) {
        print("session ended with error: \(String(describing: error))")
        switchToLocalPlayback()
    }
    
    func sessionManager(_: GCKSessionManager,
                        didFailToResumeSession _: GCKSession, withError _: Error?) {
        switchToLocalPlayback()
    }
    
}

// MARK: - TABLEVIEW METHODS

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView(){
        let xib = UINib(nibName: "VideoCell", bundle: nil)
        tableView.register(xib, forCellReuseIdentifier: "VideoCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect())
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rootItem = rootItem {
            return rootItem.children.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        guard let item = rootItem?.children[indexPath.row] as? MediaItem else { return cell }
        
        if let imageURL = item.imageURL, let title = item.title {
            GCKCastContext.sharedInstance().imageCache?.fetchImage(for: imageURL, completion: { (_ image: UIImage?) -> Void in
                cell.setup(title: title, image: image ?? UIImage())
            })
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = rootItem?.children[indexPath.row] as? MediaItem, item.mediaInfo != nil {
            selectedItem = item
        }
        
        if sessionManager.hasConnectedCastSession() {
            playSelectedItemRemotely()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
}

// MARK: - LOAD MEDIA METHODS

extension ViewController : MediaListModelDelegate {
    func loadMediaList() {
        let mediaURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/CastVideos/f.json")
        mediaList = MediaListModel()
        mediaList?.delegate = self
        mediaList?.load(from: mediaURL!)
    }
    
    func mediaListModelDidLoad(_ list: MediaListModel) {
        rootItem = mediaList?.rootItem
        tableView.reloadData()
        
    }
    
    func mediaListModel(_ list: MediaListModel, didFailToLoadWithError error: Error?) {
        print("error loading media")
    }
    
}

