//
//  ECGDetailView.swift
//  ECG2
//
//  Created by Hatem Al-Khlewee on 16/03/2025.
//


// Views/DetailViews/ECGDetailView.swift
import SwiftUI
import HealthKit

struct ECGDetailView: View {
    let ecg: HKElectrocardiogram
    @StateObject private var viewModel = ECGDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Recorded on \(formatDate(ecg.startDate))")
                                .font(.headline)
                            HStack {
                                Circle()
                                    .fill(ecg.classification.color)
                                    .frame(width: 10, height: 10)
                                Text(ecg.classification.description)
                                    .foregroundColor(ecg.classification.color)
                                    .fontWeight(.medium)
                            }
                        }
                        Spacer()
                        if let heartRate = ecg.averageHeartRate {
                            VStack(alignment: .trailing) {
                                Text("\(Int(heartRate.doubleValue(for: .count().unitDivided(by: .minute()))))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                Text("BPM")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Divider()

                    if let device = ecg.device?.name {
                        HStack {
                            Image(systemName: "applewatch")
                                .foregroundColor(.secondary)
                            Text(device)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }

                    Text("Duration: \(formatDuration(start: ecg.startDate, end: ecg.endDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let rrInterval = viewModel.averageRRInterval {
                        Divider()
                        HStack {
                            Text("R-R Interval:")
                                .foregroundColor(.secondary)
                            Text("\(Int(rrInterval)) ms")
                                .fontWeight(.medium)
                            Text("(\(viewModel.rPeaks.count) R-peaks detected)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .padding(.horizontal)

                if viewModel.isLoading {
                    VStack {
                        ProgressView().padding()
                        Text("Loading full ECG data...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else if !viewModel.voltages.isEmpty {
                    VStack {
                        Text("Pinch to zoom, swipe to pan")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 4)

                        ECGChartView(voltages: viewModel.voltages, rPeaks: viewModel.rPeaks)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .padding(.horizontal)
                } else {
                    Text("No ECG data available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("ECG Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.fetchVoltages(from: ecg) }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(start: Date, end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        return String(format: "%.1f seconds", duration)
    }
}