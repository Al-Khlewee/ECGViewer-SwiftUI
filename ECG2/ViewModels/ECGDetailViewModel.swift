//
//  ECGDetailViewModel.swift
//  ECG2
//
//  Created by Hatem Al-Khlewee on 16/03/2025.
//


// ViewModels/ECGDetailViewModel.swift
import SwiftUI
import HealthKit
import PeakSwift

class ECGDetailViewModel: ObservableObject {
    @Published var voltages: [Double] = []
    @Published var rPeaks: [Int] = []
    @Published var averageRRInterval: Double? = nil
    @Published var isLoading: Bool = false
    let healthStore = HKHealthStore()

    /// Fetch the full ECG recording.
    func fetchVoltages(from ecg: HKElectrocardiogram) {
        isLoading = true
        var accumulatedVoltages: [Double] = []

        let query = HKElectrocardiogramQuery(ecg) { [weak self] _, result in
            switch result {
            case .measurement(let measurement):
                if let voltageQuantity = measurement.quantity(for: .appleWatchSimilarToLeadI) {
                    accumulatedVoltages.append(voltageQuantity.doubleValue(for: .volt()))
                }
            case .done:
                DispatchQueue.global(qos: .userInitiated).async {
                    let processed = self?.processVoltagesForDetail(accumulatedVoltages) ?? accumulatedVoltages

                    // Use PeakSwift's QRSDetector with the NeuroKit algorithm.
                    let samplingRate = 512.0
                    let electrocardiogram = Electrocardiogram(ecg: processed, samplingRate: samplingRate)
                    let qrsDetector = QRSDetector()
                    let qrsResult = qrsDetector.detectPeaks(electrocardiogram: electrocardiogram, algorithm: .neurokit)
                    let peaks = qrsResult.rPeaks.map { Int($0) }
                    let rrInterval = self?.calculateAverageRRInterval(from: peaks, samplingRate: samplingRate)

                    DispatchQueue.main.async {
                        self?.voltages = processed
                        self?.rPeaks = peaks
                        self?.averageRRInterval = rrInterval
                        self?.isLoading = false
                    }
                }
            case .error(let error):
                DispatchQueue.main.async { self?.isLoading = false }
                print("Error loading full ECG voltages: \(error)")
            }
        }
        healthStore.execute(query)
    }

    /// Apply smoothing (a simple moving average filter).
    private func processVoltagesForDetail(_ voltages: [Double]) -> [Double] {
        guard !voltages.isEmpty else { return [] }
        return SignalProcessor.movingAverageFilter(data: voltages, windowSize: 5)
    }

    /// Helper function to calculate the average R-R interval from detected R-peaks.
    private func calculateAverageRRInterval(from peaks: [Int], samplingRate: Double) -> Double? {
        guard peaks.count > 1 else { return nil }

        var intervals = [Double]()
        for i in 1..<peaks.count {
            let intervalSamples = Double(peaks[i] - peaks[i-1])
            let intervalMs = (intervalSamples / samplingRate) * 1000
            intervals.append(intervalMs)
        }

        return intervals.reduce(0, +) / Double(intervals.count)
    }
}
