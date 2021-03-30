//
//  TestViewController.swift
//  LearnToWriteABC

import UIKit
import RxSwift
import RxCocoa

class TestViewController: UIViewController {
    
    //MARK: - IBOulet
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var nextQuestionButton: UIButton!
    @IBOutlet weak var firstAnswerButton: UIButton!
    @IBOutlet weak var secondAnswerButton: UIButton!
    @IBOutlet weak var thirdAnswerButton: UIButton!
    @IBOutlet weak var forthAnswerButton: UIButton!
    
    //MARK: - viewModel
    private var viewModel = TestViewModel()
    private var disposebag = DisposeBag()
    
    //MARK: - view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        binding()
    }

    //MARK: - binding
    private func binding() {
        let sendAnswer = Observable<Int>.merge(
            firstAnswerButton.rx.tap.map({ 1 }).asObservable(),
            secondAnswerButton.rx.tap.map({ 2 }).asObservable(),
            thirdAnswerButton.rx.tap.map({ 3 }).asObservable(),
            forthAnswerButton.rx.tap.map({ 4 }).asObservable()
        )

        let input = TestViewModel.Input(
            generateQuestion: rx.sentMessage(#selector(viewWillAppear(_:))).map({ _ in () }).asObservable(),
            sendAnswer: sendAnswer,
            nextQuestion: nextQuestionButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.question
            .drive(questionLabel.rx.text)
            .disposed(by: disposebag)
        
        output.answerButton
            .drive { (answers) in
                self.firstAnswerButton.setTitle("\(answers[0])", for: .normal)
                self.secondAnswerButton.setTitle("\(answers[1])", for: .normal)
                self.thirdAnswerButton.setTitle("\(answers[2])", for: .normal)
                self.forthAnswerButton.setTitle("\(answers[3])", for: .normal)
            }
            .disposed(by: disposebag)
        
        output.numberQuestion
            .map({ "第\($0)題" })
            .drive(questionNumberLabel.rx.text)
            .disposed(by: disposebag)
    }
}
