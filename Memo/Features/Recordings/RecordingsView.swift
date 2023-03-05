//
//  RecordingsView.swift
//  Memo
//
//  Created by Aye Chan on 3/2/23.
//

import SwiftUI

struct RecordingsView: View {
    @StateObject var viewModel = RecordingsViewModel()
    var body: some View {
        List(viewModel.audioItems) { item in
            AudioItemRow(
                item: item,
                expandsRow: viewModel.selectedAudioItem == item
            )
            .id(item.id)
            .swipeActions(allowsFullSwipe: true) {
                Button(role: .destructive) {
                    viewModel.onDeleteAudio(of: item)
                } label: {
                    Image(systemName: "trash.fill")
                }
                .tint(.red)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Audios")
        .navigationBarTitleDisplayMode(.inline)
        .errorAlert($viewModel.error) { error, completion in
            Button("Cancel", role: .cancel) {
                completion()
            }
        }
        .task {
            await viewModel.onLoadAudios()
        }
        .environmentObject(viewModel)
        .onReceive(viewModel.timer) { _ in
            viewModel.onUpdateTimeline()
        }
        .toolbar {
            EditButton()
        }
    }
}

