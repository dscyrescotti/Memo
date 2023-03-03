//
//  RecorderView.swift
//  Memo
//
//  Created by Aye Chan on 3/2/23.
//

import SwiftUI
import DSWaveformImage
import DSWaveformImageViews

struct RecorderView: View {
    @Environment(\.scenePhase) var scenePhase
    @Namespace var buttonBaseNamespace
    @Namespace var buttonBorderNamespace

    @StateObject var viewModel = RecorderViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                waveFormView
                recordToolBar
            }
            .navigationTitle("🎙Memo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        RecordingsView()
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                    .foregroundColor(.red)
                }
            }
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
        .onReceive(viewModel.timer) { _ in
            viewModel.onUpdateAveragePower()
        }
    }

    @ViewBuilder
    var waveFormView: some View {
        if viewModel.state == .idle {
            Text("Tap a red circle to start recording 👇")
                .font(.headline)
                .lineLimit(.none)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
        } else {
            GeometryReader { proxy in
                VStack {
                    WaveformLiveCanvas(
                        samples: viewModel.samples,
                        configuration: Waveform.Configuration(
                            style: .striped(.init(color: .red, width: 2, spacing: 2)),
                            verticalScalingFactor: 1
                        ),
                        renderer: LinearWaveformRenderer(),
                        shouldDrawSilencePadding: false
                    )
                    .frame(height: 300)
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Spacer()
                        let showsHour = viewModel.currentTime.hour > 0
                        if showsHour {
                            timeBox(for: viewModel.currentTime.hour)
                        }
                        timeBox(for: viewModel.currentTime.minute, appending: showsHour ? ":" : "")
                        timeBox(for: viewModel.currentTime.second, appending: ":")
                        timeBox(for: viewModel.currentTime.decimals, appending: ".", width: 15)
                            .font(.title3.bold())
                        Spacer()
                    }
                    .font(.largeTitle.bold())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Timeline
extension RecorderView {
    func timeBox(for value: Int, appending text: String? = nil, width: CGFloat = 22) -> some View {
        HStack(spacing: 2) {
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
            .frame(width: width)
        }
    }
}

// MARK: - Toolbar
extension RecorderView {
    var recordToolBar: some View {
        HStack {
            Spacer()
            if viewModel.state == .paused {
                Button {
                    viewModel.onTapDeleteRecording()
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
                    viewModel.onTapStopRecording()
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
