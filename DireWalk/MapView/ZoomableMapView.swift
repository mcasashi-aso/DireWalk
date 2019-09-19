//
//  ZoomableMapView.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/09/17.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import UIKit
import MapKit

class ZoomableMapView: MKMapView, UIGestureRecognizerDelegate {
    
    private var headingImageView = UIImageView(image: UIImage(named: "UserHeading")!)
    
    private var dragPoint: CGPoint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // iOS 13ではMapKitでも標準で使えるようになっていた
    // が、iOS 13の挙動とは少し違う
    // (このGestureはViewのcenterを中心にzoomする)
    // ので、外から使うかどうかを決めれるものとする
    func setupGesture() {
        let doubleLongPress = UILongPressGestureRecognizer(target: self, action: #selector(doubleLongPress(_:)))
        
        // ダブルタップ後、即座にLongPress状態に移るように
        doubleLongPress.minimumPressDuration = 0
        doubleLongPress.numberOfTapsRequired = 1
        
        self.addGestureRecognizer(doubleLongPress)
        
        doubleLongPress.delegate = self
        
        // MKMapViewの機能が実装してあるSubViewを引っ張ってきて、
        // 設定してあるDoubleTapGestureRecognizerにdelegateを設定する
        self.subviews[0].gestureRecognizers?.forEach({ element in
            if let recognizer = (element as? UITapGestureRecognizer),
                recognizer.numberOfTapsRequired == 2 {
                element.delegate = self
            }
        })
    }
    
    /* このzoomメソッドの実装は適当 */
    func zoom(magnification: Double) {
        let span = region.span
        region.span = MKCoordinateSpan(latitudeDelta: span.latitudeDelta * magnification, longitudeDelta: span.longitudeDelta * magnification)
        setRegion(region, animated: false)
    }
    
    /* ダブルタップ → 上下動  で、ズームイン / アウト する (GoogleMap的な挙動) */
    @objc func doubleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        let state = recognizer.state
        let location = recognizer.location(in: recognizer.view)
        switch state {
        case .began:
            dragPoint = location
        case .changed:
            /* 上に動いたか下に動いたか判断 */
            let diffY = Double(location.y - dragPoint!.y)
            let magnification = 1 + diffY * 0.01
            self.zoom(magnification: magnification)
            dragPoint = location
            
            userTrackingMode = MKUserTrackingMode.none
        default:
            break
        }
    }
    
    /* MKMapViewに元から設定されているDoubleTapと、自分で設定したLongPressを同時に機能させる */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
