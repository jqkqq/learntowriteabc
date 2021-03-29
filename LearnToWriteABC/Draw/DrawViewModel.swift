//
//  DrawViewModel.swift
//  LearnToWriteABC

import Foundation
import RxSwift
import RxCocoa
import AVFoundation

class DrawViewModel: ViewModelType {
    
    //MARK: - Input
    struct Input {
        var loadData: Observable<Void>
        var loadColorData: Observable<Void>
        var selectColor: Observable<Int>
        var nextWord: Observable<Void>
        var previousWord: Observable<Void>
        var chanegType: Observable<Int>
        var playVoice: Observable<Void>
        var clearImage: Observable<Void>
        var previousImage: Observable<Void>
        var selectbrushWidth: Observable<Float>
    }
    
    //MARK: - Output
    struct Output {
        var allColor: Driver<[SelectColor]>
        var color: Driver<UIColor>
        var word: Driver<String>
        var alert: Driver<Void>
        var clearImage: Driver<Void>
        var previousImage: Driver<Void>
        var brushWidth: Driver<Float>
    }
    
    //MARK: - private
    private let disposebag = DisposeBag()
    private var colorRelay = BehaviorRelay<UIColor>(value: .black)
    private var allColorRelay = BehaviorRelay<[SelectColor]>(value: [])
    private var data = BehaviorRelay<[String]>(value: [])
    private var totalData = BehaviorRelay<[String]>(value: [])
    private var selectWord = BehaviorRelay<Int>(value: 0)
    private var wordRelay = BehaviorRelay<String>(value: "")
    private var alertSubject = PublishSubject<Void>()
    private var clearImageSubject = PublishSubject<Void>()
    private var playVoiceSubject = PublishSubject<Void>()
    private var brushWidthRelay = BehaviorRelay<Float>(value: 15)
    
    //MARK: - functions
    func transform(input: Input) -> Output {
        
        AllColor().createColorData()
            .subscribe { [unowned self](colors) in
                self.allColorRelay.accept(colors)
            } onFailure: { (error) in
                print(error.localizedDescription)
            }
            .disposed(by: disposebag)
        
        WordData().createData()
            .subscribe { [unowned self](data) in
                let capitalData = data.enumerated()
                    .filter({ $0.offset % 2 == 0 })
                    .map({ $0.element })
                self.data.accept(capitalData)
                self.totalData.accept(data)
            } onFailure: { (error) in
                if let error = error as? WordDataError {
                    print(error.rawValue)
                }
                print(error.localizedDescription)
            }
            .disposed(by: disposebag)
        
        selectWord
            .filter({ $0 >= 0 })
            .withLatestFrom(data)
            .filter({
                let max = self.selectWord.value
                return $0.count >= max
            })
            .map { [unowned self](data) -> String in
                let index = self.selectWord.value
                return data[index]
            }
            .bind(to: wordRelay)
            .disposed(by: disposebag)
        
        wordRelay
            .map({ _ in () })
            .bind(to: clearImageSubject)
            .disposed(by: disposebag)
        
        playVoiceSubject
            .subscribe { [unowned self](_) in
                let speechSynthesizer = AVSpeechSynthesizer()
                let speechUtterance = AVSpeechUtterance(string: self.data.value[self.selectWord.value])
                speechUtterance.voice = AVSpeechSynthesisVoice(language: "zh-cn")
                speechSynthesizer.speak(speechUtterance)
            }
            .disposed(by: disposebag)
        
        data
            .map { [unowned self](data) -> String in
                return data[self.selectWord.value]
            }
            .bind(to: wordRelay)
            .disposed(by: disposebag)

        input.selectColor
            .map { [unowned self](index) -> UIColor in
                self.allColorRelay.value[index].color
            }
            .bind(to: colorRelay)
            .disposed(by: disposebag)
        
        input.selectColor
            .map({ (index) -> [SelectColor] in
                self.allColorRelay.value.enumerated().forEach({
                    $0.element.select = $0.offset == index ? true: false
                })
                return self.allColorRelay.value
            })
            .bind(to: allColorRelay)
            .disposed(by: disposebag)
        
        input.nextWord
            .withLatestFrom(selectWord)
            .map { [unowned self](number) -> Bool in
                let max = self.data.value.count - 1
                return number < max
            }
            .do(onNext: { [unowned self](bool) in
                bool ? nil: self.alertSubject.onNext(())
            })
            .filter({ $0 == true })
            .withLatestFrom(selectWord)
            .map({ $0 + 1 })
            .bind(to: selectWord)
            .disposed(by: disposebag)
        
        input.previousWord
            .withLatestFrom(selectWord)
            .map({ $0 > 0 })
            .do(onNext: { [unowned self](bool) in
                bool ? nil: self.alertSubject.onNext(())
            })
            .filter({ $0 == true })
            .withLatestFrom(selectWord)
            .map({ $0 - 1 })
            .bind(to: selectWord)
            .disposed(by: disposebag)
        
        input.chanegType
            .map { (selectIndex) -> [String] in
                let capitalData = self.totalData.value.enumerated()
                    .filter({ $0.offset % 2 == selectIndex })
                    .map({ $0.element })
                return capitalData
            }
            .bind(to: data)
            .disposed(by: disposebag)
        
        input.playVoice
            .bind(to: playVoiceSubject)
            .disposed(by: disposebag)
        
        input.clearImage
            .bind(to: clearImageSubject)
            .disposed(by: disposebag)
        
        input.selectbrushWidth
            .bind(to: brushWidthRelay)
            .disposed(by: disposebag)
        
        return Output(
            allColor: allColorRelay.asDriver(),
            color: colorRelay.asDriver(),
            word: wordRelay.asDriver(),
            alert: alertSubject.asDriver(onErrorJustReturn: ()),
            clearImage: clearImageSubject.asDriver(onErrorJustReturn: ()),
            previousImage: input.previousImage.asDriver(onErrorJustReturn: ()),
            brushWidth: brushWidthRelay.asDriver(onErrorJustReturn: 15))
    }
    
}
