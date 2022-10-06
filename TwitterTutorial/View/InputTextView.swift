//
//  CaptionTextView.swift
//  TwitterTutorial
//
//  Created by 조성규 on 2022/08/25.
//

import UIKit

class InputTextView: UITextView {
    
    // MARK: -Properties
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.text = "What's happening?"
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        font = UIFont.systemFont(ofSize: 16)
        isScrollEnabled = false
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        translatesAutoresizingMaskIntoConstraints = false
        textContainer?.maximumNumberOfLines = 0
        autocorrectionType = .no
        autocapitalizationType = .none
        
        
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: self.topAnchor, leading: self.leadingAnchor, paddingTop: 8, paddingLeading: 4)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleTextInputChange(){
        placeholderLabel.isHidden = !text.isEmpty
    }
}


