//
//  VerseViewController.swift
//  VVault
//
//  Created by Sean Zhang on 6/7/17.
//  Copyright © 2017 Sean Zhang. All rights reserved.
//

import Foundation
import UIKit

let twitterBlue = UIColor(r: 61, g: 167, b: 244) //#3da7f4

class VerseViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellID = "cellID"
    let headerID = "headerID"
    let footerID = "footerID"
    
    override func viewDidLoad() {
        print("The view loaded for the verse controller")
        collectionView?.register(VerseCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.register(VerseCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        collectionView?.register(VerseCollectionViewFooter.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerID)
        collectionView?.backgroundColor = .gray
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        cell.backgroundColor = UIColor.red
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath)
            return header
        } else {
            
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerID, for: indexPath)
            return footer
        }
    }
    
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return (CGSize(width: view.frame.width, height: 150))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return (CGSize(width: view.frame.width, height: 60))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return (CGSize(width: view.frame.width, height: 80))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

class VerseCollectionViewCell: UICollectionViewCell {
    
    var scriptureLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        label.text = "For all have sinned and fall short of the glory of God"
        label.backgroundColor = UIColor.blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var scriptureReferenceLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        label.text = "Romans 3:23"
        label.backgroundColor = UIColor.blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var scriptureImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        imageView.backgroundColor = UIColor.brown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var scriptureButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        button.backgroundColor = UIColor.cyan
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let separatorLineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.black
        lineView.translatesAutoresizingMaskIntoConstraints = false
        return lineView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCellView() {
        //setting up the cell view
        addSubview(scriptureLabel)
        addSubview(scriptureImageView)
        addSubview(scriptureButton)
        addSubview(scriptureReferenceLabel)
        addSubview(separatorLineView)
        
        // define x, y, width, height of the subview
        scriptureLabel.leftAnchor.constraint(equalTo: scriptureImageView.rightAnchor, constant: 5).isActive = true
        scriptureLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        scriptureLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        scriptureLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // define x, y, width, height of the subview
        scriptureImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        scriptureImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        scriptureImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        scriptureImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // define x, y, width, height of the subview
        scriptureButton.centerXAnchor.constraint(equalTo: scriptureImageView.centerXAnchor).isActive = true
        scriptureButton.topAnchor.constraint(equalTo: scriptureImageView.bottomAnchor, constant: 5).isActive = true
        scriptureButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        scriptureButton.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        // define x, y, width, height of the subview
        scriptureReferenceLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        scriptureReferenceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        scriptureReferenceLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        scriptureReferenceLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // define x, y, width, height of the subview
        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorLineView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
}

class VerseCollectionViewHeader: UICollectionViewCell{
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Verses To be Memorized"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = twitterBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeaderView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupHeaderView() {
        addSubview(textLabel)
        backgroundColor = UIColor.white
        // define x, y, width, height of the subview
        textLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        textLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        textLabel.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        textLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
}

class VerseCollectionViewFooter: UICollectionViewCell {
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Discover More Topical Verses"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = twitterBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFooterView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupFooterView() {
        addSubview(textLabel)
        
        // define x, y, width, height of the subview
        textLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        textLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        textLabel.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        textLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
}




