//
//  YearPicker.swift
//  PTCGLeagueManager
//
//  Created by Michael Parker on 8/13/24.
//

import SwiftUI

struct YearPicker: View {
    
    @Binding var selectedDate: Date
    let yearRange: ClosedRange<Int>

    init(selection: Binding<Date>) {

        self._selectedDate = selection
        let currentYear = Calendar.current.component(.year, from: Date())
        self.yearRange = (currentYear - 70)...currentYear

//        
//        let calendar = Calendar.current
//        let year = calendar.component(.year, from: selection.wrappedValue)
//        if !yearRange.contains(year) {
//            var adjustedYear = year
//            if year < yearRange.lowerBound {
//                adjustedYear = yearRange.lowerBound
//            } else if year > yearRange.upperBound {
//                adjustedYear = yearRange.upperBound
//            }
//            let originalComponents = calendar.dateComponents([.month, .day, .hour, .minute, .second, .nanosecond, .timeZone], from: selection.wrappedValue)
//            var components = DateComponents()
//            components.year = adjustedYear
//            components.month = originalComponents.month
//            components.day = originalComponents.day
//            components.hour = originalComponents.hour
//            components.minute = originalComponents.minute
//            components.second = originalComponents.second
//            components.nanosecond = originalComponents.nanosecond
//            components.timeZone = originalComponents.timeZone
//            self._selectedDate = Binding.constant(calendar.date(from: components)!)
//        }
    }
    
    var body: some View {
        
        let calendar = Calendar.current
        let selectedYear = calendar.component(.year, from: selectedDate)
        
        // Clamp the selected year to the valid range
        let clampedYear = min(max(selectedYear, yearRange.lowerBound), yearRange.upperBound)

        // Create a binding to the clamped year
        let yearBinding = Binding<Int>(
            get: { clampedYear },
            set: { newYear in
                var components = calendar.dateComponents([.month, .day], from: selectedDate)
                    components.year = newYear
                selectedDate = calendar.date(from: components) ?? Date()
            }
        )


        VStack {
//            Picker("Year", selection: $selectedDate) {
            Picker("Year", selection: yearBinding) {
                ForEach(yearRange, id: \.self) { year in
                    Text(displayYear(year: year))
                        .tag(self.dateFromYear(year))
                }
            }
        }
    }
        
    private func displayYear(year: Int) -> String {
        let numberFormatter: NumberFormatter = {
            let nf = NumberFormatter()
            nf.usesGroupingSeparator = false
            return nf
        }()
        return numberFormatter.string(from: NSNumber(value: year)) ?? "\(year)"
    }
    
    private func dateFromYear(_ year: Int) -> Date {
        let calendar = Calendar.current
        let originalComponents = calendar.dateComponents([.month, .day, .hour, .minute, .second, .nanosecond, .timeZone], from: selectedDate)
        var components = DateComponents()
        components.year = year
        components.month = originalComponents.month
        components.day = originalComponents.day
        components.hour = originalComponents.hour
        components.minute = originalComponents.minute
        components.second = originalComponents.second
        components.nanosecond = originalComponents.nanosecond
        components.timeZone = originalComponents.timeZone
        return calendar.date(from: components)!
    }
}
