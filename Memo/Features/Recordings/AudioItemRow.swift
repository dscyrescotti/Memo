//
//  AudioItemRow.swift
//  Memo
//
//  Created by Aye Chan on 3/4/23.
//

import SwiftUI
import AVFoundation

struct AudioItemRow: View {
    @EnvironmentObject var viewModel: RecordingsViewModel
    let item: AudioItem
    var expandsRow: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text(item.name)
                .font(.headline.bold())
            HStack {
                Text(item.createdAt.formatDate())
                Spacer()
                if !expandsRow {
                    durationView
                }
            }
            .foregroundColor(.secondary)
            .font(.caption)
            if expandsRow {
                audioPlayerTool
                    .transition(.opacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.onExpandAudioRow(with: item)
        }
    }

    @ViewBuilder
    var durationView: some View {
        let seconds = item.duration
        let showsHour = seconds.hour > 0
        HStack(spacing: 0.2) {
            if showsHour {
                timeBox(for: seconds.hour)
            }
            timeBox(for: seconds.minute, appending: showsHour ? ":" : "")
            timeBox(for: seconds.second, appending: ":")
        }
    }

    func timeBox(for value: Int, appending text: String? = nil, width: CGFloat = 10) -> some View {
        HStack(spacing: 0.2) {
            let digits = value.digits()
            Group {
                if let text {
                    Text(text)
                }
                if digits.count == 1 {
                    Text("0")
                }
                ForEach(0..<digits.count, id: \.self) { index in
                    Text("\(digits[index])")
                }
            }
        }
    }

    var audioPlayerTool: some View {
        VStack {
            Slider(value: $viewModel.currentTime, in: 0...item.duration) { isEditing in
                if !isEditing {
                    viewModel.onSlideTimeline()
                }
            }
            HStack(spacing: 30) {
                Spacer()
                Button {
                    viewModel.onSkipBackward()
                } label: {
                    Image(systemName: "gobackward.10")
                }
                Button {
                    if viewModel.audioState == .playing {
                        viewModel.onPauseAudio()
                    } else {
                        viewModel.onPlayAudio()
                    }
                } label: {
                    if viewModel.audioState == .playing {
                        Image(systemName: "pause.fill")
                    } else {
                        Image(systemName: "play.fill")
                    }
                }
                .font(.largeTitle)
                Button {
                    viewModel.onSkipForward()
                } label: {
                    Image(systemName: "goforward.10")
                }
                Spacer()
            }
            .buttonStyle(BorderlessButtonStyle())
            .font(.title2)
            .fontWeight(.semibold)
            .tint(.black)
        }
    }
}
