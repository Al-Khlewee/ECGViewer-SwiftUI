//
//  ECGThumbnailView.swift
//  ECG2
//
//  Created by Hatem Al-Khlewee on 16/03/2025.
//


// Views/Components/ECGThumbnailView.swift
import SwiftUI
import HealthKit
import Charts
struct ECGThumbnailView: View {
    let voltages: [Double]
    let classification: HKElectrocardiogram.Classification

    var body: some View {
        Chart {
            ForEach(Array(voltages.enumerated()), id: \.offset) { index, voltage in
                LineMark(
                    x: .value("Sample", index),
                    y: .value("Voltage", voltage * 1000 * 0.1) // Apply 0.1x zoom factor
                )
                .lineStyle(StrokeStyle(lineWidth: 1.5))
                .foregroundStyle(classification == .sinusRhythm ? .green : .red)
            }
        }
        .frame(height: 60)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: -0.1...0.1)
        .padding(.vertical, 4)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
}