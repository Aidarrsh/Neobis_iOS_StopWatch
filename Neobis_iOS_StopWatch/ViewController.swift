//
//  ViewController.swift
//  Neobis_iOS_StopWatch
//
//  Created by Айдар Шарипов on 8/4/23.
//

import UIKit

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet weak var StopButton: UIButton!
    @IBOutlet weak var PauseButton: UIButton!
    
    var playButtonPressed = false
    var pauseButtonPressed = false
    var stopButtonPressed = false
    var timerCounting:Bool = false
    var startTime:Date?
    var stopTime:Date?
    var scheduledTimer: Timer!
    
    let userDefaults = UserDefaults.standard
    let START_TIME_KEY = "starTime"
    let STOP_TIME_KEY = "stopTime"
    let COUNTING_KEY = "countingKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        pickerView.isHidden = true
        
        startTime = userDefaults.object(forKey: START_TIME_KEY) as? Date
        stopTime = userDefaults.object(forKey: STOP_TIME_KEY) as? Date
        timerCounting = userDefaults.bool(forKey: COUNTING_KEY)
        
        let playImage = UIImage(systemName: "play.circle.fill")?.withRenderingMode(.alwaysTemplate).resized(to: CGSize(width: 80, height: 80))
        PlayButton.setImage(playImage?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        PlayButton.imageView?.contentMode = .scaleAspectFit
        
        let pauseImage = UIImage(systemName: "pause.circle.fill")?.withRenderingMode(.alwaysTemplate).resized(to: CGSize(width: 80, height: 80))
        PauseButton.setImage(pauseImage?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        PauseButton.imageView?.contentMode = .scaleAspectFit
        
        let stopImage = UIImage(systemName: "stop.circle.fill")?.withRenderingMode(.alwaysTemplate).resized(to: CGSize(width: 80, height: 80))
        StopButton.setImage(stopImage?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        StopButton.imageView?.contentMode = .scaleAspectFit
        
        if timerCounting{
            startTimer()
            
        } else {
            stopTimer ()
            if let start = startTime {
                if let stop = stopTime {
                    let time = calcRestartTime (start: start, stop: stop)
                    let diff = Date().timeIntervalSince(time)
                    setTimeLabel(Int(diff))
                }
            }
        }
    }
    
    func setStartTime(date: Date?){
        startTime = date
        userDefaults.set(startTime, forKey: START_TIME_KEY)
    }
    
    func setStopTime(date: Date?){
        stopTime = date
        userDefaults.set(stopTime, forKey: STOP_TIME_KEY)
    }
    
    func setTimerCounting( val: Bool){
        timerCounting = val
        userDefaults.set(timerCounting, forKey: COUNTING_KEY)
    }
    
    @IBAction func PlayButtonAction(_ sender: UIButton) {
        
        let playImage = UIImage(systemName: "play.circle")?.withRenderingMode(.alwaysTemplate).resized(to: CGSize(width: 80, height: 80))
        PlayButton.setImage(playImage?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        
        let pauseImage = UIImage(systemName: "pause.circle.fill")?.withRenderingMode(.alwaysTemplate).resized(to: CGSize(width: 80, height: 80))
        PauseButton.setImage(pauseImage?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        PauseButton.imageView?.contentMode = .scaleAspectFit
        playButtonPressed = true
        
        if let stop = stopTime{
            let restartTime = calcRestartTime(start: startTime!, stop: stop)
            setStopTime(date: nil)
            setStartTime(date: restartTime)
        } else {
            setStartTime(date: Date())
        }
        startTimer()
    }
    
    func calcRestartTime(start: Date, stop: Date) -> Date{
        let diff = start.timeIntervalSince(stop)
        return Date().addingTimeInterval(diff)
    }
    
    func startTimer(){
        scheduledTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refreshValue), userInfo: nil, repeats: true)
        setTimerCounting(val: true)
    }
    
    func stopTimer(){
        if scheduledTimer != nil{
            scheduledTimer.invalidate()
        }
        setTimerCounting(val: false)
    }
    
    func setTimeLabel(_ val: Int){
        let time = secondsToHoursMinutesSeconds(val)
        let timeString = makeTimeString(hour: time.0, min: time.1, sec: time.2)
        TimeLabel.text = timeString
    }
    
    func secondsToHoursMinutesSeconds(_ ms: Int) -> (Int, Int, Int)
    {
        let hour = ms / 3600
        let min = (ms % 3600) / 60
        let sec = (ms % 3600) % 60
        return (hour, min, sec)
    }
    
    func makeTimeString(hour: Int, min: Int, sec: Int) -> String{
        var timeString = ""
        timeString += String (format: "%02d", hour)
        timeString += ":"
        timeString += String (format: "%02d", min)
        timeString += ":"
        timeString += String (format: "%02d", sec)
        return timeString
    }
    
    @objc func refreshValue(){
        if let start = startTime {
            let diff = Date().timeIntervalSince(start)
            setTimeLabel(Int(diff))
        } else {
            stopTimer()
            setTimeLabel(0)
        }
    }
    
    @IBAction func PauseButtonAction(_ sender: UIButton) {
        if playButtonPressed == true {
            let pauseImage = UIImage(systemName: "pause.circle")?.withRenderingMode(.alwaysTemplate).resized(to: CGSize(width: 80, height: 80))
            PauseButton.setImage(pauseImage?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
            PauseButton.imageView?.contentMode = .scaleAspectFit
        }
        
        let playImage = UIImage(systemName: "play.circle.fill")?.withRenderingMode(.alwaysTemplate).resized(to: CGSize(width: 80, height: 80))
        PlayButton.setImage(playImage?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        PlayButton.imageView?.contentMode = .scaleAspectFit
        pauseButtonPressed = true
        stopTimer()
    }
    
    @IBAction func StopButtonAction(_ sender: UIButton) {
        
        let playImage = UIImage(systemName: "play.circle.fill")?.withRenderingMode(.alwaysTemplate).resized(to: CGSize(width: 80, height: 80))
        PlayButton.setImage(playImage?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        PlayButton.imageView?.contentMode = .scaleAspectFit
        
        let pauseImage = UIImage(systemName: "pause.circle.fill")?.withRenderingMode(.alwaysTemplate).resized(to: CGSize(width: 80, height: 80))
        PauseButton.setImage(pauseImage?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        PauseButton.imageView?.contentMode = .scaleAspectFit
        stopButtonPressed = true
        
        setStopTime(date: nil)
        setStartTime(date: nil)
        TimeLabel.text = makeTimeString(hour: 0, min: 0, sec: 0)
        setStopTime(date: Date())
        stopTimer()
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0{
            Image.image = UIImage(systemName: "timer")
            pickerView.isHidden = true
        } else {
            Image.image = UIImage(systemName: "stopwatch")
            pickerView.isHidden = false
        }
    }
}
