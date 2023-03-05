//
//  RecordingsViewModel.swift
//  Memo
//
//  Created by Aye Chan on 3/4/23.
//

import Combine
import SwiftUI
import Foundation
import AVFoundation

class RecordingsViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var audioItems: [AudioItem] = []
    @Published var error: RecordingError?
    @Published var selectedAudioItem: AudioItem?
    @Published var audioState: AudioState = .idle
    @Published var currentTime: Double = .zero

    var audioPlayer: AVAudioPlayer?
    var cancellable: (any Cancellable)?
    var timer = Timer.publish(every: 0.01, on: .main, in: .common)

    override init() {
        super.init()
    }

    func onLoadAudios() async {
        do {
            let fileManager = FileManager.default
            let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let items = try fileManager.contentsOfDirectory(atPath: url.relativePath)
                .compactMap {
                    AudioItem(name: $0, baseURL: url.relativePath)
                }
                .sorted(by: >)
            await MainActor.run {
                self.audioItems = items
            }
        } catch {
            await onHandleError(error)
        }
    }

    func onExpandAudioRow(with item: AudioItem) {
        guard item != selectedAudioItem else { return }
        if let audioPlayer {
            audioPlayer.delegate = nil
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            }
        }
        onStopTimer()
        currentTime = .zero
        audioState = .idle
        withAnimation {
            selectedAudioItem = item
        }
        self.audioPlayer = selectedAudioItem?.audioPlayer
        self.audioPlayer?.currentTime = currentTime
        self.audioPlayer?.delegate = self
    }

    func onPlayAudio() {
        guard let audioPlayer else { return }
        guard !audioPlayer.isPlaying else { return }
        currentTime = audioPlayer.currentTime
        audioState = .playing
        audioPlayer.play()
        onStartTimer()
    }

    func onPauseAudio() {
        guard let audioPlayer else { return }
        guard audioPlayer.isPlaying else { return }
        audioState = .paused
        audioPlayer.pause()
        onStopTimer()
    }

    func onSkipForward() {
        guard let audioPlayer else { return }
        let currentTime = min(audioPlayer.currentTime + 10, audioPlayer.duration)
        audioPlayer.currentTime = currentTime
        self.currentTime = currentTime

    }

    func onSkipBackward() {
        guard let audioPlayer else { return }
        let currentTime = max(audioPlayer.currentTime - 10, 0)
        audioPlayer.currentTime = currentTime
        self.currentTime = currentTime
    }

    func onSlideTimeline() {
        guard let audioPlayer else { return }
        audioPlayer.currentTime = currentTime
    }

    func onUpdateTimeline() {
        currentTime += 0.01
    }

    private func onHandleError(_ error: Error) async {
        await MainActor.run {
            if let error = error as? LocalizedError {
                self.error = .systemFailed(error)
            } else {
                self.error = .unknown
            }
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioState = .idle
        onStopTimer()
    }

    private func onStartTimer() {
        guard cancellable == nil else { return }
        timer = Timer.publish(every: 0.01, on: .main, in: .common)
        cancellable = timer.connect()
    }

    private func onStopTimer() {
        guard cancellable != nil else { return }
        cancellable?.cancel()
        cancellable = nil
    }

    func onDeleteAudio(of item: AudioItem) {
        Task {
            do {
                guard let index = audioItems.firstIndex(of: item) else { return }
                await MainActor.run {
                    _ = audioItems.remove(at: index)
                }
                try FileManager.default.removeItem(atPath: item.filePath.relativePath)
            } catch {
                await onHandleError(error)
            }
        }
    }
}
