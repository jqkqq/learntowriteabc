//
//  ExtensionDrawView.swift
//  LearnToWriteABC

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: DrawView {
    
    var color: Binder<UIColor> {
        return Binder(self.base) { (drawView, color) in
            drawView.color = color
        }
    }
    
    var brushWidth: Binder<CGFloat> {
        return Binder(self.base) { (drawView, width) in
            drawView.brushWidth = width
        }
    }
    
    var opacity: Binder<CGFloat> {
        return Binder(self.base) { (drawView, opacity) in
            drawView.opacity = opacity
        }
    }
    
}
