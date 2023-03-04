//
//  AudioItemRow.swift
//  Memo
//
//  Created by Aye Chan on 3/4/23.
//

import SwiftUI
import AVFoundation

struct AudioItemRow: View {
    let item: AudioItem

    var body: some View {
        VStack(alignment: .leading) {
            Text(item.name)
                .font(.headline)
            HStack {
                Text(item.createdAt.formatDate())
                Spacer()
                durationView
            }
            .foregroundColor(.secondary)
            .font(.caption)
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
}
