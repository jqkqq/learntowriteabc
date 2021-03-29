//
//  VoiceViewController.swift
//  LearnToWriteABC

import UIKit
import RxSwift
import RxCocoa
import SCLAlertView

class VoiceViewController: UIViewController {
    
    //MARK: - IBOulet
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var playVoiceButton: UIButton!
    @IBOutlet weak var wordTypeSegment: UISegmentedControl!
    
    //MARK: - properties
    var viewModel = VoiceViewModel()
    private var disposebag = DisposeBag()

    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "发音"
        binding()
    }
    
    //MARK: - binding
    func binding() {
        let input = VoiceViewModel
            .Input(
                loadData: rx.sentMessage(#selector(viewDidLoad)).map({ _ in () }),
                nextAction: nextButton.rx.tap.asObservable(),
                previousAction: previousButton.rx.tap.asObservable(),
                chanegType: wordTypeSegment.rx.selectedSegmentIndex.asObservable(),
                playVoice: playVoiceButton.rx.tap.asObservable()
            )
        let output = viewModel.transform(input: input)
        
        output.word
            .drive(wordLabel.rx.text)
            .disposed(by: disposebag)
        
        output.alert
            .drive { [unowned self](_) in
                self.alert()
            }
            .disposed(by: disposebag)
    }
    
    //MARK: - function
    private func alert() {
        SCLAlertView().showError("错误", subTitle: "已经到底了...")
    }

}
