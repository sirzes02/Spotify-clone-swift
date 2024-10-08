//
//  PlaybackPresenter.swift
//  spotify-sub
//
//  Created by Santiago Varela on 24/08/24.
//

import AVFoundation
import Foundation
import UIKit

protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
}

final class PlaybackPresenter {
    enum Constants {
        enum Values {
            static let volumeDefault: Float = 0.5
        }
    }

    static let shared = PlaybackPresenter()

    var playerVC: PlayerViewController?

    private var track: AudioTrack?
    private var tracks = [AudioTrack]()

    var index = 0

    var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        } else if playerQueue != nil, !tracks.isEmpty {
            return tracks[index]
        }

        return nil
    }

    var player: AVPlayer?
    var playerQueue: AVQueuePlayer?

    func startPlayback(from viewController: UIViewController, track: AudioTrack) {
        guard let url = URL(string: track.preview_url ?? "") else {
            return
        }
        player = AVPlayer(url: url)
        player?.volume = Constants.Values.volumeDefault

        tracks = []
        self.track = track

        let vc = PlayerViewController()
        vc.title = track.name
        vc.dataSource = self
        vc.delegate = self

        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            self?.player?.play()
        }

        playerVC = vc
    }

    func startPlayback(from viewController: UIViewController, tracks: [AudioTrack]) {
        self.tracks = tracks
        track = nil

        playerQueue = AVQueuePlayer(items: tracks.compactMap {
            guard let url = URL(string: $0.preview_url ?? "") else {
                return nil
            }
            return AVPlayerItem(url: url)
        })
        playerQueue?.volume = Constants.Values.volumeDefault

        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self

        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            self?.playerQueue?.play()
        }

        playerVC = vc
    }
}

extension PlaybackPresenter: PlayerViewControllerDelegate {
    func didTapPlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        } else if let player = playerQueue {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        }
    }

    func didTapNext() {
        if tracks.isEmpty {
            player?.pause()
        } else if let player = playerQueue {
            player.advanceToNextItem()
            index += 1
            playerVC?.refreshUI()
        }
    }

    func didTapBack() {
        if tracks.isEmpty {
            player?.pause()
            player?.play()
        } else if let firstItem = playerQueue?.items().first {
            playerQueue?.pause()
            playerQueue?.removeAllItems()
            playerQueue = AVQueuePlayer(items: [firstItem])
            playerQueue?.play()
            playerQueue?.volume = Constants.Values.volumeDefault
        }
    }

    func didSlideSlider(_ value: Float) {
        player?.volume = value
    }
}

extension PlaybackPresenter: PlayerDataSource {
    var songName: String? {
        return currentTrack?.name
    }

    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }

    var imageURL: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
}
