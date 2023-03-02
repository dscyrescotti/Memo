//
//  RecorderView.swift
//  Memo
//
//  Created by Aye Chan on 3/2/23.
//

import SwiftUI

struct RecorderView: View {

    @Environment(\.scenePhase) var scenePhase
    @Namespace var buttonBaseNamespace
    @Namespace var buttonBorderNamespace

    @StateObject var viewModel = RecorderViewModel()

    var body: some View {
        VStack {
            Text("File Name")
            Text("00:00.00")
            Spacer()
            // waveform view
            Spacer()
            recordToolBar
        }
        .errorAlert($viewModel.error) { error, completion in
            switch error {
            case .permissionDenied:
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    Button("Open Settings") {
                        UIApplication.shared.open(url)
                        completion()
                    }
                    .fontWeight(.bold)
                }
                Button("Cancel", role: .cancel) {
                    completion()
                    Task {
                        await viewModel.onCheckPermission()
                    }
                }
            default:
                Button("Cancel", role: .cancel) {
                    completion()
                }
            }
        }
        .task {
            await viewModel.onCheckPermission()
        }
        .onChange(of: scenePhase) { newValue in
            viewModel.onChangeScenePhase(newValue)
        }
    }

    var recordToolBar: some View {
        HStack {
            Spacer()
            if viewModel.state == .paused {
                Button {

                } label: {
                    Image(systemName: "trash.fill")
                        .resizable()
                        .foregroundColor(.red)
                        .frame(width: 20, height: 20)
                        .padding(15)
                        .background(.pink.opacity(0.3), in: Circle())
                }
                .transition(.scale.combined(with: .move(edge: .leading)))
            }
            Spacer()
            Button {
                viewModel.onTapRecordButton()
            } label: {
                recordButtonLabel
            }
            Spacer()
            if viewModel.state == .paused {
                Button {

                } label: {
                    Image(systemName: "stop.fill")
                        .resizable()
                        .foregroundColor(.blue)
                        .frame(width: 20, height: 20)
                        .padding(15)
                        .background(.blue.opacity(0.3), in: Circle())
                }
                .transition(.scale.combined(with: .move(edge: .trailing)))
            }
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, ignoresSafeAreaEdges: .bottom)
    }

    @ViewBuilder
    var recordButtonLabel: some View {
        switch viewModel.state {
        case .idle:
            Capsule()
                .matchedGeometryEffect(id: "buttonBase", in: buttonBaseNamespace)
                .foregroundColor(.red)
                .frame(width: 50, height: 50)
                .padding(4)
                .overlay {
                    Capsule()
                        .stroke(lineWidth: 3)
                        .matchedGeometryEffect(id: "buttonStroke", in: buttonBorderNamespace)
                        .foregroundColor(.gray)
                }
        case .recording:
            Capsule()
                .matchedGeometryEffect(id: "buttonBase", in: buttonBaseNamespace)
                .foregroundColor(.clear)
                .frame(width: 120, height: 50)
                .overlay {
                    Image(systemName: "pause.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                }
                .padding(4)
                .overlay {
                    Capsule()
                        .stroke(lineWidth: 3)
                        .matchedGeometryEffect(id: "buttonStroke", in: buttonBorderNamespace)
                        .foregroundColor(.gray)
                }

        case .paused:
            Capsule()
                .matchedGeometryEffect(id: "buttonBase", in: buttonBaseNamespace)
                .foregroundColor(.pink.opacity(0.3))
                .frame(width: 120, height: 50)
                .overlay {
                    Text("Resume")
                        .foregroundColor(.red)
                        .font(.headline)
                }
                .padding(4)
                .overlay {
                    Capsule()
                        .stroke(lineWidth: 3)
                        .matchedGeometryEffect(id: "buttonStroke", in: buttonBorderNamespace)
                        .foregroundColor(.red)
                }
        }
    }
}

