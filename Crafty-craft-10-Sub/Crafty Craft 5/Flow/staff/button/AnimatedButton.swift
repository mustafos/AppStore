//  Created by Melnykov Valerii on 14.07.2023
//


import UIKit



protocol AnimatedButtonEvent : AnyObject {
    func onClick()
}

enum animationButtonStyle {
    case gif,native
}

class AnimatedButton: UIView {
    
    @IBOutlet private var contentSelf: UIView!
    @IBOutlet private weak var backgroundSelf: UIImageView!
    @IBOutlet private weak var titleSelf: UILabel!
    
    weak var delegate : AnimatedButtonEvent?
    private let currentFont = Configurations_REFACTOR.getSubFontName()
    private var persistentAnimations: [String: CAAnimation] = [:]
    private var persistentSpeed: Float = 0.0
    private let xib = "AnimatedButton"
    
    public var style : animationButtonStyle = .native
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Init()
    }
    
    // Этот метод будет вызван, когда view добавляется к superview
      override func didMoveToSuperview() {
          super.didMoveToSuperview()
          if style == .native {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                  self.setPulseAnimation()
              })
              addNotificationObservers()
          }
        
      }

      // Этот метод будет вызван перед тем, как view будет удален из superview
      override func willMove(toSuperview newSuperview: UIView?) {
          super.willMove(toSuperview: newSuperview)
          if style == .native {
              if newSuperview == nil {
                  self.layer.removeAllAnimations()
                  removeNotificationObservers()
              }
          }
      }

      private func addNotificationObservers() {
          NotificationCenter.default.addObserver(self, selector: #selector(pauseAnimation), name: UIApplication.didEnterBackgroundNotification, object: nil)
          NotificationCenter.default.addObserver(self, selector: #selector(resumeAnimation), name: UIApplication.willEnterForegroundNotification, object: nil)
      }

      private func removeNotificationObservers() {
          NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
          NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
      }

      @objc private func pauseAnimation() {
          self.persistentSpeed = self.layer.speed

          self.layer.speed = 1.0 //in case layer was paused from outside, set speed to 1.0 to get all animations
          self.persistAnimations(withKeys: self.layer.animationKeys())
          self.layer.speed = self.persistentSpeed //restore original speed

          self.layer.pause()
      }

      @objc private func resumeAnimation() {
          self.restoreAnimations(withKeys: Array(self.persistentAnimations.keys))
          self.persistentAnimations.removeAll()
          if self.persistentSpeed == 1.0 { //if layer was plaiyng before backgorund, resume it
              self.layer.resume()
          }
      }
    
    func persistAnimations(withKeys: [String]?) {
        withKeys?.forEach({ (key) in
            if let animation = self.layer.animation(forKey: key) {
                self.persistentAnimations[key] = animation
            }
        })
    }

    func restoreAnimations(withKeys: [String]?) {
        withKeys?.forEach { key in
            if let persistentAnimation = self.persistentAnimations[key] {
                self.layer.add(persistentAnimation, forKey: key)
            }
        }
    }
    
    private func Init() {
        Bundle.main.loadNibNamed(xib, owner: self, options: nil)
        contentSelf.fixInView(self)
        contentSelf.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        contentSelf.layer.cornerRadius = 8
        animationBackgroundInit()
        
    }
    
    private func animationBackgroundInit() {
        titleSelf.text = localizedString(forKey: "iOSButtonID")
        titleSelf.font = UIFont(name: currentFont, size: 29)
        titleSelf.textColor = .white
        titleSelf.minimumScaleFactor = 11/22
        if style == .native {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.setPulseAnimation()
            })
        }else {
            do {
                let gif = try UIImage(gifName: "btn_gif.gif")
                backgroundSelf.setGifImage(gif)
            } catch {
                print(error)
            }
        }
        
        self.onClick(target: self, #selector(click))
    }
    
    @objc func click(){
        delegate?.onClick()
    }
    

    
}

extension UIView {
    func setPulseAnimation(){
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1
        pulseAnimation.toValue = 0.95
        pulseAnimation.fromValue = 0.79
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = Float.infinity
        self.layer.add(pulseAnimation, forKey: "pulse")
    }
}


extension CALayer {
    func pause() {
        if self.isPaused() == false {
            let pausedTime: CFTimeInterval = self.convertTime(CACurrentMediaTime(), from: nil)
            self.speed = 0.0
            self.timeOffset = pausedTime
        }
    }

    func isPaused() -> Bool {
        return self.speed == 0.0
    }

    func resume() {
        let pausedTime: CFTimeInterval = self.timeOffset
        self.speed = 1.0
        self.timeOffset = 0.0
        self.beginTime = 0.0
        let timeSincePause: CFTimeInterval = self.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        self.beginTime = timeSincePause
    }
}
