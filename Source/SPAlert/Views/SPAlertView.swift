// The MIT License (MIT)
// Copyright © 2019 Ivan Varabei (varabeis@icloud.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

/**
 View which presenting. You can configure `titleLabel`, `subtitleLabel` and other. For change duration use property `duration`.
 Also you can configure layout & haptic. If you use preset, all configure automatically.
 */
open class SPAlertView: UIView {
    /**
     Large top text on alert.
     */
    private var titleLabel: UILabel?

    /**
     Small text on alert.
     */
    private var subtitleLabel: UILabel?

    /**
     Current preset of alert
     */
    private var preset: SPAlertPreset?

    /**
     Icon view. Size for it configure in `layout` property.
     */
    private var iconView: UIView?

    /**
     Blur view for background.
     */
    public var backgroundView: UIVisualEffectView?

    /**
     Duration time when alert visible.
     */
    public var duration: TimeInterval = 1.5

    /**
      Horizontal alert padding
     */
    public var sideSpace: CGFloat = 16

    /**
     Width of the alert
     */
    public var width: CGFloat = 250

    /**
      Vertical center offset
     */
    public var verticalOffset: CGFloat = 0

    /**
     Allow dismiss by tap on alert. By default it allowed.
     */
    public var dismissByTap: Bool = true

    /**
     Sets whether alert automatically dismisses after duration. Defaults to true.
     */
    public var shouldAutoDismiss: Bool = true

    /**
     Vibro for this alert. Default value using for presets. If you init custom. haptic not configure.
     */
    public var haptic: SPAlertHaptic = .none

    /**
     Spacing and icon size configure here. Auto configure when you using presets.
     */
    public var layout = SPAlertLayout()

    /**
     View on which present alert.
     */
    public var keyWindow: UIView = (UIApplication.shared.keyWindow ?? UIWindow())

    // MARK: Init

    public init(title: String, message: String?, preset: SPAlertPreset) {
        super.init(frame: CGRect.zero)
        initPreset(preset)
        initTitleLabel(title)
        if let message = message {
            initSubtitleLabel(message)
        }
        commonInit()
    }

    public init(title: String, message: String?, icon view: UIView) {
        super.init(frame: CGRect.zero)
        iconView = view
        initTitleLabel(title)
        if let message = message {
            initSubtitleLabel(message)
        }
        commonInit()
    }

    public init(title: String, message: String?, image: UIImage) {
        super.init(frame: CGRect.zero)
        iconView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        iconView?.contentMode = .scaleAspectFit
        initTitleLabel(title)
        if let message = message {
            initSubtitleLabel(message)
        }
        commonInit()
    }

    public init(message: String) {
        super.init(frame: CGRect.zero)
        initSubtitleLabel(message)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func initPreset(_ preset: SPAlertPreset) {
        self.preset = preset
        if iconView == nil {
            iconView = preset.iconView
        }
        layout = preset.layout
        haptic = preset.haptic
    }

    private func initTitleLabel(_ title: String) {
        if titleLabel == nil {
            titleLabel = UILabel()
        }
        titleLabel!.text = title
    }

    private func initSubtitleLabel(_ message: String) {
        if subtitleLabel == nil {
            subtitleLabel = UILabel()
        }
        subtitleLabel!.text = message
    }

    lazy var textColor = UIColor {
        let darkModeColor = UIColor(red: 127 / 255, green: 127 / 255, blue: 129 / 255, alpha: 1)
        let lightModeColor = UIColor(red: 88 / 255, green: 87 / 255, blue: 88 / 255, alpha: 1)
        return $0.userInterfaceStyle == .dark ? darkModeColor : lightModeColor
    }

    private func commonInit() {
        backgroundColor = .clear
        layer.masksToBounds = true
        layer.cornerRadius = 8

        if backgroundView == nil {
            backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: isDarkMode ? .dark : .extraLight))
            backgroundView!.isUserInteractionEnabled = false
            addSubview(backgroundView!)
        }

        if let iconView = iconView, iconView.superview == nil {
            addSubview(iconView)
        }

        addLabelsIfNeeded()

