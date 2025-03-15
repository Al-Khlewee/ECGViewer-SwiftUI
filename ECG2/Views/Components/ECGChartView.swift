//
//  ECGChartView.swift
//  ECG2
//
//  Created by Hatem Al-Khlewee on 16/03/2025.
//


// Views/Components/ECGChartView.swift
import SwiftUI
import Charts

struct ECGChartView: View {
    let voltages: [Double]
    let rPeaks: [Int]
    let samplingRate: Double = 512.0

    @State private var scale: CGFloat = 15.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGPoint = .zero
    @State private var lastOffset: CGPoint = .zero

    private var totalDuration: Double {
        Double(voltages.count) / samplingRate
    }

    // Helper function to create ECG voltage lines
    private func ecgLines() -> some ChartContent {
        ForEach(Array(voltages.enumerated()), id: \.offset) { index, voltage in
            LineMark(
                x: .value("Time", Double(index) / samplingRate),
                y: .value("Voltage", voltage * 1000)
            )
            .lineStyle(StrokeStyle(lineWidth: 1.5))
            .foregroundStyle(.red)
        }
    }

    // Helper function to create second markers
    private func secondMarkers() -> some ChartContent {
        ForEach(0...Int(totalDuration), id: \.self) { second in
            RuleMark(x: .value("Second", Double(second)))
                .foregroundStyle(.gray.opacity(0.3))
        }
    }

    // Helper function to create R-peak markers
    private func rPeakMarkers() -> some ChartContent {
        ForEach(rPeaks, id: \.self) { peakIndex in
            PointMark(
                x: .value("Time", Double(peakIndex) / samplingRate),
                y: .value("Voltage", voltages[peakIndex] * 1000)
            )
            .symbolSize(100)
            .foregroundStyle(.blue)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            // The overall content (grid + chart) is grouped in a ZStack so the grid appears behind the ECG plot.
            ZStack {
                // Draw the ECG grid background.
                ECGGridBackground(width: max(geometry.size.width, geometry.size.width * scale), height: geometry.size.height)
                Chart {
                    // Plot the ECG voltages
                    ecgLines()

                    // Draw vertical rules at each second
                    secondMarkers()

                    // Plot R-peaks as points
                    rPeakMarkers()
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) { value in
                        if let second = value.as(Double.self) {
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel { Text("\(Int(second))s") }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisTick()
                    }
                }
            }
            .frame(
                width: max(geometry.size.width, geometry.size.width * scale),
                height: geometry.size.height
            )
            .offset(x: offset.x, y: 0)
            .gesture(
                SimultaneousGesture(
                    // Pinch to zoom
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            // Limit zoom scale between 0.1 and 50
                            scale = min(max(scale * delta, 0.1), 50)
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                        },
                    // Pan gesture
                    DragGesture()
                        .onChanged { value in
                            let newX = lastOffset.x + value.translation.width
                            let contentWidth = geometry.size.width * scale
                            let excessWidth = max(0, contentWidth - geometry.size.width)
                            let limitedX = min(max(newX, -excessWidth), 0)
                            offset = CGPoint(x: limitedX, y: 0)
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
            )
            .clipped()
            .overlay(alignment: .topTrailing) {
                Text("Zoom: \(scale, specifier: "%.1f")x")
                    .font(.caption)
                    .padding(6)
                    .background(Color(.systemGray6).opacity(0.8))
                    .cornerRadius(4)
                    .padding(8)
            }
        }
        .frame(height: 300)
        .padding()
    }
}