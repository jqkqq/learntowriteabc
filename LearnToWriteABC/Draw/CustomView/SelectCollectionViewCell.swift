//
//  SelectCollectionViewCell.swift
//  LearnToWriteABC

import UIKit

class SelectColor {
    var color: UIColor
    var select = false
    
    init(color: UIColor) {
        self.color = color
    }
}

class SelectCollectionViewCell: UICollectionViewCell {
    
    //MARK: - IBOulet
    @IBOutlet weak var myBackgroundView: UIView!
    @IBOutlet weak var selectImageView: UIImageView!
    
    //MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
        myBackgroundView.layer.cornerRadius = 10
    }
    
    func updata(_ data: SelectColor) {
        myBackgroundView.backgroundColor = data.color
        selectImageView.isHidden = !data.select
    }

}