        iconView?.tintColor = textColor
        titleLabel?.textColor = textColor
        subtitleLabel?.textColor = textColor
    }

    private func addLabelsIfNeeded() {
        if let titleLabel = titleLabel {
            titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
            titleLabel.numberOfLines = 0
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 3
            style.alignment = .center
            titleLabel.attributedText = NSAttributedString(string: titleLabel.text ?? "", attributes: [.paragraphStyle: style])
            if titleLabel.superview == nil {
                addSubview(titleLabel)
            }
        }

        if let subtitleLabel = subtitleLabel {
            subtitleLabel.font = UIFont.systemFont(ofSize: 16)
            subtitleLabel.numberOfLines = 0
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 2
            style.alignment = .center
            subtitleLabel.attributedText = NSAttributedString(string: subtitleLabel.text ?? "", attributes: [.paragraphStyle: style])
            if subtitleLabel.superview == nil {
                addSubview(subtitleLabel)
            }
        }
    }

    // MARK: Public

    /**
     Use this method for present controller. No need pass any controller, alert appear on `keyWindow`.
     */
    public func present() {
        if dismissByTap {
            let tapGesterRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
            addGestureRecognizer(tapGesterRecognizer)
        }
        haptic.impact()
        keyWindow.addSubview(self)
        layoutIfNeeded()
        layoutSubviews()
        alpha = 0
        transform = transform.scaledBy(x: 0.8, y: 0.8)

        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
        }, completion: { _ in
            if let iconView = self.iconView as? SPAlertIconAnimatable {
                iconView.animate()
            }
            if self.shouldAutoDismiss {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.duration) {
                    self.dismiss()
                }
            }
        })
    }

    /**
     Use this method for force dismiss controller. By default it call automatically.
     */
    @objc public func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.transform = self.transform.scaledBy(x: 0.8, y: 0.8)
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

    // MARK: Layout

    override open func layoutSubviews() {
        super.layoutSubviews()
        let width: CGFloat = self.width
        let sideSpace: CGFloat = self.sideSpace
        if let iconView = iconView {
            iconView.frame = CGRect(x: 0, y: layout.topSpace, width: layout.iconWidth, height: layout.iconHeight)
            iconView.center.x = width / 2
        }
        var yPosition = (iconView == nil) ? 32 : (iconView!.frame.maxY + layout.bottomIconSpace)
        if let titleLabel = titleLabel {
            layout(titleLabel, x: sideSpace, y: yPosition, width: width - sideSpace * 2)
            yPosition = titleLabel.frame.maxY + 4
        } else {
            yPosition = (iconView == nil) ? 23 : yPosition
        }
        if let subtitleLabel = subtitleLabel {
            layout(subtitleLabel, x: sideSpace, y: yPosition, width: width - sideSpace * 2)
        }
        frame = CGRect(x: 0, y: 0, width: width, height: calculateHeight())
        center = CGPoint(x: keyWindow.frame.midX, y: keyWindow.frame.midY + verticalOffset)
        backgroundView?.frame = bounds
    }

    /**
     Layout labels with multi-lines.
     */
    private func layout(_ label: UILabel, x: CGFloat, y: CGFloat, width: CGFloat) {
        label.frame = CGRect(x: x, y: y, width: width, height: 0)
        label.sizeToFit()
        label.frame = CGRect(x: x, y: y, width: width, height: label.frame.height)
    }

    /**
     This menthod call when need calulate height with layout.
     */
    private func calculateHeight() -> CGFloat {
        var height: CGFloat = 0
        if let iconView = iconView {
            height = iconView.frame.maxY + layout.bottomIconSpace
        }
        if let titleLabel = titleLabel {
            height = titleLabel.frame.maxY + layout.bottomSpace
        }
        if let subtitleLabel = subtitleLabel {
            if titleLabel == nil, iconView == nil {
                height = subtitleLabel.frame.origin.y * 2 + subtitleLabel.frame.height
            } else {
                height = subtitleLabel.frame.maxY + layout.bottomSpace
            }
        }
        return height
    }

    /**
     Check `userInterfaceStyle` mode.
     */
    private var isDarkMode: Bool {
        if #available(iOS 12.0, *) {
            switch UIApplication.shared.windows.first?.traitCollection.userInterfaceStyle ?? .light {
            case .dark:
                return true
            case .light:
                return false
            case .unspecified:
                return false
            @unknown default:
                return false
            }
        } else {
            return false
        }
    }

    public func update(title: String? = nil, message: String? = nil, preset: SPAlertPreset? = nil, haptic: SPAlertHaptic? = nil, dismissAfter: TimeInterval? = nil) {
        let animationDuration = 0.2
        var viewsToRemove: [UIView] = []
        var viewsToHide: [UIView] = []
        var viewsToShow: [UIView] = []

        if let titleLabel {
            if title == nil { viewsToRemove.append(titleLabel) }
            else if titleLabel.text != title {
                viewsToHide.append(titleLabel)
                viewsToShow.append(titleLabel)
            }
        }
        if let subtitleLabel {
            if message == nil { viewsToRemove.append(subtitleLabel) }
            else if subtitleLabel.text != message {
                viewsToHide.append(subtitleLabel)
                viewsToShow.append(subtitleLabel)
            }
        }
        if preset != self.preset || preset == nil, let iconView {
            viewsToRemove.append(iconView)
        }

        let fadeOutAnimations = {
            (viewsToRemove + viewsToHide).forEach { $0.alpha = 0 }
        }

        func reInit() {
            viewsToRemove.forEach {
                $0.removeFromSuperview()
                if $0 == self.titleLabel { self.titleLabel = nil }
                if $0 == self.subtitleLabel { self.subtitleLabel = nil }
                if $0 == self.iconView { self.iconView = nil }
            }
            if let title = title, titleLabel == nil {
                initTitleLabel(title)
                viewsToShow.append(titleLabel!)
            }
            if let message = message, subtitleLabel == nil {
                initSubtitleLabel(message)
                viewsToShow.append(subtitleLabel!)
            }
            if let _preset = preset, _preset != self.preset {
                initPreset(_preset)
                viewsToShow.append(iconView!)
            }
            if iconView == nil {
                layout = SPAlertLayout()
                self.haptic = .none
            }
            if let haptic {
                self.haptic = haptic
            }
            viewsToShow.forEach {
                if $0 == self.titleLabel { self.titleLabel?.text = title }
                if $0 == self.subtitleLabel { self.subtitleLabel?.text = message }
                $0.alpha = 0
            }
            commonInit()
        }

        let fadeInAnimations = { (_: Bool) in
            UIView.animate(
                withDuration: animationDuration,
                animations: {
                    viewsToShow.forEach { $0.alpha = 1 }
                }, completion: { _ in
                    guard let dismissAfter else { return }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + dismissAfter) {
                        self.dismiss()
                    }
                })
            if let _iconView = self.iconView, viewsToShow.contains(_iconView) {
                (_iconView as? SPAlertIconAnimatable)?.animate()
            }
            self.haptic.impact()
        }

        let fadeOutCompletion = { (_: Bool) in
            reInit()
            UIView.animate(
                withDuration: animationDuration,
                animations: {
                    self.layoutSubviews()
                },
                completion: fadeInAnimations)
        }

        UIView.animate(
            withDuration: animationDuration,
            animations: fadeOutAnimations,
            completion: fadeOutCompletion)
    }
}
