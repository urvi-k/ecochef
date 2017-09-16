//
//  TimerViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 9/5/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit

class DualTimerController {
    var topLabel: UILabel
    var bottomLabel: UILabel
    var sumLabel: UILabel
    var timerButton: UIButton
    var isSelected: Bool = false
    private var topside: Bool = true
    private var topcum: Float = 0
    private var bottomcum: Float = 0
    private var localIsRunning: Bool = false
    private var startTime: Date?
    private var timer: Timer?
    
    var isRunning: Bool {
        return localIsRunning
    }
    
    init(_ top: UILabel, _ bottom: UILabel, _ sum: UILabel,
         _ timer: UIButton) {
        topLabel = top
        bottomLabel = bottom
        sumLabel = sum
        timerButton = timer
    }
    
    func toggle() {
        isSelected = !isSelected
        if isSelected {
            timerButton.setTitleColor(.red, for: .normal)
        } else {
            timerButton.setTitleColor(.black, for: .normal)
        }
    }
    
    func flip() {
        if topside {
            topcum += secondsElapsed()
        } else {
            bottomcum += secondsElapsed()
        }
        startTime = Date()
        topside = !topside
    }
    
    func reset() {
        topcum = 0
        bottomcum = 0
        localIsRunning = false
        timer?.invalidate()
    }
    
    func start() {
        localIsRunning = true
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (timer) in
            self.updateTimes()
        }
    }
    
    func stop() {
        localIsRunning = false
        if topside {
            topcum = topcum + secondsElapsed()
        } else {
            bottomcum = topcum + secondsElapsed()
        }
    }
    
    func updateTimes() {
        var topTotal: Float = topcum
        var bottomTotal: Float = bottomcum
        if localIsRunning {
            if topside {
                topTotal += secondsElapsed()
            } else {
                bottomTotal += secondsElapsed()
            }
        }
        let sumTotal: Float = topTotal + bottomTotal
        topLabel.text = formatTimeFrom(seconds: topTotal)
        bottomLabel.text = formatTimeFrom(seconds: bottomTotal)
        sumLabel.text = formatTimeFrom(seconds: sumTotal)
    }
    
    private func secondsElapsed() -> Float {
        var seconds: TimeInterval = 0
        if let then = startTime {
            seconds = then.timeIntervalSinceNow
        }
        return -Float(seconds)
    }
    
    private func formatTimeFrom(seconds: Float) -> String {
        var minstr : String
        var secstr : String

        let min = Int(floor(seconds/60))
        if min < 10 {
            minstr = "0\(min)"
        } else {
            minstr = "\(min)"
        }
        let sec = round(10*(seconds - Float(60*min)))/10
        if sec < 10 {
            secstr = "0\(sec)"
        } else {
            secstr = "\(sec)"
        }
        let timeform = minstr + ":" + secstr
        return timeform
    }
}

class TimerViewController: UIViewController {
    private var currentTimer: DualTimerController!  // convenience
    private var timerList: [DualTimerController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerList.append(DualTimerController(topLabel1, bottomLabel1, sumLabel1, timerButton1))
        timerList.append(DualTimerController(topLabel2, bottomLabel2, sumLabel2, timerButton2))
        currentTimer = timerList.first
        currentTimer.toggle()
    }
    
    func selectTimer(_ num: Int) {
        currentTimer.toggle()
        currentTimer = timerList[num]
        currentTimer.toggle()
    }

    // MARK: - IB
    @IBAction func clickTimer1(_ sender: UIButton) {
        selectTimer(0)
    }
    
    @IBAction func clickTimer2(_ sender: UIButton) {
        selectTimer(1)
    }
    
    @IBAction func startCounter(_ sender: UIButton) {
        if currentTimer.isRunning {
            currentTimer?.stop()
        } else {
            currentTimer?.start()
        }
    }
    
    @IBAction func clickTurn(_ sender: UIButton) {
        currentTimer.flip()
    }
    
    @IBOutlet weak var timerButton1: TimerButton!
    @IBOutlet weak var topLabel1: UILabel!
    @IBOutlet weak var bottomLabel1: UILabel!
    @IBOutlet weak var sumLabel1: UILabel!
    
    @IBOutlet weak var timerButton2: TimerButton!
    @IBOutlet weak var topLabel2: UILabel!
    @IBOutlet weak var bottomLabel2: UILabel!
    @IBOutlet weak var sumLabel2: UILabel!
    
}
