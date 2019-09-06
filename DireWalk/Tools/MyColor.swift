//
//  MyColor.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/08/30.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit

/*
 結局ほとんど使わなかった
 
 このアプリではiOS 13以前で動作する時DarkModeを標準とする
 また、iOS 13以降でも常にダークモードにするオプションを用意してある
 なお、今回はiOS 12時点で浮いていた設定画面の色をDark Modeに準拠させることのみとし、
 アプリ全体をライトテーマに揃えるということはしない。
 iPhone X, Xs向けとなってしまうが、歩きながら常に開いておきたいアプリであるということを
 鑑みると少しでも電池の消費量を抑えた方がいいからである。
 iPhone Xrなどに対しても、昼間の日光の中では黒地に白が一番見えやすく、
 この配色は悪くないチョイスだと確信している。
 */
var isDarkTheme: Bool {
    if #available(iOS 13, *),
        !ViewModel.shared.settings.isAlwaysDarkAppearance,
        UITraitCollection.current.userInterfaceStyle == .light{
        return true
    }else {
        return false
    }
}

extension UIColor {
    public class func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        return isDarkTheme ? dark : light
    }
}

extension UIColor {
    public static let background = dynamicColor(light: .white, dark: .black)
    public static let labelText = dynamicColor(light: .black,
                                               dark: .init(white: 0, alpha: 0.87))
    public static let controller = dynamicColor(light: .lightGray, dark: .darkGray)
    
    
}

extension UIColor {
    public static let mySystemBlue = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    public static let myBlue = #colorLiteral(red: 0.04705882353, green: 0.3921568627, blue: 1, alpha: 1)
    public static let mySkyBlue = #colorLiteral(red: 0, green: 0.7490196078, blue: 1, alpha: 1)
    public static let cover = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
    public static let superGray = #colorLiteral(red: 0.860546875, green: 0.860546875, blue: 0.860546875, alpha: 1)
}
