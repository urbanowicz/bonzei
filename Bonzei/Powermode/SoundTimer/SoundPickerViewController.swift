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
    
}

//MARK:- UICollectionViewDelegateFlowLayout
extension SoundPickerViewController: UICollectionViewDelegateFlowLayout {
    
}

//MARK:- SoundsCollectionViewFlowLayout
class SoundsCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        scrollDirection = .horizontal
        minimumInteritemSpacing = 24.0
        minimumLineSpacing = 24.0
        itemSize = CGSize(width: 275, height: 275)
    }
}

//MARK:- SoundCell
class SoundCell: UICollectionViewCell {
    static let reuseId = "SoundCell"
}
