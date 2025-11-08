//
//  ContentView.swift
//  Calculator
//
//  Created by Gustavo Caldas de Souza on 2025-11-05.
//

import SwiftUI

enum CalculatorButton: String {
    case zero = "0"
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case decimal = "."
    case equals = "="
    case plus = "+"
    case minus = "-"
    case multiply = "×"
    case divide = "÷"
    case clear = "AC"
    case negative = "+/-"
    case percent = "%"
    
    var backgroundColor: Color {
        switch self {
        case .clear:
            return Color(red: 1.0, green: 0.3, blue: 0.3) // Bright Red
        case .negative:
            return Color(red: 1.0, green: 0.6, blue: 0.0) // Orange
        case .percent:
            return Color(red: 1.0, green: 0.8, blue: 0.0) // Golden Yellow
        case .divide:
            return Color(red: 0.4, green: 0.8, blue: 1.0) // Sky Blue
        case .multiply:
            return Color(red: 0.6, green: 0.4, blue: 1.0) // Purple
        case .minus:
            return Color(red: 1.0, green: 0.4, blue: 0.7) // Pink
        case .plus:
            return Color(red: 0.3, green: 0.9, blue: 0.5) // Green
        case .equals:
            return Color(red: 0.2, green: 0.7, blue: 1.0) // Blue
        default:
            return Color(red: 0.15, green: 0.15, blue: 0.25) // Dark Blue-Gray
        }
    }
    
    var foregroundColor: Color {
        return .white
    }
}

enum Operation {
    case add, subtract, multiply, divide, none
}

struct ContentView: View {
    @State private var display = "0"
    @State private var currentNumber: Double = 0
    @State private var previousNumber: Double = 0
    @State private var operation: Operation = .none
    @State private var isTypingNumber = false
    @State private var history: String = ""
    
    let buttons: [[CalculatorButton]] = [
        [.clear, .negative, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .minus],
        [.one, .two, .three, .plus],
        [.zero, .decimal, .equals]
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.1, blue: 0.3),
                    Color(red: 0.1, green: 0.2, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geo in
                let horizontalPadding: CGFloat = 24
                let spacing: CGFloat = 12
                let columns: CGFloat = 4
                let totalWidth = geo.size.width - horizontalPadding * 2
                let buttonBaseWidth = (totalWidth - spacing * (columns - 1)) / columns

                // Reserve a portion of height for the display area; adapt to landscape
                let displayHeight = max(geo.size.height * 0.18, 72)
                let availableButtonAreaHeight = geo.size.height - displayHeight - 48 // top/bottom spacing
                let buttonBaseHeight = max(min(buttonBaseWidth, (availableButtonAreaHeight - spacing * 4) / 5), 44)

                VStack(spacing: 12) {
                    Spacer(minLength: 8)

                    // Display
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 6) {
                            Text(history)
                                .font(.system(size: min(20, displayHeight * 0.18)))
                                .foregroundColor(Color.white.opacity(0.8))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.horizontal, 4)

                            Text(display)
                                .font(.system(size: min(72, displayHeight * 0.6)))
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, Color(red: 0.8, green: 0.9, blue: 1.0)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.blue.opacity(0.25), radius: 8, x: 0, y: 4)
                                .lineLimit(1)
                                .minimumScaleFactor(0.2)
                                .padding(.horizontal, horizontalPadding)
                                .frame(height: displayHeight * 0.85)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    // Buttons
                    VStack(spacing: spacing) {
                        ForEach(buttons, id: \.self) { row in
                            HStack(spacing: spacing) {
                                ForEach(row, id: \.self) { button in
                                    let w: CGFloat = (button == .zero) ? (buttonBaseWidth * 2 + spacing) : buttonBaseWidth
                                    Button(action: {
                                        self.buttonTapped(button)
                                    }) {
                                        Text(button.rawValue)
                                            .font(.system(size: min(32, buttonBaseHeight * 0.45)))
                                            .fontWeight(.bold)
                                            .foregroundColor(button.foregroundColor)
                                            .frame(width: w, height: buttonBaseHeight)
                                            .background(button.backgroundColor)
                                            .cornerRadius(16)
                                            .shadow(color: button.backgroundColor.opacity(0.45), radius: 8, x: 0, y: 4)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 12)
                    .padding(.horizontal, horizontalPadding)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
    
    func buttonWidth(_ button: CalculatorButton) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 12
        let totalSpacing: CGFloat = spacing * 5
        let buttonWidth = (screenWidth - totalSpacing) / 4
        
        if button == .zero {
            return buttonWidth * 2 + spacing
        }
        return buttonWidth
    }
    
    func buttonHeight() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 12
        let totalSpacing: CGFloat = spacing * 5
        return (screenWidth - totalSpacing) / 4
    }
    
    func buttonTapped(_ button: CalculatorButton) {
        switch button {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            numberPressed(button.rawValue)
        case .decimal:
            decimalPressed()
        case .plus:
            operationPressed(.add)
        case .minus:
            operationPressed(.subtract)
        case .multiply:
            operationPressed(.multiply)
        case .divide:
            operationPressed(.divide)
        case .equals:
            equalsPressed()
        case .clear:
            clearPressed()
        case .negative:
            negativePressed()
        case .percent:
            percentPressed()
        }
    }
    
    func numberPressed(_ number: String) {
        if isTypingNumber {
            if display.count < 9 {
                display = display == "0" ? number : display + number
            }
        } else {
            display = number
            isTypingNumber = true
        }
        currentNumber = Double(display) ?? 0
        if operation == .none {
            history = ""
        }
    }
    
    func decimalPressed() {
        if !display.contains(".") {
            display += "."
            isTypingNumber = true
        }
    }
    
    func operationPressed(_ op: Operation) {
        if operation != .none {
            equalsPressed()
        }
        previousNumber = currentNumber
        operation = op
        isTypingNumber = false
        history = formatNumber(previousNumber) + " " + opSymbol(op)
    }
    
    func equalsPressed() {
        var result: Double = 0
        
        switch operation {
        case .add:
            result = previousNumber + currentNumber
        case .subtract:
            result = previousNumber - currentNumber
        case .multiply:
            result = previousNumber * currentNumber
        case .divide:
            if currentNumber != 0 {
                result = previousNumber / currentNumber
            } else {
                display = "Error"
                operation = .none
                isTypingNumber = false
                return
            }
        case .none:
            result = currentNumber
        }
        
        // Format the result
        if result.truncatingRemainder(dividingBy: 1) == 0 {
            display = String(format: "%.0f", result)
        } else {
            display = String(result)
        }
        if operation != .none {
            history = formatNumber(previousNumber) + " " + opSymbol(operation) + " " + formatNumber(currentNumber) + " ="
        }

        currentNumber = result
        operation = .none
        isTypingNumber = false
    }
    
    func clearPressed() {
        display = "0"
        currentNumber = 0
        previousNumber = 0
        operation = .none
        isTypingNumber = false
        history = ""
    }
    
    func negativePressed() {
        currentNumber = -currentNumber
        if display.hasPrefix("-") {
            display.removeFirst()
        } else {
            display = "-" + display
        }
    }
    
    func percentPressed() {
        currentNumber = currentNumber / 100
        display = String(currentNumber)
    }

    func opSymbol(_ op: Operation) -> String {
        switch op {
        case .add: return "+"
        case .subtract: return "-"
        case .multiply: return "×"
        case .divide: return "÷"
        case .none: return ""
        }
    }

    func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}

#Preview {
    ContentView()
}
