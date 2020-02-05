//
//  MyButton.swift
//  DireWalk
//
//  Created by Masashi Aso on 2019/11/04.
//  Copyright © 2019 麻生昌志. All rights reserved.
//

import SwiftUI

class AnimationCloseButton: UIButton {
    
    private(set) var process: CGFloat = 0
    
    private(set) var path: UIBezierPath!
    private(set) var path2: UIBezierPath!
    private(set) var shapeLayer: CAShapeLayer!
    
    var drawingSize = CGSize(width: 300, height: 300) {
        didSet {
            if self.drawingSize.width != self.drawingSize.height {
                let a = min(self.drawingSize.width, self.drawingSize.height)
                self.drawingSize = CGSize(width: a, height: a)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .black

        makeShapeLayer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func makeShapeLayer() {
        self.makeArrow()

        shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 3.0

        layer.mask = shapeLayer
    }
    
    func optimizeSize() {
        self.drawingSize = CGSize(width:  min(self.frame.width,  self.drawingSize.width),
                                  height: min(self.frame.height, self.drawingSize.height))
    }

    private func makeArrow() {
        let width: CGFloat = 20
        func point(x: CGFloat, y: CGFloat) -> CGPoint {
            CGPoint(x: (self.frame.width - self.drawingSize.width)/2 + x,
                    y: (self.frame.height - self.drawingSize.height)/2 + y)
        }
        path = UIBezierPath()
        path.move   (to: point(x: self.drawingSize.width/2 - width/2, y: 0))
        path.addLine(to: point(x: self.drawingSize.width/2 + width/2, y: 0))
        path.addLine(to: point(x: self.drawingSize.width/2 + width/2,
                               y: self.drawingSize.height))
        path.addLine(to: point(x: self.drawingSize.width/2 - width/2,
                               y: self.drawingSize.height))
        
        path2.move   (to: point(x: 0, y: self.drawingSize.height * (1+self.process)/2))
        path2.addLine(to: point(x: self.drawingSize.width/2,
                                y: self.drawingSize.height - width * sqrt(2)))
        path2.addLine(to: point(x: self.drawingSize.width,
                                y: self.drawingSize.height * (1+self.process)/2))
        
        
        path.close()
    }
    
    func animate(to proccess: CGFloat) {
        makeShapeLayer()
    }
}

// MARK: - Preview

class TestViewController: UIViewController {
    var button: AnimationCloseButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: 37.5, y: 100, width: 300, height: 300)
        self.button = AnimationCloseButton(frame: frame)
        self.view.addSubview(button)
        
        let animateButton = UIButton(frame: CGRect(x: 100, y: 600, width: 100, height: 60))
        animateButton.setTitle("animate", for: .normal)
        animateButton.setTitleColor(.blue, for: .normal)
        animateButton.addTarget(self, action: #selector(animate), for: .touchUpInside)
        self.view.addSubview(animateButton)
    }
    
    @objc func animate() {
        self.button.animate(to: 1.0)
    }
}

@available(iOS 13, *)
struct MyButton: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> TestViewController {
        TestViewController()
    }
    func updateUIViewController(_ uiViewController: TestViewController, context: Context) {
    }
}

@available(iOS 13, *)
struct MyButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            MyButton()
        }
    }
}
