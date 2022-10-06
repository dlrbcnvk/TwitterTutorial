//
//  EditProfileCell.swift
//  TwitterTutorial
//
//  Created by 조성규 on 2022/09/06.
//

import UIKit

protocol EditProfileCellDelegate: AnyObject {
    func updateUserInfo(_ cell: EditProfileCell)
}

class EditProfileCell: UITableViewCell {
    
    // MARK: - Properties
    
    var viewModel: EditProfileViewModel? {
        didSet { configure() }
    }
    weak var delegate: EditProfileCellDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var infoTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textAlignment = .left
        tf.textColor = .twitterBlue
        tf.addTarget(self, action: #selector(handleUpdateUserInfo), for: .editingDidEnd)
        tf.text = "Test Your Attirbute"
        tf.keyboardType = .default
        return tf
    }()
    
    let bioTextView: InputTextView = {
        let tv = InputTextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.placeholderLabel.isHidden = true
        return tv
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        titleLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        titleLabel.centerY(inView: self, leadingAnchor: leadingAnchor, paddingLeading: 16)
        
        addSubview(infoTextField)
        infoTextField.centerY(inView: self, leadingAnchor: titleLabel.trailingAnchor, paddingLeading: 8)
        infoTextField.anchor(trailing: trailingAnchor, paddingTrailing: 16)
        
        contentView.addSubview(bioTextView) 
        bioTextView.anchor(top: topAnchor, leading: titleLabel.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, paddingTop: 4, paddingLeading: 16, paddingTrailing: 8)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateUserInfo), name: UITextView.textDidEndEditingNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleUpdateUserInfo(){
        delegate?.updateUserInfo(self)
    }
    
    // MARK: - Helpers
    
    func configure(){
        guard let viewModel = viewModel else {
            return
        }
        infoTextField.isHidden = viewModel.shouldHideTextField
        bioTextView.isHidden = viewModel.shouldHideTextView
        
        titleLabel.text = viewModel.titleText
        infoTextField.text = viewModel.optionValue
        bioTextView.text = viewModel.optionValue
    }
}
