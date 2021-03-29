//
//  DrawView.swift
//  LearnToWriteABC

import UIKit
import SnapKit

class DrawView: UIView {
    
    //MARK: - UI
    lazy var mainImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var tempImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    //MARK: - 繪圖的屬性
    var color = UIColor.black
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    private var lastPoint = CGPoint.zero
    private var swiped = false
    private var saveImages: [UIImage] = []
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        
        addSubview(mainImageView)
        mainImageView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        
        addSubview(tempImageView)
        tempImageView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
    }

    //MARK: - override touch 系列
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        swiped = false
        lastPoint = touch.location(in: tempImageView)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        swiped = true
        let currentPoint = touch.location(in: tempImageView)
        drawLine(from: lastPoint, to: currentPoint)
        lastPoint = currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped{
            drawLine(from: lastPoint, to: lastPoint)
        }
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: tempImageView.bounds, blendMode: .normal, alpha: 1.0)
        tempImageView.image?.draw(in: tempImageView.bounds, blendMode: .normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        tempImageView.image = nil
        guard let saveImage = mainImageView.image else {
            return
        }
        saveImages.append(saveImage)               
    }
    
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContext(tempImageView.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        tempImageView.image?.draw(in: tempImageView.bounds)
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(color.cgColor)
        context.strokePath()
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    func clearImage() {
        mainImageView.image = nil
        saveImages.removeAll()
    }
    
    func previousImage() {
        if !saveImages.isEmpty {
            saveImages.removeLast()
            guard let saveImage = saveImages.last else {
                clearImage()
                return
            }
            mainImageView.image = saveImage
        }
    }

}
