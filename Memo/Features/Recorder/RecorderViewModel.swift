//
//  RecorderViewMode.swift
//  Memo
//
//  Created by Aye Chan on 3/2/23.
//

import Combine
import SwiftUI
import Foundation
import AVFoundation

class RecorderViewModel: ObservableObject {
    var audioSession: AVAudioSession = .sharedInstance()
    var audioRecorder: AVAudioRecorder?

    @Published var error: RecordingError?
    @Published var state: RecordingState = .idle
    @Published var samples: [Float] = []
    @Published var currentTime: TimeInterval = 0

    var didMoveToBackground: Bool = false

    var cancellable: (any Cancellable)?
    var timer = Timer.publish(every: 0.005, on: .main, in: .common)

    init() { }

    func onCheckPermission() async {
        switch audioSession.recordPermission {
        case .undetermined:
            _ = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
                audioSession.requestRecordPermission {
                    continuation.resume(returning: $0)
                }
            }
            await onCheckPermission()
        case .granted:
            break
        default:
            await MainActor.run {
                self.error = .permissionDenied
            }
        }
    }

    func onChangeScenePhase(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            if didMoveToBackground {
                didMoveToBackground = false
                Task {
                    await onCheckPermission()
                }
            }
        case .background:
            didMoveToBackground = true
        default: break
        }
    }

    func onTapRecordButton() {
        switch state {
        case .idle:
            onStartRecording()
        case .recording:
            onPauseRecording()
        case .paused:
            onResumeRecording()
        }
    }

    func onTapDeleteRecording() {
        Task {
            onStopTimer()
            let filePath = audioRecorder?.url
            audioRecorder?.stop()
            audioRecorder = nil
            await MainActor.run {
                samples.removeAll()
                withAnimation {
                    state = .idle
                }
            }
            guard let filePath, FileManager.default.fileExists(atPath: filePath.relativePath) else { return }
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {
                await onHandleError(error)
            }
        }
    }

    func onTapStopRecording() {
        Task {
            onStopTimer()
            audioRecorder?.stop()
            audioRecorder = nil
            await MainActor.run {
                withAnimation {
                    samples = []
                    state = .idle
                }
            }
        }
    }

    private func onStartRecording() {
        Task {
            do {
                /// set up audio session
                try audioSession.setCategory(.playAndRecord)

                /// prepare file path
                let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                var filePath = directory.appendingPathComponent("Memo.m4a")
                var count: Int = 1
                while FileManager.default.fileExists(atPath: filePath.relativePath) {
                    let newFileName = "Memo-\(count).m4a"
                    filePath.deleteLastPathComponent()
                    filePath = filePath.appendingPathComponent(newFileName)
                    count += 1
                }

                /// set up audio player
                let settings: [String: Any] = [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVSampleRateKey: 44100.0,
                    AVNumberOfChannelsKey: 1
                ]
                audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
                audioRecorder?.isMeteringEnabled = true
                audioRecorder?.prepareToRecord()
                audioRecorder?.record()

                onStartTimer()

                await MainActor.run {
                    withAnimation {
                        state = .recording
                    }
                }
            } catch  {
                await onHandleError(error)
            }
        }
    }

    private func onPauseRecording() {
        Task {
            onStopTimer()
            audioRecorder?.pause()
            await MainActor.run {
                withAnimation {
                    state = .paused
                }
            }
        }
    }

    private func onResumeRecording() {
        Task {
            onStartTimer()
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            await MainActor.run {
                withAnimation {
                    state = .recording
                }
            }
        }
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

    private func onStartTimer() {
        guard cancellable == nil else { return }
        timer = Timer.publish(every: 0.005, on: .main, in: .common)
        cancellable = timer.connect()
    }

    private func onStopTimer() {
        guard cancellable != nil else { return }
        cancellable?.cancel()
        cancellable = nil
    }

    func onUpdateAveragePower() {
        guard let audioRecorder else { return }
        audioRecorder.updateMeters()
        let currentAmplitude = 1 - pow(10, audioRecorder.averagePower(forChannel: 0) / 20)
        samples += [currentAmplitude]
        currentTime = audioRecorder.currentTime
    }
}
