//
//  ECGListItemWithThumbnail.swift
//  ECG2
//
//  Created by Hatem Al-Khlewee on 16/03/2025.
//


//Views/Components/ECGListItemWithThumbnail.swift
import HealthKit
import SwiftUI

struct ECGListItemWithThumbnail: View {
    let ecg: HKElectrocardiogram
    let previewVoltages: [Double]

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(formatDate(ecg.startDate))
                            .font(.headline)
                        HStack(spacing: 4) {
                            Circle()
                                .fill(ecg.classification.color)
                                .frame(width: 10, height: 10)
                            Text(ecg.classification.description)
                                .font(.subheadline)
                                .foregroundColor(ecg.classification.color)
                        }
                    }
                    Spacer()
                    if let heartRate = ecg.averageHeartRate {
                        VStack(alignment: .trailing) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("\(Int(heartRate.doubleValue(for: .count().unitDivided(by: .minute())))) BPM")
                                    .fontWeight(.medium)
                            }
                            Text("Duration: \(formatDuration(start: ecg.startDate, end: ecg.endDate))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if !previewVoltages.isEmpty {
                    ECGThumbnailView(voltages: previewVoltages, classification: ecg.classification)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 60)
                        .cornerRadius(8)
                        .overlay(ProgressView())
                }

                if let device = ecg.device?.name {
                    HStack {
                        Image(systemName: "applewatch")
                            .foregroundColor(.secondary)
                        Text(device)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(start: Date, end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        return String(format: "%.1fs", duration)
    }
}