//
//  DrawViewController.swift
//  LearnToWriteABC

import UIKit
import RxCocoa
import RxSwift
import SCLAlertView

class DrawViewController: UIViewController {
    
    //MARK: - IBOulet
    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var selectCollectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var selectWordLabel: UILabel!    
    @IBOutlet weak var selectTypeSegment: UISegmentedControl!
    @IBOutlet weak var playVoiceButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var previousImageButton: UIButton!
    @IBOutlet weak var brushWidthSlider: UISlider!
    @IBOutlet weak var latticeImageView: UIImageView!
    
    //MARK: - properties
    var viewModel = DrawViewModel()
    private var disposebag = DisposeBag()
    
    //MARK: - view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()        
        setupUI()
        binding()
    }
    
    //MARK: - set up UI
    private func setupUI() {
        title = "写字"
        
        [clearButton, playVoiceButton, previousImageButton].forEach({
            $0?.layer.cornerRadius = clearButton.frame.height / 4
        })
        
        setShareButton()
        
        brushWidthSlider.value = 10
        selectCollectionView.register(UINib(nibName: "SelectCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SelectCollectionViewCell")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let width = selectCollectionView.frame.height / 2
        layout.itemSize = CGSize(width: width, height: width)
        selectCollectionView.collectionViewLayout = layout        
    }
    
    private func setShareButton() {
        let shareButton = UIBarButtonItem(title: "分享", style: .done, target: self, action: #selector(shareAction))
        navigationItem.rightBarButtonItems = [shareButton]
    }
    
    @objc func shareAction() {
        guard let image = drawView.mainImageView.image else { return }
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activity, animated: true)
    }
    
    //MARK: - binding
    private func binding() {
        let input = DrawViewModel.Input(
            loadData: rx.sentMessage(#selector(viewDidLoad)).map({ _ in () }).asObservable(),
            loadColorData: rx.sentMessage(#selector(viewDidLoad)).map({ _ in () }).asObservable(),
            selectColor: selectCollectionView.rx.itemSelected.map({ $0.row }).asObservable(),
            nextWord: nextButton.rx.tap.asObservable(),
            previousWord: previousButton.rx.tap.asObservable(),
            chanegType: selectTypeSegment.rx.selectedSegmentIndex.asObservable(),
            playVoice: playVoiceButton.rx.tap.asObservable(),
            clearImage: clearButton.rx.tap.asObservable(),
            previousImage: previousImageButton.rx.tap.asObservable(),
            selectbrushWidth: brushWidthSlider.rx.value.asObservable())
        
        let output = viewModel.transform(input: input)
        output.color
            .drive(drawView.rx.color)
            .disposed(by: disposebag)
        
        output.allColor
            .drive(selectCollectionView.rx.items(cellIdentifier: "SelectCollectionViewCell", cellType: SelectCollectionViewCell.self)) { (index, model, cell) in
                cell.updata(model)
            }
            .disposed(by: disposebag)
        
        output.word
            .drive(wordLabel.rx.text)
            .disposed(by: disposebag)
        
        output.word
            .drive(selectWordLabel.rx.text)
            .disposed(by: disposebag)
        
        output.alert
            .drive { [unowned self](_) in
                self.alert()
            }
            .disposed(by: disposebag)
        
        output.clearImage
            .drive { [unowned self](_) in
                self.drawView.clearImage()
            }
            .disposed(by: disposebag)
        
        output.previousImage
            .drive { [unowned self](_) in
                self.drawView.previousImage()
            }
            .disposed(by: disposebag)
        
        output.brushWidth
            .map({ CGFloat($0) })
            .drive { [unowned self](value) in
                self.drawView.brushWidth = value
            }
            .disposed(by: disposebag)
        
    }

    //MARK: - function
    private func alert() {
        SCLAlertView().showError("错误", subTitle: "已经到底了...")
    }
    
}
