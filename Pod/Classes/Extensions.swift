//
//  Extensions.swift
//  Alamofire-iOS
//
//  Created by Евгений Дац on 27/09/2018.
//

import UIKit

extension UIView {
    var recursiveSubviews: [UIView] {
        var subviews = self.subviews.compactMap({$0})
        subviews.forEach { subviews.append(contentsOf: $0.recursiveSubviews) }
        return subviews
    }
}

extension UIAlertAction {
    
    private struct AssociatedKeys {
        static var checkedKey = "UIAlertAction.checkedKey"
    }
    
    @nonobjc var isChecked: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.checkedKey) as? Bool ?? false
        } set (checked) {
            objc_setAssociatedObject(self, &AssociatedKeys.checkedKey, checked, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            imageView = imageView ?? UIImageView()
            imageView?.image = checked ? UIImage(named: "UniversalCheckmark")?.withRenderingMode(.alwaysTemplate) : nil
        }
    }
    
    @nonobjc var alertController: UIAlertController? {
        get {
            return perform(Selector(("_alertController"))).takeUnretainedValue() as? UIAlertController
        } set(vc) {
            perform(Selector(("_setAlertController:")), with: vc)
        }
    }
    
    private var view: UIView? {
        return alertController?.view.recursiveSubviews.filter({type(of: $0) == NSClassFromString("_UIInterfaceActionCustomViewRepresentationView")}).compactMap({$0.value(forKeyPath: "action.customContentView") as? UIView}).first(where: {$0.value(forKey: "action") as? UIAlertAction == self})
    }
    
    var imageView: UIImageView? {
        get {
            return view?.value(forKey: "_checkView") as? UIImageView
        } set(new) {
            view?.setValue(new, forKey: "_checkView")
            guard let new = new, let view = view else { return }
            view.addSubview(new)
            new.translatesAutoresizingMaskIntoConstraints = false
            
            new.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
            new.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
    }
}

extension UIColor {
    @nonobjc static let dark = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0)
}

extension UIAlertController {
    
    private struct AssociatedKeys {
        static var blurStyleKey = "UIAlertController.blurStyleKey"
    }
    
    #if os(iOS)
    
    //    @objc public var preferredAction: UIAlertAction? {
    //        get {
    //            return perform(#selector(getter: UIAlertController.preferredAction))?.takeUnretainedValue() as? UIAlertAction
    //        } set (action) {
    //            perform(#selector(setter:UIAlertController.preferredAction), with: action)
    //            actions.forEach({$0.isChecked = false})
    //            action?.isChecked = true
    //        }
    //    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        visualEffectView?.effect = UIBlurEffect(style: blurStyle)
        cancelActionView?.backgroundColor = cancelButtonColor
        cancelHighlightView?.recursiveSubviews.forEach({$0.backgroundColor = blurStyle == .dark ? .black : nil})
        preferredAction?.isChecked = true
    }
    
    #endif
    
    public var blurStyle: UIBlurEffect.Style {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.blurStyleKey) as? UIBlurEffect.Style ?? .extraLight
        } set (style) {
            objc_setAssociatedObject(self, &AssociatedKeys.blurStyleKey, style, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    public var cancelButtonColor: UIColor? {
        return blurStyle == .dark ? .dark : nil
    }
    
    private var visualEffectView: UIVisualEffectView? {
        if let presentationController = presentationController, presentationController.responds(to: Selector(("popoverView"))), let view = presentationController.value(forKey: "popoverView") as? UIView // We're on an iPad and visual effect view is in a different place.
        {
            return view.recursiveSubviews.compactMap({$0 as? UIVisualEffectView}).first
        }
        
        return view.recursiveSubviews.compactMap({$0 as? UIVisualEffectView}).first
    }
    
    private var cancelBackgroundView: UIView? {
        return view.recursiveSubviews.first(where: {type(of: $0) == NSClassFromString("_UIAlertControlleriOSActionSheetCancelBackgroundView")})
    }
    
    private var cancelActionView: UIView? {
        return cancelBackgroundView?.value(forKey: "backgroundView") as? UIView
    }
    
    private var cancelHighlightView: UIView? {
        return cancelBackgroundView?.value(forKey: "highlightView") as? UIView
    }
    
    public convenience init(title: String?, message: String?, preferredStyle: UIAlertController.Style, blurStyle: UIBlurEffect.Style) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        self.blurStyle = blurStyle
    }
}
