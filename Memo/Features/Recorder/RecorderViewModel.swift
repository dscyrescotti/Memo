//
//  RecorderViewMode.swift
//  Memo
//
//  Created by Aye Chan on 3/2/23.
//

import SwiftUI
import Foundation
import AVFoundation

class RecorderViewModel: ObservableObject {
    var audioSession: AVAudioSession = .sharedInstance()
    var audioRecorder: AVAudioRecorder?

    @Published var error: RecordingError?
    @Published var state: RecordingState = .idle

    var didMoveToBackground: Bool = false

    init() { }

    func onLoadAudioSession() async {
        do {
            /// set up audio session
            try audioSession.setCategory(.playAndRecord)

            /// prepare file path
            let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let filePath = directory.appendingPathComponent("recording.m4a", conformingTo: .audio)

            /// set up audio player
            let settings: [String: Any] = [
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.medium,
                AVEncoderBitRateKey: 16
            ]
            audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
        } catch  {
            await MainActor.run {
                if let error = error as? LocalizedError {
                    self.error = .systemFailed(error)
                } else {
                    self.error = .unknown
                }
            }
        }
    }

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
            await onLoadAudioSession()
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
        withAnimation {
            switch state {
            case .idle:
                state = .recording
            case .recording:
                state = .paused
            case .paused:
                state = .recording
            }
        }
    }
}
