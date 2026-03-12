
import Foundation



public func timeAgoSince(_ date: Date) -> String {
    
    let calendar = Calendar.current
    let now = Date()
    let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
    let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now, options: [])
    
    if let year = components.year, year >= 2 {
        return "\(year) years ago"
    }
    
    if let year = components.year, year >= 1 {
        return "Last year"
    }
    
    if let month = components.month, month >= 2 {
        return "\(month) months ago"
    }
    
    if let month = components.month, month >= 1 {
        return "Last month"
    }
    
    if let week = components.weekOfYear, week >= 2 {
        return "\(week) weeks ago"
    }
    
    if let week = components.weekOfYear, week >= 1 {
        return "Last week"
    }
    
    if let day = components.day, day >= 2 {
        return "\(day) days ago"
    }
    
    if let day = components.day, day >= 1 {
        return "Yesterday"
    }
    
    if let hour = components.hour, hour >= 2 {
        return "\(hour) hours ago"
    }
    
    if let hour = components.hour, hour >= 1 {
        return "An hour ago"
    }
    
    if let minute = components.minute, minute >= 2 {
        return "\(minute) minutes ago"
    }
    
    if let minute = components.minute, minute >= 1 {
        return "A minute ago"
    }
    
    if let second = components.second, second >= 3 {
        return "\(second) seconds ago"
    }
    
    return "Just now"
    
}

public func numberCompact(num: Double, roundingNumber: Int = 1) ->String{
    let thousandNum = num/1000
    let millionNum = num/1000000
    if num >= 1000 && num < 1000000{
        if(floor(thousandNum) == thousandNum || roundingNumber == 0){
            return("\(Int(thousandNum))k")
        }
        return("\(thousandNum.roundToPlaces(roundingNumber))k")
    }
    if num > 1000000{
        if(floor(millionNum) == millionNum || roundingNumber == 0){
            return("\(Int(thousandNum))k")
        }
        return ("\(millionNum.roundToPlaces(roundingNumber))M")
    }
    else{
        if(floor(num) == num || roundingNumber == 0){
            return ("\(Int(num))")
        }
        return ("\(num)")
    }

}

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        let double = self * divisor
        return Darwin.round( double ) / divisor
    }
}

func formatSecondsToString(_ seconds: TimeInterval) -> String {
    if seconds.isNaN {
        return "00:00"
    }
    let Min = Int(seconds / 60)
    let Sec = Int(seconds.truncatingRemainder(dividingBy: 60))
    return String(format: "%02d:%02d", Min, Sec)
}

func formatSecondsToString(_ seconds: Int) -> String {
    if seconds == 0 {
        return "00:00"
    }
    let Min = Int(seconds / 60)
    let Sec = Int(Double(seconds).truncatingRemainder(dividingBy: 60))
    return String(format: "%02d:%02d", Min, Sec)
}


func getCurrentDateAndTime(_ date: Date = Date()) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateString = dateFormatter.string(from: date)
    return dateString
}


