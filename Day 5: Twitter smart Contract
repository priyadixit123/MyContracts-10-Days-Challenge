// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedTwitter {
struct Tweet {
uint256 id;
address author;
string content;
string media;
uint256 timestamp;
uint256 likes;
uint256 retweets;
uint256[] comments;
}

struct Comment {
uint256 id;
uint256 tweetId;
address author;
string content;
uint256 timestamp;
}

struct UserProfile {
string username;
string bio;
string profilePic;
}

uint256 private tweetCount;
uint256 private commentCount;
mapping(uint256 => Tweet) public tweets;
mapping(uint256 => Comment) public comments;
mapping(uint256 => mapping(address => bool)) public likedTweets;
mapping(uint256 => mapping(address => bool)) public retweetedTweets;
mapping(address => uint256[]) public userTweets;
mapping(address => UserProfile) public userProfiles;
mapping(address => mapping(address => bool)) public followers;

event TweetCreated(uint256 indexed id, address indexed author, string content, string media, uint256 timestamp);
event TweetLiked(uint256 indexed id, address indexed user);
event TweetRetweeted(uint256 indexed id, address indexed user, string quoteContent, uint256 newTweetId);
event CommentCreated(uint256 indexed id, uint256 indexed tweetId, address indexed author, string content, uint256 timestamp);
event TweetDeleted(uint256 indexed id, address indexed author);
event ProfileUpdated(address indexed user, string username, string bio, string profilePic);
event UserFollowed(address indexed follower, address indexed followee);
event UserUnfollowed(address indexed follower, address indexed followee);

function postTweet(string memory _content, string memory _media) external {
tweetCount++;
Tweet storage tweet = tweets[tweetCount];
tweet.id = tweetCount;
tweet.author = msg.sender;
tweet.content = _content;
tweet.media = _media;
tweet.timestamp = block.timestamp;
userTweets[msg.sender].push(tweetCount);
emit TweetCreated(tweetCount, msg.sender, _content, _media, block.timestamp);
}

function likeTweet(uint256 _tweetId) external {
require(_tweetId > 0 && _tweetId <= tweetCount, “Tweet does not exist”);
require(!likedTweets[_tweetId][msg.sender], “Tweet already liked”);

likedTweets[_tweetId][msg.sender] = true;
tweets[_tweetId].likes++;
emit TweetLiked(_tweetId, msg.sender);
}

function retweet(uint256 _tweetId, string memory _quoteContent) external {
require(_tweetId > 0 && _tweetId <= tweetCount, “Tweet does not exist”);
require(!retweetedTweets[_tweetId][msg.sender], “Tweet already retweeted”);

retweetedTweets[_tweetId][msg.sender] = true;
tweets[_tweetId].retweets++;

tweetCount++;
Tweet storage newTweet = tweets[tweetCount];
newTweet.id = tweetCount;
newTweet.author = msg.sender;
newTweet.content = _quoteContent;
newTweet.timestamp = block.timestamp;
userTweets[msg.sender].push(tweetCount);
emit TweetCreated(tweetCount, msg.sender, _quoteContent, “”, block.timestamp);

emit TweetRetweeted(_tweetId, msg.sender, _quoteContent, tweetCount);
}

function commentOnTweet(uint256 _tweetId, string memory _content) external {
require(_tweetId > 0 && _tweetId <= tweetCount, “Tweet does not exist”);

commentCount++;
Comment storage newComment = comments[commentCount];
newComment.id = commentCount;
newComment.tweetId = _tweetId;
newComment.author = msg.sender;
newComment.content = _content;
newComment.timestamp = block.timestamp;
tweets[_tweetId].comments.push(commentCount);
emit CommentCreated(commentCount, _tweetId, msg.sender, _content, block.timestamp);
}

function deleteTweet(uint256 _tweetId) external {
require(_tweetId > 0 && _tweetId <= tweetCount, “Tweet does not exist”);
require(tweets[_tweetId].author == msg.sender, “You can only delete your own tweets”);

delete tweets[_tweetId];
emit TweetDeleted(_tweetId, msg.sender);
}

function getTweet(uint256 _tweetId) external view returns (Tweet memory) {
require(_tweetId > 0 && _tweetId <= tweetCount, “Tweet does not exist”);
return tweets[_tweetId];
}

function getUserTweets(address _user) external view returns (uint256[] memory) {
return userTweets[_user];
}

function getTweetComments(uint256 _tweetId) external view returns (Comment[] memory) {
require(_tweetId > 0 && _tweetId <= tweetCount, “Tweet does not exist”);

uint256[] memory commentIds = tweets[_tweetId].comments;
Comment[] memory tweetComments = new Comment[](commentIds.length);
for (uint256 i = 0; i < commentIds.length; i++) {
tweetComments[i] = comments[commentIds[i]];
}

return tweetComments;
}

function updateUserProfile(string memory _username, string memory _bio, string memory _profilePic) external {
UserProfile storage profile = userProfiles[msg.sender];
profile.username = _username;
profile.bio = _bio;
profile.profilePic = _profilePic;
emit ProfileUpdated(msg.sender, _username, _bio, _profilePic);
}

function followUser(address _user) external {
require(_user != msg.sender, “You cannot follow yourself”);
require(!followers[msg.sender][_user], “Already following this user”);

followers[msg.sender][_user] = true;
emit UserFollowed(msg.sender, _user);
}

function unfollowUser(address _user) external {
require(followers[msg.sender][_user], “Not following this user”);

followers[msg.sender][_user] = false;
emit UserUnfollowed(msg.sender, _user);
}

function isFollowing(address _follower, address _followee) external view returns (bool) {
return followers[_follower][_followee];
}
}
