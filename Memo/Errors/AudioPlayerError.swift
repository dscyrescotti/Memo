//
//  AudioPlayerError.swift
//  Memo
//
//  Created by Aye Chan on 3/4/23.
//

import Foundation

enum AudioPlayerError: LocalizedError {
    case fileInvalid
    case systemFailed(LocalizedError)
    case unknown
}

extension AudioPlayerError {
    var errorDescription: String? {
        switch self {
        case .fileInvalid:
            return "Audio File Invalid"
        case .systemFailed(let error):
            return error.errorDescription
        case .unknown:
            return "Unknown Error"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .fileInvalid:
            return "Oops! The audio file is invalid."
        case .systemFailed(let error):
            return error.recoverySuggestion
        case .unknown:
            return "Oops! The unknown error occurs."
        }
    }
}
