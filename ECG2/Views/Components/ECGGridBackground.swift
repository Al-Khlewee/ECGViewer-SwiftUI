//
//  ECGGridBackground.swift
//  ECG2
//
//  Created by Hatem Al-Khlewee on 16/03/2025.
//


// Views/Components/ECGGridBackground.swift
import SwiftUI

struct ECGGridBackground: View {
    var width: CGFloat
    var height: CGFloat
    // Define spacing in points; these values are illustrative.
    let smallSquareSpacing: CGFloat = 10    // Represents the 1mm grid (scaled)
    let largeSquareSpacing: CGFloat = 50    // Represents the 5mm grid (scaled)

    var body: some View {
        Canvas { context, size in
            // Draw small squares grid
            var smallPath = Path()
            for x in stride(from: 0, through: size.width, by: smallSquareSpacing) {
                smallPath.move(to: CGPoint(x: x, y: 0))
                smallPath.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in stride(from: 0, through: size.height, by: smallSquareSpacing) {
                smallPath.move(to: CGPoint(x: 0, y: y))
                smallPath.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(smallPath, with: .color(.red.opacity(0.3)), lineWidth: 0.5)

            // Draw large squares grid
            var largePath = Path()
            for x in stride(from: 0, through: size.width, by: largeSquareSpacing) {
                largePath.move(to: CGPoint(x: x, y: 0))
                largePath.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in stride(from: 0, through: size.height, by: largeSquareSpacing) {
                largePath.move(to: CGPoint(x: 0, y: y))
                largePath.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(largePath, with: .color(.red.opacity(0.6)), lineWidth: 1)
        }
        .frame(width: width, height: height)
        .drawingGroup()
    }
}