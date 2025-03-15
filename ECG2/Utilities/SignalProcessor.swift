//
//  SignalProcessor.swift
//  ECG2
//
//  Created by Hatem Al-Khlewee on 16/03/2025.
//


// Utilities/SignalProcessor.swift
import Foundation

class SignalProcessor {
    /// Apply a simple moving average filter to smooth the signal
    static func movingAverageFilter(data: [Double], windowSize: Int = 5) -> [Double] {
        guard data.count > windowSize else { return data }

        var result = [Double](repeating: 0, count: data.count)

        for i in 0..<data.count {
            var sum = 0.0
            var count = 0

            let halfWindow = windowSize / 2
            let start = max(0, i - halfWindow)
            let end = min(data.count - 1, i + halfWindow)

            for j in start...end {
                sum += data[j]
                count += 1
            }

            result[i] = sum / Double(count)
        }

        return result
    }

    /// Normalize data to a specific range
    static func normalize(data: [Double], minValue: Double = -1.0, maxValue: Double = 1.0) -> [Double] {
        guard let min = data.min(), let max = data.max(), min != max else {
            return data.map { _ in 0 }
        }

        let range = max - min
        let targetRange = maxValue - minValue

        return data.map { minValue + ((($0 - min) / range) * targetRange) }
    }

    /// Calculates the derivative of the signal (slope)
    static func derivative(data: [Double]) -> [Double] {
        guard data.count > 1 else { return [] }

        var result = [Double](repeating: 0, count: data.count)

        for i in 1..<data.count {
            result[i] = data[i] - data[i-1]
        }

        return result
    }
}