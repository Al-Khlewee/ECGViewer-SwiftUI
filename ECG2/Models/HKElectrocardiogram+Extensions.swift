//
//  HKElectrocardiogram+Extensions.swift
//  ECG2
//
//  Created by Hatem Al-Khlewee on 16/03/2025.
//

import SwiftUI
import HealthKit

extension HKElectrocardiogram.Classification {
    var description: String {
        switch self {
        case .notSet: return "Not Set"
        case .sinusRhythm: return "Sinus Rhythm"
        case .atrialFibrillation: return "Atrial Fibrillation"
        case .inconclusiveLowHeartRate: return "Inconclusive (Low HR)"
        case .inconclusiveHighHeartRate: return "Inconclusive (High HR)"
        case .inconclusivePoorReading: return "Inconclusive (Poor Reading)"
        case .inconclusiveOther: return "Inconclusive"
        case .unrecognized: return "Unrecognized"
        @unknown default: return "Unknown"
        }
    }

    var color: Color {
        switch self {
        case .sinusRhythm: return .green
        case .atrialFibrillation: return .red
        case .inconclusiveLowHeartRate, .inconclusiveHighHeartRate,
             .inconclusivePoorReading, .inconclusiveOther: return .orange
        default: return .gray
        }
    }
}

extension HKElectrocardiogram: Identifiable {
    public var id: UUID { uuid }
}
