//
//  TestViewModel.swift
//  LearnToWriteABC

import Foundation
import RxSwift
import RxCocoa

class TestViewModel: ViewModelType {
    
    //MARK: - Input
    struct Input {
        var generateQuestion: Observable<Void>
        var sendAnswer: Observable<Int>
        var nextQuestion: Observable<Void>
        var restart: Observable<Void>
    }
    
    //MARK: - Output
    struct Output {
        var question: Driver<String>
        var answerButton: Driver<[String]>
        var numberQuestion: Driver<Int>
        var isCorrect: Driver<Bool>
        var nextButtonIsHidden: Driver<Bool>
        var finish: Driver<Int>
    }
    
    //MARK: - porperties
    private var disposeBag = DisposeBag()
    private var capitalData = BehaviorRelay<[String]>(value: [])
    private var uppercaseData = BehaviorRelay<[String]>(value: [])
    private var numberQuestionRelay = BehaviorRelay<Int>(value: 1)
    private var questionSubject = PublishSubject<String>()
    private var radomIndex = PublishSubject<Int>()
    private var isCapital = PublishSubject<Bool>()
    private var answerButtonSubject = PublishSubject<[String]>()
    private var generateQuestionSubject = PublishSubject<Void>()
    private var isCorrectSubject = PublishSubject<Bool>()
    private var correctTime = BehaviorRelay<Int>(value: 0)
    private var nextButtonIsHiddenSubject = PublishSubject<Bool>()
    private var finishSubject = PublishSubject<Int>()
    
    init() {
        WordData().createData()
            .subscribe { [unowned self](data) in
                let capital = data.enumerated().filter({ $0.offset % 2 == 0 }).map({ $0.element })
                let uppercase = data.enumerated().filter({ $0.offset % 2 == 1 }).map({ $0.element })
                self.capitalData.accept(capital)
                self.uppercaseData.accept(uppercase)
            } onFailure: { (error) in
                if let error = error as? WordDataError {
                    print(error.rawValue)
                }
                print(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - binding
    func transform(input: Input) -> Output {
        
        generateQuestionSubject
            .do(onNext: { [unowned self](_) in
                let bool = Bool.random()
                self.isCapital.onNext(bool)
            })
            .map { (_) -> Int in
                let answer = (0...25).randomElement()!
                return answer
            }
            .bind(to: radomIndex)
            .disposed(by: disposeBag)
        
        Observable.zip(isCapital, radomIndex)
            .do(onNext: { [unowned self](bool, index) in
                let question = bool ?
                    self.capitalData.value[index]: self.uppercaseData.value[index]
                self.questionSubject.onNext(question)
            })
            .map { [unowned self](bool, index) -> [String] in
                var answers: [Int] = []
                answers.append(index)
                while answers.count < 4 {
                    let answer = (0...25).randomElement()!
                    index == answer ? nil: answers.append(answer)
                }
                answers.shuffle()
                return answers
                    .map({ bool ? self.uppercaseData.value[$0]: self.capitalData.value[$0] })
            }
            .bind(to: answerButtonSubject)
            .disposed(by: disposeBag)
        
        isCorrectSubject
            .filter({ $0 == true })            
            .withLatestFrom(correctTime)
            .map({ $0 + 1 })
            .bind(to: correctTime)
            .disposed(by: disposeBag)
        
        isCorrectSubject
            .withLatestFrom(numberQuestionRelay)
            .filter({ $0 == 10 })
            .withLatestFrom(correctTime)
            .bind(to: finishSubject)
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                isCorrectSubject
                    .withLatestFrom(numberQuestionRelay)
                    .map({ $0 == 10 ? true: false }),
                generateQuestionSubject.map({ _ in true })
            )
            .bind(to: nextButtonIsHiddenSubject)
            .disposed(by: disposeBag)
        
        input.generateQuestion
            .bind(to: generateQuestionSubject)
            .disposed(by: disposeBag)
        
        input.nextQuestion
            .withLatestFrom(numberQuestionRelay)
            .filter({ $0 < 10 })
            .map({ _ in () })
            .bind(to: generateQuestionSubject)
            .disposed(by: disposeBag)
        
        input.nextQuestion
            .withLatestFrom(numberQuestionRelay)
            .filter({ $0 < 10 })            
            .map({ $0 + 1 })
            .bind(to: numberQuestionRelay)
            .disposed(by: disposeBag)
        
        let sendData = Observable.combineLatest(isCapital, radomIndex, input.sendAnswer, answerButtonSubject)
        
        input.sendAnswer
            .withLatestFrom(sendData)
            .map { (isCapital, radomIndex, selectIndex, answers) -> Bool in
                let answer = isCapital ?
                    self.uppercaseData.value[radomIndex]: self.capitalData.value[radomIndex]
                let selectAnswer = answers[selectIndex]                
                return answer == selectAnswer
            }
            .bind(to: isCorrectSubject)
            .disposed(by: disposeBag)
        
        input.restart
            .map({ 1 })
            .bind(to: numberQuestionRelay)
            .disposed(by: disposeBag)
        
        input.restart
            .bind(to: generateQuestionSubject)
            .disposed(by: disposeBag)
        
        input.restart
            .map({ 0 })
            .bind(to: correctTime)
            .disposed(by: disposeBag)

        return Output(
            question: questionSubject.asDriver(onErrorJustReturn: "A"),
            answerButton: answerButtonSubject.asDriver(onErrorJustReturn: []),
            numberQuestion: numberQuestionRelay.asDriver(),
            isCorrect: isCorrectSubject.asDriver(onErrorJustReturn: false),
            nextButtonIsHidden: nextButtonIsHiddenSubject.asDriver(onErrorJustReturn: true),
            finish: finishSubject.asDriver(onErrorJustReturn: 0))
    }
    
}
