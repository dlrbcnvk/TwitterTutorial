//
//  TweetCell.swift
//  TwitterTutorial
//
//  Created by 조성규 on 2022/08/25.
//

import UIKit
import ActiveLabel

protocol TweetCellDelegate: AnyObject {
    func handleProfileImageTapped(_ cell: TweetCell)
    func handleReplyTapped(_ cell: TweetCell)
    func handleLikeTapped(_ cell: TweetCell)
}

class TweetCell: UICollectionViewCell {

    // MARK: - Properties
    
    var tweet: Tweet? {
        didSet { configure() }
    }
    
    weak var delegate: TweetCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.setDimensions(width: 48, height: 48)
        iv.layer.cornerRadius = 48 / 2
        iv.backgroundColor = .twitterBlue
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        
        return iv
    }()
    
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.mentionColor = .twitterBlue
        label.hashtagColor = .twitterBlue
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var retweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "retweet"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(handleRetweetTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "like"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "share"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
        return button
    }()
    
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.mentionColor = .twitterBlue
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let captionStack = UIStackView(arrangedSubviews: [infoLabel, captionLabel])
        captionStack.axis = .vertical
        captionStack.distribution = .fillProportionally
        captionStack.spacing = 4
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, captionStack])
        imageCaptionStack.distribution = .fillProportionally
        imageCaptionStack.spacing = 12
        imageCaptionStack.alignment = .leading
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        
        contentView.addSubview(stack)
        stack.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, paddingTop: 4, paddingLeading: 12, paddingTrailing: 12)
        
        
        
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        
        let actionStack = UIStackView(arrangedSubviews: [commentButton, retweetButton, likeButton, shareButton])
        actionStack.axis = .horizontal
        actionStack.spacing = 72
        contentView.addSubview(actionStack)
        actionStack.centerX(inView: self)
        actionStack.anchor(bottom: bottomAnchor, paddingBottom: 8)
        
        let underlineView = UIView()
        underlineView.backgroundColor = .systemGroupedBackground
        contentView.addSubview(underlineView)
        underlineView.anchor(leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, height: 1)
        
        configureMentionHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Selectors
    
    @objc func handleCommentTapped(){
        delegate?.handleReplyTapped(self)
    }
    
    @objc func handleRetweetTapped(){
        print("DEBUG: \(#function)")
    }
    
    @objc func handleLikeTapped(){
        delegate?.handleLikeTapped(self)
    }
    
    @objc func handleShareTapped(){
        print("DEBUG: \(#function)")
    }
    
    @objc func handleProfileImageTapped(){
        print("DEBUG: \(#function)")
        delegate?.handleProfileImageTapped(self)
    }
    
//    deinit {
//        self.delegate = nil
//    }
    // MARK: - Helpers
    
    func configure(){
        guard let tweet = tweet else { return }
        let viewModel = TweetViewModel(tweet: tweet)
        
        captionLabel.text = tweet.caption
        
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        infoLabel.attributedText = viewModel.userInfoText
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        
        replyLabel.text = viewModel.replyText
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
    }
    
    func configureMentionHandler(){
        captionLabel.handleMentionTap { mention in
            print("DEBUG: Go to user profile for \(mention)")
        }
    }
    
}
