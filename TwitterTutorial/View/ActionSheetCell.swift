//
//  ActionSheetCell.swift
//  TwitterTutorial
//
//  Created by 조성규 on 2022/08/31.
//

import UIKit

class ActionSheetCell: UITableViewCell {
     
    // MARK: - Properties
    
    var option: ActionSheetOptions? {
        didSet { configure() }
    }
    
    private let optionImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "twitter_logo_blue")
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Test Option"
        return label
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(optionImageView)
        optionImageView.centerY(inView: self)
        optionImageView.anchor(leading: leadingAnchor, paddingLeading: 8)
        optionImageView.setDimensions(width: 36, height: 36)
        
        contentView.addSubview(titleLabel)
        titleLabel.centerY(inView: self)
        titleLabel.anchor(leading: optionImageView.trailingAnchor, paddingLeading: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configure(){
        titleLabel.text = option?.description
    }
    
}
