//
//  XHAlbumRichTextView.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-5-19.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHAlbumRichTextView.h"

#import "XHMessageAvatorFactory.h"
#import "XHAlbumPhotoCollectionViewCell.h"
#import "XHAlbumCollectionViewFlowLayout.h"

#define kXHPhotoCollectionViewCellIdentifier @"XHPhotoCollectionViewCellIdentifier"

@interface XHAlbumRichTextView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIImageView *avatorImageView;
@property (nonatomic, strong) UILabel *userNameLabel;

@property (nonatomic, strong) UICollectionView *sharePhotoCollectionView;

@end

@implementation XHAlbumRichTextView

+ (CGFloat)getRichTextHeightWithText:(NSString *)text {
    if (!text || !text.length)
        return 0;
    return [SETextView frameRectWithAttributtedString:[[NSAttributedString alloc] initWithString:text] constraintSize:CGSizeMake(CGRectGetWidth([[UIScreen mainScreen] bounds]) - kXHAvatarImageSize - (kXHAlbumAvatorSpacing * 3), CGFLOAT_MAX) lineSpacing:kXHAlbumContentLineSpacing font:kXHAlbumContentFont].size.height;
}

+ (CGFloat)getSharePhotoCollectionViewHeightWithPhotos:(NSArray *)photos {
    NSInteger row = (photos.count / 3 + (photos.count % 3 ? 1 : 0));
    return (row * (kXHAlbumPhotoSize + kXHAlbumPhotoInsets));
}

+ (CGFloat)calculateRichTextHeightWithAlbum:(XHAlbum *)currentAlbum {
    CGFloat richTextHeight = kXHAlbumAvatorSpacing * 2;
    
    richTextHeight += kXHAlbumUserNameHeigth;
    
    richTextHeight += kXHAlbumContentLineSpacing;
    richTextHeight += [self getRichTextHeightWithText:currentAlbum.albumShareContent];
    
    richTextHeight += kXHAlbumPhotoInsets;
    richTextHeight += [self getSharePhotoCollectionViewHeightWithPhotos:currentAlbum.albumSharePhotos];
    
    return richTextHeight;
}

#pragma mark - Propertys

- (void)setDisplayAlbum:(XHAlbum *)displayAlbum {
    _displayAlbum = displayAlbum;
    
    self.userNameLabel.text = displayAlbum.userName;
    
    self.richTextView.attributedText = [[NSAttributedString alloc] initWithString:displayAlbum.albumShareContent];
    
    [self setNeedsLayout];
}

- (UIImageView *)avatorImageView {
    if (!_avatorImageView) {
        _avatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kXHAlbumAvatorSpacing, kXHAlbumAvatorSpacing, kXHAvatarImageSize, kXHAvatarImageSize)];
        _avatorImageView.image = [UIImage imageNamed:@"avator"];
    }
    return _avatorImageView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        CGFloat userNameLabelX = CGRectGetMaxX(self.avatorImageView.frame) + kXHAlbumAvatorSpacing;
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(userNameLabelX, CGRectGetMinY(self.avatorImageView.frame), CGRectGetWidth([[UIScreen mainScreen] bounds]) - userNameLabelX - kXHAlbumAvatorSpacing, kXHAlbumUserNameHeigth)];
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.textColor = [UIColor colorWithRed:0.294 green:0.595 blue:1.000 alpha:1.000];
    }
    return _userNameLabel;
}

- (SETextView *)richTextView {
    if (!_richTextView) {
        _richTextView = [[SETextView alloc] initWithFrame:self.bounds];
        _richTextView.backgroundColor = [UIColor clearColor];
        _richTextView.font = self.font;
        _richTextView.textColor = self.textColor;
        _richTextView.textAlignment = self.textAlignment;
        _richTextView.lineSpacing = self.lineSpacing;
    }
    return _richTextView;
}

- (UICollectionView *)sharePhotoCollectionView {
    if (!_sharePhotoCollectionView) {
        _sharePhotoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[XHAlbumCollectionViewFlowLayout alloc] init]];
        _sharePhotoCollectionView.backgroundColor = self.richTextView.backgroundColor;
        _sharePhotoCollectionView.delegate = self;
        _sharePhotoCollectionView.dataSource = self;
        [_sharePhotoCollectionView registerClass:[XHAlbumPhotoCollectionViewCell class] forCellWithReuseIdentifier:kXHPhotoCollectionViewCellIdentifier];
    }
    return _sharePhotoCollectionView;
}

#pragma mark - Life Cycle

- (void)setup {
    self.font = kXHAlbumContentFont;
    self.textColor = [UIColor blackColor];
    self.textAlignment = NSTextAlignmentLeft;
    self.lineSpacing = kXHAlbumContentLineSpacing;
    
    [self addSubview:self.avatorImageView];
    [self addSubview:self.userNameLabel];
    
    [self addSubview:self.richTextView];
    [self addSubview:self.sharePhotoCollectionView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat richTextViewX = CGRectGetMinX(self.userNameLabel.frame);
    CGRect richTextViewFrame = CGRectMake(richTextViewX, CGRectGetMaxY(self.userNameLabel.frame) + kXHAlbumContentLineSpacing, CGRectGetWidth([[UIScreen mainScreen] bounds]) - richTextViewX - kXHAlbumAvatorSpacing, [XHAlbumRichTextView getRichTextHeightWithText:self.displayAlbum.albumShareContent]);
    self.richTextView.frame = richTextViewFrame;
    
    CGRect sharePhotoCollectionViewFrame = CGRectMake(richTextViewX, CGRectGetMaxY(richTextViewFrame) + kXHAlbumPhotoInsets, kXHAlbumPhotoInsets * 4 + kXHAlbumPhotoSize * 3, [XHAlbumRichTextView getSharePhotoCollectionViewHeightWithPhotos:self.displayAlbum.albumSharePhotos]);
    self.sharePhotoCollectionView.frame = sharePhotoCollectionViewFrame;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.displayAlbum.albumSharePhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XHAlbumPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kXHPhotoCollectionViewCellIdentifier forIndexPath:indexPath];
    
    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
