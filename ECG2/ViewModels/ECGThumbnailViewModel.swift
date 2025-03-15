//
//  ECGThumbnailViewModel.swift
//  ECG2
//
//  Created by Hatem Al-Khlewee on 16/03/2025.
//


// ViewModels/ECGThumbnailViewModel.swift
import SwiftUI
import HealthKit

class ECGThumbnailViewModel: ObservableObject {
    @Published var ecgs: [HKElectrocardiogram] = []
    @Published var previewVoltages: [UUID: [Double]] = [:]
    @Published var isLoading: Bool = false
    let healthStore = HKHealthStore()

    /// Request authorization to read ECG data from HealthKit.
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available")
            return
        }

        let ecgType = HKObjectType.electrocardiogramType()
        let typesToRead: Set<HKSampleType> = [ecgType]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
        } catch {
            print("Authorization failed: \(error)")
        }
    }

    /// Fetch ECG samples and collect exactly 3 seconds for thumbnails
    func getECGFromHealthStore() async {
        DispatchQueue.main.async { self.isLoading = true }
        await requestAuthorization()

        let ecgType = HKObjectType.electrocardiogramType()
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(sampleType: ecgType,
                                  predicate: nil,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: [sortDescriptor]) { [weak self] (_, samples, error) in
            guard let self = self else { return }
            if let ecgs = samples as? [HKElectrocardiogram] {
                DispatchQueue.main.async {
                    self.ecgs = ecgs
                    self.isLoading = false
                }
                // Fetch exactly 3 seconds for each ECG
                ecgs.forEach { self.fetchThreeSecondPreview(for: $0) }
            } else {
                DispatchQueue.main.async { self.isLoading = false }
            }
        }
        healthStore.execute(query)
    }

    /// Fetch exactly 3 seconds of voltage data (1536 samples at 512Hz)
    private func fetchThreeSecondPreview(for ecg: HKElectrocardiogram) {
        var voltages: [Double] = []
        let samplingRate = 512.0 // Apple Watch ECG sampling rate
        let desiredDuration = 3.0 // 3 seconds
        let samplesToCollect = Int(samplingRate * desiredDuration) // ~1536 samples

        let query = HKElectrocardiogramQuery(ecg) { [weak self] _, result in
            switch result {
            case .measurement(let measurement):
                if let voltageQuantity = measurement.quantity(for: .appleWatchSimilarToLeadI) {
                    voltages.append(voltageQuantity.doubleValue(for: .volt()))
                    // Stop after collecting exactly 3 seconds worth of data
                    if voltages.count >= samplesToCollect {
                        self?.processAndStoreThumbnail(voltages: voltages, for: ecg)
                        return
                    }
                }
            case .done:
                self?.processAndStoreThumbnail(voltages: voltages, for: ecg)
            case .error(let error):
                print("Error loading thumbnail voltages: \(error)")
            }
        }
        healthStore.execute(query)
    }

    /// Process thumbnail data for display with 0.1x zoom
    private func processAndStoreThumbnail(voltages: [Double], for ecg: HKElectrocardiogram) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let processedVoltages = self?.processVoltagesForThumbnail(voltages) ?? voltages
            DispatchQueue.main.async {
                self?.previewVoltages[ecg.uuid] = processedVoltages
            }
        }
    }

    /// Downsample data to make it suitable for thumbnail display
    private func processVoltagesForThumbnail(_ voltages: [Double]) -> [Double] {
        guard !voltages.isEmpty else { return [] }

        var processedVoltages: [Double] = []
        let samplingRate = 4 // Take every 4th sample to reduce data for thumbnail

        for i in stride(from: 0, to: min(voltages.count, 1536), by: samplingRate) {
            processedVoltages.append(voltages[i])
        }

        return processedVoltages
    }
}
