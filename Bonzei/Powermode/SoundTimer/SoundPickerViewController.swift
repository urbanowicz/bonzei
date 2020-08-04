//
//  SoundPickerViewController.swift
//  Bonzei
//
//  Created by Tomasz on 03/08/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class SoundPickerViewController: UIViewController {
    
    let sounds = ["Rainforest", "Infinite Bliss", "Foamy Waves"]
    
    @IBOutlet weak var mainHeaderLabel: UILabel!
    @IBOutlet weak var soundHeaderLabel: UILabel!
    @IBOutlet weak var soundsCollectionView: UICollectionView!
    
    private var customFlowLayout = SoundsCollectionViewFlowLayout()
    
    private var centerCell: SoundCell?
    
    var mainHeader: String? {
        didSet {
            mainHeaderLabel.text = mainHeader
        }
    }
    
    var soundHeader: String? {
        didSet {
            soundHeaderLabel.text = soundHeader
        }
    }
    
    var timeHeader: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSoundsCollectionView()
        setupMainHeader()
        setupSoundHeader()
        setupTimeHeader()
        
        // Do any additional setup after loading the view.
    }
        
    private func setupSoundsCollectionView() {
        soundsCollectionView.decelerationRate = .fast
        soundsCollectionView.backgroundColor = UIColor.systemGray3
        soundsCollectionView.delegate = self
        soundsCollectionView.dataSource = self
        soundsCollectionView.collectionViewLayout = customFlowLayout
        soundsCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func setupMainHeader() {
        mainHeader = "Power nap"
    }
    
    private func setupSoundHeader() {
        soundHeader = "BINAURAL BEAT"
    }
    
    private func setupTimeHeader() {
        timeHeader = "NAP TIME"
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
    }
}

//MARK:- UICollectionViewDataSource
extension SoundPickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sounds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SoundCell.reuseId, for: indexPath)
        
        cell.layer.cornerRadius = cell.frame.height/2.0
        cell.backgroundColor = UIColor.systemRed
        
        return cell
    }
}

//MARK:- UICollectionViewDelegate
extension SoundPickerViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView is UICollectionView else { return }
        
        let visibleCells = soundsCollectionView.visibleCells
        let inset = soundsCollectionView.contentInset.left
        let cellWidth = customFlowLayout.itemSize.width
        let distanceBetweenCellCenters = cellWidth + customFlowLayout.minimumLineSpacing
        
        for cell in visibleCells {
            let k = abs(cell.center.x - (scrollView.contentOffset.x + inset + cellWidth/2.0)) / distanceBetweenCellCenters
            let scaleFactor = CGFloat(1.0 + (1 - k) * 0.5)
            if k < 1 {
                cell.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            } else {
                cell.transform = CGAffineTransform.identity
            }
        }
        
    }
}

//MARK:- UICollectionViewDelegateFlowLayout
extension SoundPickerViewController: UICollectionViewDelegateFlowLayout {

}

//MARK:- SoundsCollectionViewFlowLayout
class SoundsCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        scrollDirection = .horizontal
        minimumLineSpacing = 65.0
        itemSize = CGSize(width: 183, height: 183)
        
        let sideInset = (collectionView!.frame.width - itemSize.width) / 2.0
        collectionView!.contentInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard collectionView != nil else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        let inset = collectionView!.contentInset.left
        let deltaX = proposedContentOffset.x
        
        let distanceBetweenCellCenters = itemSize.width + minimumLineSpacing
    
        let k = round((deltaX + inset) / distanceBetweenCellCenters)
        
        return CGPoint(x: k * distanceBetweenCellCenters - inset, y: proposedContentOffset.y)
    }
}

//MARK:- SoundCell
class SoundCell: UICollectionViewCell {
    static let reuseId = "SoundCell"
    
    /// marks the cell as selected
    func scaleBy(factor: Double) {
        self.transform = CGAffineTransform(scaleX: CGFloat(factor), y: CGFloat(factor))
    }
    
    func deselect() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
    }
}
