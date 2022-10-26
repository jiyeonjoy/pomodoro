//
//  ViewController.swift
//  pomodoro
//
//  Created by Jiyeon Choi on 2022. 10. 26..
//

import UIKit
import AudioToolbox

enum TimerStatus {
  case start
  case pause
  case end
}

class ViewController: UIViewController {

  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var datePicker: UIDatePicker!

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var toggleButton: UIButton!

  var duration = 60
  var timerStatus: TimerStatus = .end
  var currentSeconds = 0
  var timer: DispatchSourceTimer?

  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureToggleButton()
  }

  @IBAction func tapCancelButton(_ sender: UIButton) {
    switch self.timerStatus {
    case .start, .pause:
      self.stopTimer()

    default:
      break
    }
  }

  @IBAction func tapToggleButton(_ sender: UIButton) {
    self.duration = Int(self.datePicker.countDownDuration)
    switch self.timerStatus {
    case .end:
      self.currentSeconds = duration
      self.timerStatus = .start
      UIView.animate(withDuration: 0.5, animations: {
        self.timerLabel.alpha = 1
        self.progressView.alpha = 1
        self.datePicker.alpha = 0
      })
      self.toggleButton.isSelected = true
      self.cancelButton.isEnabled = true
      self.startTimer()

    case .start:
      self.timerStatus = .pause
      self.toggleButton.isSelected = false
      self.timer?.suspend()

    case .pause:
      self.timerStatus = .start
      self.toggleButton.isSelected = true
      self.timer?.resume()
    }
  }

  func configureToggleButton() {
    self.toggleButton.setTitle("시작", for: .normal)
    self.toggleButton.setTitle("일시정지", for: .selected)
  }

  func startTimer() {
    if self.timer == nil {
        /// 유아이 작업은 main 쓰레드 에서 해줘야 됨.
      self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        /// 즉시 실행, 1초마다 실행
      self.timer?.schedule(deadline: .now(), repeating: 1)
      self.timer?.setEventHandler(handler: { [weak self] in
        guard let self = self else { return }
        self.currentSeconds -= 1
        let hour = self.currentSeconds / 3600
        let minutes = (self.currentSeconds % 3600) / 60
        let seconds = (self.currentSeconds % 3600) % 60
        self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)
        self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
          self.imageView.transform = CGAffineTransform(rotationAngle: .pi) // 180도
        })
        UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
          self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2) // 360도
        })
        if self.currentSeconds <= 0 {
          AudioServicesPlaySystemSound(1005)
          self.stopTimer()
        }
      })
      self.timer?.resume()
    }
  }

  func stopTimer() {
    if self.timerStatus == .pause {
      self.timer?.resume()
    }
    self.timerStatus = .end
    self.cancelButton.isEnabled = false

    UIView.animate(withDuration: 0.5, animations: {
      self.timerLabel.alpha = 0
      self.progressView.alpha = 0
      self.datePicker.alpha = 1
      self.imageView.transform = .identity
    })
    self.toggleButton.isSelected = false
    self.timer?.cancel()
    self.timer = nil
  }
}
