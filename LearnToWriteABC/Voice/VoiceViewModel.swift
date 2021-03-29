//
//  VoiceViewModel.swift
//  LearnToWriteABC

import Foundation
import RxSwift
import RxCocoa
import AVFoundation

class VoiceViewModel: ViewModelType {
    
    //MARK: - Inputs
    struct Input {
        var loadData: Observable<Void>
        var nextAction: Observable<Void>
        var previousAction: Observable<Void>
        var chanegType: Observable<Int>
        var playVoice: Observable<Void>
    }
    
    //MARK: - Outputs
    struct Output {
        var word: Driver<String>
        var alert: Driver<Void>
    }
    
    //MARK: - private
    private var totalData = BehaviorRelay<[String]>(value: [])
    private var data = BehaviorRelay<[String]>(value: [])
    private var wordRelay = BehaviorRelay<String>(value: "")
    private var seletIndex = BehaviorRelay<Int>(value: 0)
    private var alertSubject = PublishSubject<Void>()
    private var playVoiceSubject = PublishSubject<Void>()
    private var disposebag = DisposeBag()
    
    //MARK: - function
    func transform(input: Input) -> Output {
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
        
        seletIndex
            .filter({ $0 >= 0 })
            .withLatestFrom(data)
            .filter({
                let max = self.seletIndex.value
                return $0.count >= max
            })
            .map { [unowned self](data) -> String in
                let index = self.seletIndex.value
                return data[index]
            }
            .bind(to: wordRelay)
            .disposed(by: disposebag)
        
        data
            .withLatestFrom(seletIndex)
            .map { (index) -> String in
                self.data.value[index]
            }
            .bind(to: wordRelay)
            .disposed(by: disposebag)
        
        wordRelay            
            .skip(1)
            .map({ _ in () })
            .bind(to: playVoiceSubject)
            .disposed(by: disposebag)
        
        playVoiceSubject
            .subscribe { [unowned self](_) in
                let speechSynthesizer = AVSpeechSynthesizer()
                let speechUtterance = AVSpeechUtterance(string: self.data.value[self.seletIndex.value])
                speechUtterance.voice = AVSpeechSynthesisVoice(language: "zh-cn")
                speechSynthesizer.speak(speechUtterance)
            }
            .disposed(by: disposebag)
        
        input.nextAction
            .withLatestFrom(seletIndex)
            .map { [unowned self](number) -> Bool in
                let max = self.data.value.count - 1
                return number < max
            }
            .do(onNext: { [unowned self](bool) in
                bool ? nil: self.alertSubject.onNext(())
            })
            .filter({ $0 == true })
            .withLatestFrom(seletIndex)
            .map({ $0 + 1 })
            .bind(to: seletIndex)
            .disposed(by: disposebag)
        
        input.previousAction
            .withLatestFrom(seletIndex)
            .map ({ $0 > 0 })
            .do(onNext: { [unowned self](bool) in
                bool ? nil: self.alertSubject.onNext(())
            })
            .filter({ $0 == true })
            .withLatestFrom(seletIndex)
            .map({ $0 - 1 })
            .bind(to: seletIndex)
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

        return Output(
            word: wordRelay.asDriver(),
            alert: alertSubject.asDriver(onErrorJustReturn: ())
        )
    }
    
}
