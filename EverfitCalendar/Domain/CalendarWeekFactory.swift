//
//  CalendarWeekFactory.swift
//  EverfitCalendar
//

import Foundation

struct CalendarWeekFactory {

    /// Builds the device-local week that contains `date`, always Monday…Sunday.
    ///
    /// Foundation weeks follow `calendar.firstWeekday` (often Sunday). This method
    /// does **not**. Gregorian `weekday` is 1 = Sunday … 7 = Saturday, so
    /// `(weekday + 5) % 7` is the number of days to subtract to land on Monday
    /// (0 when `date` is already Monday; 6 when it is Sunday).
    /// Time zone comes from `calendar` so “today” matches the device, not UTC.
    /// Formatters use `en_US_POSIX` so weekday abbreviations stay English (`Mon`).
    func makeCurrentWeek(
        for date: Date = Date(),
        calendar: Calendar = .current
    ) -> [CalendarDay] {
        let today = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: today)
        // Sunday=1 → 6 days back; Monday=2 → 0. Do not use calendar.range(of: .weekOfYear).
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
