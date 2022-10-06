//
//  FeedController.swift
//  TwitterTutorial
//
//  Created by 조성규 on 2022/08/22.
//

import UIKit
import SDWebImage

private let reuseIdentifier = "TweetCell"

class FeedController: UICollectionViewController {
    
    // MARK: - Properties
    
    var user: User? {
        didSet {
            configureLeftBarButton()
            configureRightBarButton()
        }
    }
    
    var cellCaptionHeight: CGFloat? = 14
    
    private var tweets = [Tweet]() {
        didSet { collectionView.reloadData() }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        fetchTweets()
        
        UserService.shared.fetchUser(withUsername: "fs") { user in
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
        
        print("DEBUG: \(#function)")
    }
    
    
    
    // MARK: - API
    
    func fetchTweets(){
        collectionView.refreshControl?.beginRefreshing()
        TweetService.shared.fetchTweets { tweets in
            self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
            self.checkIfUserLikedTweets( )
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func checkIfUserLikedTweets() {
        self.tweets.forEach { tweet in
            TweetService.shared.checkIfUSerLikedTweet(tweet) { didLike in
                guard didLike == true else { return }
                
                if let index = self.tweets.firstIndex(where: { $0.tweetID == tweet.tweetID}) {
                    self.tweets[index].didLike = true
                }
            }
        }
    }

    // MARK: - Helpers
    
    func makeUI() {
        view.backgroundColor = .white
        
        // 컬렉션뷰 등록⭐️
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.backgroundColor = .white

        // (네비게이션바 설정관련) iOS버전 업데이트 되면서 바뀐 설정⭐️⭐️⭐️
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()  // 불투명으로
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        navigationItem.titleView = imageView
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    func configureLeftBarButton(){
        guard let user = user else { return }
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
    
    func configureRightBarButton(){
        guard let user = user else { return }
        let logoutImageView = UIImageView(image: UIImage(systemName: "nosign"))
        logoutImageView.setDimensions(width: 32, height: 32)
        logoutImageView.layer.masksToBounds = true
        logoutImageView.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logoutImageView)
    }
    
    // MARK: - Selectors
    
    @objc func handleRefresh(){
        fetchTweets()
    }
}

// MARK: - UICollectionViewDelegate/Datasource

extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // print("DEBUG: Tweet count at time of collectionView function call is \(tweets.count)")
        // 이 함수를 처음 호출하는 시점에서 tweets는 비어있음. tweets 배열이 채워졌을 때 collectionView.reloadData 해야 함
        // tweet에 didSet 속성감시자 두고 여기에 reload 코드 넣는다.
        // fetchTweets에서 tweets 배열이 채워질 때 didSet이 호출되어 collectionView 데이터가 reload될 것이다.
        return tweets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? TweetCell else { return TweetCell() }
        
        cell.tweet = tweets[indexPath.row]
        
        cell.delegate = self
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // in my own refactor
        var tweetID = tweets[indexPath.row].tweetID
        TweetService.shared.checkIfUSerLikedTweet(tweets[indexPath.row]) { liked in
            TweetService.shared.fetchSingleTweet(tweetID) { tweet in
                var likeReflectedTweet = tweet
                likeReflectedTweet.didLike = liked
                
                let controller = TweetController(tweet: likeReflectedTweet)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.width - 68, ofSize: 14).height
        return CGSize(width: view.frame.width, height: height + 100)
    }
}

// MARK: -TweetCellDelegate

extension FeedController: TweetCellDelegate {
    func handleLikeTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        
        TweetService.shared.likeTweet(tweet: tweet) { error, ref in
            // 추가적인 네트워킹 하지 않고 ui 고치기
            cell.tweet?.didLike.toggle()
            let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
            cell.tweet?.likes = likes
        }
        
        // only upload notification if tweet is being liked
        guard !tweet.didLike else { return }
        NotificationService.shared.uploadNotification(type: .like, tweet: tweet)
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        let controller = UploadTweetController(user: tweet.user, config: .reply(tweet))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        guard let user = cell.tweet?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}
