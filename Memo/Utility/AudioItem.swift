//
//  AudioItem.swift
//  Memo
//
//  Created by Aye Chan on 3/4/23.
//

import Foundation
import AVFoundation

struct AudioItem: Identifiable, Comparable {
    static func < (lhs: AudioItem, rhs: AudioItem) -> Bool {
        lhs.createdAt < rhs.createdAt
    }

    var id: String { name }

    let name: String
    let baseURL: String
    let filePath: URL
    let audioPlayer: AVAudioPlayer

    init?(name: String, baseURL: String) {
        self.name = name
        self.baseURL = baseURL
        guard let filePath = Self.filePath(name: name, baseURL: baseURL), let audioPlayer = try? AVAudioPlayer(contentsOf: filePath) else {
            return nil
        }
        self.audioPlayer = audioPlayer
        self.filePath = filePath
    }

    var duration: TimeInterval {
        audioPlayer.duration
    }

    var createdAt: Date {
        let attributes = try? FileManager.default.attributesOfItem(atPath: filePath.relativePath)
        return attributes?[.creationDate] as? Date ?? .now
    }

    static func filePath(name: String, baseURL: String) -> URL? {
        guard var url = URL(string: baseURL) else {
            return nil
        }
        url.appendPathComponent(name, conformingTo: .audio)
        return url
    }
}
