//
//  MediaItem.swift
//  GoogleTest
//
//  Created by Mehmed Tukulic on 26/03/2021.
//

import Foundation
import GoogleCast

/**
 * An object representing a media item (or a container group of media items).
 */
class MediaItem: NSObject {
  fileprivate(set) var title: String?
  fileprivate(set) var imageURL: URL?
  var children: [Any]!
  fileprivate(set) var mediaInfo: GCKMediaInformation?
  fileprivate(set) var parent: MediaItem?
  var isNowPlaying: Bool = false

  /** Initializer for constructing a group item.
   *
   * @param title The title of the item.
   * @param imageURL The URL of the image for this item.
   * @param parent The parent item of this item, if any.
   */
  init(title: String?, imageURL: URL?, parent: MediaItem?) {
    self.title = title
    children = [Any]()
    self.imageURL = imageURL
    self.parent = parent
  }

  /** Initializer for constructing a media item.
   *
   * @param mediaInfo The media information for this item.
   * @param parent The parent item of this item, if any.
   */
  convenience init(mediaInformation mediaInfo: GCKMediaInformation, parent: MediaItem) {
    let title = mediaInfo.metadata?.string(forKey: kGCKMetadataKeyTitle) ?? ""
    let imageURL = (mediaInfo.metadata?.images()[0] as? GCKImage)?.url
    self.init(title: title, imageURL: imageURL, parent: parent)
    self.mediaInfo = mediaInfo
  }

  /**
   * Factory method for constructing the special "now playing" item.
   *
   * @param parent The parent item of this item.
   */
  class func nowPlayingItem(withParent parent: MediaItem) -> MediaItem {
    let item = MediaItem(title: "Now Playing", imageURL: nil, parent: parent)
    item.isNowPlaying = true
    return item
  }
}
