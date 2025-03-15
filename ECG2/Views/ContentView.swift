//
//  ContentView.swift
//  ECG2
//
//  Created by Hatem Al-Khlewee on 16/03/2025.
//


// Views/ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ECGThumbnailViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.ecgs) { ecg in
                        NavigationLink(destination: ECGDetailView(ecg: ecg)) {
                            ECGListItemWithThumbnail(
                                ecg: ecg,
                                previewVoltages: viewModel.previewVoltages[ecg.uuid] ?? []
                            )
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                    }
                }
                .listStyle(.plain)
                .navigationTitle("ECG Records")
                .refreshable { await viewModel.getECGFromHealthStore() }

                if viewModel.isLoading && viewModel.ecgs.isEmpty {
                    VStack {
                        ProgressView().padding()
                        Text("Loading ECG records...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground).opacity(0.8))
                }

                if !viewModel.isLoading && viewModel.ecgs.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("No ECG Records Found")
                            .font(.title2)
                            .fontWeight(.medium)

                        Text("ECG records from your Apple Watch will appear here")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)

                        Button(action: {
                            Task { await viewModel.getECGFromHealthStore() }
                        }) {
                            Text("Refresh")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .task { await viewModel.getECGFromHealthStore() }
        }
    }
}