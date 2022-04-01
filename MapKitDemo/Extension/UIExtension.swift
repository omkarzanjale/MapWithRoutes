//
//  UIExtension.swift
//  MapKitDemo
//
//  Created by Admin on 31/03/22.
//

import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var rounded: Bool {
        
        get {
            return true
        }
        set {
            if newValue {
                self.roundView()
            }
        }
    }
    
    func roundView() {
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
    }
    
    @IBInspectable var borderWidth: CGFloat {
        
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        
        set {
            
            layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var isTopRounded: Bool {
        
        get {
            return true
        }
        
        set {
            
            if newValue {
                
                DispatchQueue.main.async {
                    
                    self.roundCorners([.topLeft, .topRight], radius: 3)
                    
                }
                
            }
            
        }
        
    }
    
    @IBInspectable var topCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            DispatchQueue.main.async {
                self.roundCorners([.topLeft, .topRight], radius: newValue)
                
            }
            
        }
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        let mask = CAShapeLayer()
        
        mask.path = path.cgPath
        
        self.layer.mask = mask
    }
}

extension UIColor {
    static let themeColor = UIColor(red: 0.835, green: 0.098, blue: 0.000, alpha: 1)
}
