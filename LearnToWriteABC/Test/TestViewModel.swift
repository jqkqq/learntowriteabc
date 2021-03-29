//
//  TestViewModel.swift
//  LearnToWriteABC

import Foundation
import RxSwift
import RxCocoa

class TestViewModel: ViewModelType {
    
    //MARK: - Input
    struct Input {
        var loadData: Observable<Void>
        var sendAnswer: Observable<String>
        var nextQuestion: Observable<Void>
    }
    
    //MARK: - Output
    struct Output {
        
    }
    
    //MARK: - porperties
    private var disposeBag = DisposeBag()
    private var capitalData = BehaviorRelay<[String]>(value: [])
    private var uppercaseData = BehaviorRelay<[String]>(value: [])
    private var numberQuestion = BehaviorRelay<Int>(value: 1)
    private var question = PublishSubject<String>()
    
    //MARK: - binding
    func transform(input: Input) -> Output {
        
        WordData().createData()
            .subscribe { [unowned self](data) in
                let capital = data.enumerated().filter({ $0.offset % 2 == 0 }).map({ $0.element })
                let uppercase = data.enumerated().filter({ $0.offset % 2 == 0 }).map({ $0.element })
                self.capitalData.accept(capital)
                self.uppercaseData.accept(uppercase)
            } onFailure: { (error) in
                if let error = error as? WordDataError {
                    print(error.rawValue)
                }
                print(error.localizedDescription)
            }
            .disposed(by: disposeBag)
        
        input.loadData
            .

        
        
        
        return Output()
    }
    
}
