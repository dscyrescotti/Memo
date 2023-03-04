//
//  RecordingsViewModel.swift
//  Memo
//
//  Created by Aye Chan on 3/4/23.
//

import Foundation

class RecordingsViewModel: ObservableObject {
    @Published var audioItems: [AudioItem] = []
    @Published var error: RecordingError?

    init() { }

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

    private func onHandleError(_ error: Error) async {
        await MainActor.run {
            if let error = error as? LocalizedError {
                self.error = .systemFailed(error)
            } else {
                self.error = .unknown
            }
        }
    }
}
