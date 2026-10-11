//
//  CalendarWeekFactory.swift
//  EverfitCalendar
//

import Foundation

struct CalendarWeekFactory {

    /// Returns the seven days of the week containing `date`, Monday through Sunday.
    ///
    /// `calendar.firstWeekday` is ignored. Date math uses the injected calendar's
    /// time zone so "today" matches the device's local day.
    func makeCurrentWeek(
        for date: Date = Date(),
        calendar: Calendar = .current
    ) -> [CalendarDay] {
        let today = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: today)
        // Gregorian: 1 = Sunday ... 7 = Saturday. Monday is 2.
        let daysFromMonday = (weekday + 5) % 7

        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else {
            return []
        }

        let weekdayFormatter = DateFormatter()
        weekdayFormatter.calendar = calendar
        weekdayFormatter.locale = Locale(identifier: "en_US_POSIX")
        weekdayFormatter.timeZone = calendar.timeZone
        weekdayFormatter.dateFormat = "EEE"

        let dayFormatter = DateFormatter()
        dayFormatter.calendar = calendar
        dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        dayFormatter.timeZone = calendar.timeZone
        dayFormatter.dateFormat = "d"

        return (0..<7).compactMap { offset in
            guard let dayDate = calendar.date(byAdding: .day, value: offset, to: monday) else {
                return nil
            }
            return CalendarDay(
                date: dayDate,
                dayNumber: dayFormatter.string(from: dayDate),
                weekdayShort: weekdayFormatter.string(from: dayDate),
                isToday: calendar.isDate(dayDate, inSameDayAs: today)
            )
        }
    }
}
