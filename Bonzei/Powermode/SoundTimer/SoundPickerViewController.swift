//
//  SoundPickerViewController.swift
//  Bonzei
//
//  Created by Tomasz on 03/08/2020.
//  Copyright © 2020 bonzei.app. All rights reserved.
//

import UIKit

class SoundPickerViewController: UIViewController {
    
    @IBOutlet weak var mainHeaderLabel: UILabel!
    @IBOutlet weak var soundHeaderLabel: UILabel!
    @IBOutlet weak var timeHeaderLabel: UILabel!
    @IBOutlet weak var durationPicker: PickerView!
    @IBOutlet weak var durationPickerSelectionRect: UIView!
    @IBOutlet weak var durationPickerOverlayTop: UIView!
    @IBOutlet weak var durationPickerOverlayBottom: UIView!
    @IBOutlet weak var soundsCollectionView: UICollectionView!
    
    private var customFlowLayout = SoundsCollectionViewFlowLayout()
    
    private var viewIsAppearing = true
    
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
    
    var timeHeader: String? {
        didSet {
            timeHeaderLabel.text = timeHeader
        }
    }
    
    var durations: [Int]? {
        didSet {
            guard durations != nil else { return }
            durationPicker.data = durations!.map() {"\($0) min"}
        }
    }

    private var selectedPowerNap: PowerNap?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSoundsCollectionView()
        setupMainHeader()
        setupSoundHeader()
        setupTimeHeader()
        setupDurationPicker()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isBeingPresented {
            viewIsAppearing = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Top overlay for the duration picker
        let topOverlayMask = CAGradientLayer()
        topOverlayMask.frame = durationPickerOverlayTop.bounds
        topOverlayMask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        topOverlayMask.locations = [0.5, 1.0]
        durationPickerOverlayTop.layer.mask = topOverlayMask
        
        // Bottom overlay for the duration picker
        let bottomOverlayMask = CAGradientLayer()
        bottomOverlayMask.frame = durationPickerOverlayBottom.bounds
        bottomOverlayMask.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        bottomOverlayMask.locations = [0.0, 0.5]
        durationPickerOverlayBottom.layer.mask = bottomOverlayMask
        
    }
    
    private func setupSoundsCollectionView() {
        soundsCollectionView.decelerationRate = .fast
        soundsCollectionView.isPagingEnabled = false
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
    
    private func setupDurationPicker() {
        durations = [10, 15, 25]
        durationPicker.scrollView.decelerationRate = .fast
        durationPicker.font = UIFont(name: "Muli-Regular", size: 24)
        durationPicker.textColor = UIColor(red: 0.42, green: 0.42, blue: 0.42, alpha: 0.5)
        durationPicker.textColorSelected = BonzeiColors.jungleGreen
        
        durationPickerSelectionRect.backgroundColor = UIColor.clear
        durationPickerSelectionRect.layer.borderWidth = 1.0
        durationPickerSelectionRect.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.00).cgColor
        durationPickerSelectionRect.layer.cornerRadius = 8.0
        durationPickerSelectionRect.isUserInteractionEnabled = false
        
        durationPickerOverlayTop.backgroundColor = view.backgroundColor
        durationPickerOverlayTop.isUserInteractionEnabled = false
        durationPickerOverlayBottom.backgroundColor = view.backgroundColor
        durationPickerOverlayBottom.isUserInteractionEnabled = false
        
        durationPicker.selectItem(withIndex: 1)
    }
    
    // MARK:- Private API
    
    private func getSelectedPowerNap() -> PowerNap? {
        
        let x = view.bounds.width / 2.0
        let y = soundsCollectionView.frame.origin.y + soundsCollectionView.frame.height / 2.0
        
        let center = view.convert(CGPoint(x: x, y: y), to: soundsCollectionView)
        
        if let indexPath = soundsCollectionView.indexPathForItem(at: center) {
            return sounds[indexPath.row]
        }
        return nil
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        guard let powerNap = getSelectedPowerNap() else { return }
        selectedPowerNap = powerNap
        performSegue(withIdentifier: "SoundPickerToSoundTimer", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SoundPickerToSoundTimer" {
            let soundTimerVC = segue.destination as! SoundTimerViewController
            soundTimerVC.powerNap = selectedPowerNap!
        }
    }
    
    @IBAction func unwindToSoundPicker(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    
}

//MARK:- UICollectionViewDataSource
extension SoundPickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sounds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SoundCell.reuseId, for: indexPath) as! SoundCell
        let powerNap = sounds[indexPath.row]
        
        // appearance of the cell
        cell.layer.cornerRadius = cell.frame.height/2.0
        cell.backgroundColor = UIColor(hexString: powerNap.coverColor)
        cell.tagBackground.layer.cornerRadius = 3.0
        
        // contents of the cell
       
        cell.tagLabel.text = powerNap.waveType
        cell.melodyNameLabel.text = powerNap.melodyName
        cell.descriptionLabel.text = powerNap.description

        if viewIsAppearing {
            viewIsAppearing = false
            if indexPath.row == 0 {
                cell.select()
            }
        }
        
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
        let cellSize = collectionView!.frame.height / 1.5
        itemSize = CGSize(width: cellSize, height: cellSize)
        minimumLineSpacing = 0.355 * cellSize
        
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
    
        let k = velocity.x > 0 ? ceil((deltaX + inset) / distanceBetweenCellCenters) : floor((deltaX + inset) / distanceBetweenCellCenters)
        
        return CGPoint(x: k * distanceBetweenCellCenters - inset, y: proposedContentOffset.y)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
}

//MARK:- SoundCell
class SoundCell: UICollectionViewCell {
    static let reuseId = "SoundCell"
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagBackground: UIView!
    @IBOutlet weak var melodyNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    /// marks the cell as selected
    func select() {
        self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    }
    
    func deselect() {
        self.transform = CGAffineTransform.identity
    }
}
