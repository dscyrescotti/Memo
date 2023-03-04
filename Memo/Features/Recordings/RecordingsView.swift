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
            AudioItemRow(item: item)
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
    }
}

