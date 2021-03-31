//
//  TestViewController.swift
//  LearnToWriteABC

import UIKit
import RxSwift
import RxCocoa
import SCLAlertView

class TestViewController: UIViewController {
    
    //MARK: - IBOulet
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var nextQuestionButton: UIButton!
    @IBOutlet weak var firstAnswerButton: UIButton!
    @IBOutlet weak var secondAnswerButton: UIButton!
    @IBOutlet weak var thirdAnswerButton: UIButton!
    @IBOutlet weak var forthAnswerButton: UIButton!
    @IBOutlet weak var isCorrectLabel: UILabel!
    
    lazy var restartButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "重新开始", style: .done, target: nil, action: nil)
        return button
    }()
    
    //MARK: - viewModel
    private var viewModel = TestViewModel()
    private var disposebag = DisposeBag()
    
    //MARK: - view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
    
    //MARK: - set up UI
    private func setupUI() {
        title = "测验"
        navigationItem.rightBarButtonItems = [restartButton]
        setAlert()
    }
    
    private func setAlert() {
        SCLAlertView().showInfo("测验规则", subTitle: "总共10题，请依序选择答案，并点下一题")
    }
    
    private func finishAlert(_ number: Int) {
        SCLAlertView().showSuccess("恭喜完成", subTitle: "您總共對 \(number) 題")
    }

    //MARK: - binding
    private func binding() {
        let sendAnswer = Observable<Int>.merge(
            firstAnswerButton.rx.tap.map({ 0 }).asObservable(),
            secondAnswerButton.rx.tap.map({ 1 }).asObservable(),
            thirdAnswerButton.rx.tap.map({ 2 }).asObservable(),
            forthAnswerButton.rx.tap.map({ 3 }).asObservable()
        )

        let input = TestViewModel.Input(
            generateQuestion: rx.sentMessage(#selector(viewWillAppear(_:))).map({ _ in () }).asObservable(),
            sendAnswer: sendAnswer,
            nextQuestion: nextQuestionButton.rx.tap.asObservable(),
            restart: restartButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.question
            .drive(questionLabel.rx.text)
            .disposed(by: disposebag)
        
        output.answerButton
            .drive { [unowned self](answers) in
                [firstAnswerButton, secondAnswerButton, thirdAnswerButton, forthAnswerButton]
                    .forEach({ $0?.isEnabled = true })
                self.firstAnswerButton.setTitle("\(answers[0])", for: .normal)
                self.secondAnswerButton.setTitle("\(answers[1])", for: .normal)
                self.thirdAnswerButton.setTitle("\(answers[2])", for: .normal)
                self.forthAnswerButton.setTitle("\(answers[3])", for: .normal)
                self.isCorrectLabel.text = ""
            }
            .disposed(by: disposebag)
        
        output.isCorrect
            .do(onNext: { [unowned self](_) in
                [firstAnswerButton, secondAnswerButton, thirdAnswerButton, forthAnswerButton]
                    .forEach({ $0?.isEnabled = false })
            })
            .map({ $0 ? "⭕️": "❌" })
            .drive(isCorrectLabel.rx.text)
            .disposed(by: disposebag)
        
        output.finish
            .drive { [unowned self]times in
                self.nextQuestionButton.isHidden = true
                self.finishAlert(times)
            }
            .disposed(by: disposebag)
        
        output.numberQuestion
            .map({ "第 \($0) 題" })
            .drive(questionNumberLabel.rx.text)
            .disposed(by: disposebag)
        
        output.nextButtonIsHidden
            .drive(nextQuestionButton.rx.isHidden)
            .disposed(by: disposebag)
                
    }
}
