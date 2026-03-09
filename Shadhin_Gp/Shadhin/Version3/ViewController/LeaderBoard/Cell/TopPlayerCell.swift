//
//  TopPlayerCell.swift
//  Shadhin_BL
//
//  Created by Joy on 11/1/23.
//

import UIKit

class TopPlayerCell: UICollectionViewCell {
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var height : CGFloat{
        return 130
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    @IBOutlet weak var dailyButton: UIButton!
    @IBOutlet weak var weeklyButton: UIButton!
    @IBOutlet weak var monthlyButton: UIButton!
    
    private var campaign : Campaign?
    var onCampaign : (Campaign)-> Void = {campaign in}
    var timer: Timer?
    var endDate: Date?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dailyButton.setBackgroundColor(color: .tintColor, forState: .selected)
        dailyButton.setBackgroundColor(color: .clear, forState: .normal)
        weeklyButton.setBackgroundColor(color: .tintColor, forState: .selected)
        weeklyButton.setBackgroundColor(color: .clear, forState: .normal)
        monthlyButton.setBackgroundColor(color: .tintColor, forState: .selected)
        monthlyButton.setBackgroundColor(color: .clear, forState: .normal)
        
        dailyButton.setTitleColor(.white, for: .selected)
        weeklyButton.setTitleColor(.white, for: .selected)
        monthlyButton.setTitleColor(.white, for: .selected)

        dailyButton.setTitleColor(.black, for: .normal)
        weeklyButton.setTitleColor(.black, for: .normal)
        monthlyButton.setTitleColor(.black, for: .normal)
        
        dailyButton.isHidden = true
        weeklyButton.isHidden = true
        monthlyButton.isHidden = true
        dailyButton.isSelected = true
        titleLabel.text = "Daily Top 20 Winners"
    }
    
    func setTopPlayerNumberText(topPlayerNumber: Int) {
        titleLabel.text = "Daily Top \(topPlayerNumber) Winners"
    }
    

    func bind(with campaignSegData : Campaign){
        self.campaign = campaignSegData
        self.dailyButton.isHidden = false
        self.monthlyButton.isHidden = true
        self.weeklyButton.isHidden = true
        self.startCountdown(endDate: campaignSegData.endDate ?? "")
    }
    
    func startCountdown(endDate: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        if let endDate = formatter.date(from: endDate) {
            self.endDate = endDate
            updateCountdown()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        }
    }

    @objc func updateCountdown() {
        guard let endDate = endDate else { return }

        let remainingTime = Int(endDate.timeIntervalSinceNow)

        if remainingTime <= 0 {
            endLabel.text = "Ended"
            timer?.invalidate()
            timer = nil
            return
        }

        let days = remainingTime / (24 * 3600)
        let hours = (remainingTime % (24 * 3600)) / 3600
        let minutes = (remainingTime % 3600) / 60
        let seconds = remainingTime % 60

        endLabel.text = "Ends in \(days)d \(hours)h \(minutes)m \(seconds)s"
    }

    deinit {
        timer?.invalidate()
    }

    
    
    @IBAction func onDailyPressedd(_ sender: Any) {
//        guard let daily = campaign.first(where: { $0.name == .daily }) else {return}
//        dailyButton.isSelected = true
//        weeklyButton.isSelected = false
//        monthlyButton.isSelected = false
//        onCampaign(daily)
        //titleLabel.text = "Daily Top 50 Winners"
        
    }
    @IBAction func onWeeklyPressed(_ sender: Any) {
//        guard let weekly = campaign.first(where: { $0.name == .weekly }) else {return}
//        dailyButton.isSelected = false
//        weeklyButton.isSelected = true
//        monthlyButton.isSelected = false
//
//        onCampaign(weekly)
        //titleLabel.text = "Weekly Top 50 Winners"
    }
    
    @IBAction func onMonthlyPressed(_ sender: Any) {
//        guard let monthly = campaign.first(where: { $0.name == .monthLy }) else {return}
//        dailyButton.isSelected = false
//        weeklyButton.isSelected = false
//        monthlyButton.isSelected = true
//
//        onCampaign(monthly)
        //titleLabel.text = "Monthly Top 50 Winners"
    }
}

extension Date {

    static func -(recent: Date, previous: Date) -> String {
        let day = Calendar.current.dateComponents([.month,.day,.hour,.minute], from: previous, to: recent)
        var time = "Ends in "
        if let month = day.month, month > 0{
            time.append("\(month) Month, ")
        }
        if let day = day.day , day > 0{
            time.append("\(day) Day\(day>1 ? "s":""), ")
        }
        if let hour = day.hour, hour > 0{
            time.append("\(hour) Hour\(hour > 1 ? "s" : ""), ")
        }
        if let minute = day.minute{
            time.append("\(minute) Minute\(minute > 1 ? "s" : "")")
        }
        return time.appending(".")
    }

}
