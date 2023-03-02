//
//  RecordingError.swift
//  Memo
//
//  Created by Aye Chan on 3/2/23.
//

import Foundation

enum RecordingError: LocalizedError {
    case permissionDenied
    case systemFailed(LocalizedError)
    case unknown
}

extension RecordingError {
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone Access Denied"
        case .systemFailed(let error):
            return error.errorDescription
        case .unknown:
            return "Unknown Error"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "You need to allow the microphone access to record the audio."
        case .systemFailed(let error):
            return error.recoverySuggestion
        case .unknown:
            return "Oops! The unknown error occurs."
        }
    }
}
