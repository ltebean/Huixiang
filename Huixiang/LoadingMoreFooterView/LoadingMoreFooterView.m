//
//  LoadingMoreFooterView.m
//   Ptt
//
//  Created by Xingzhi Cheng on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoadingMoreFooterView.h"

#define TEXT_COLOR [UIColor blackColor]

@interface LoadingMoreFooterView()
@property(nonatomic, retain) UILabel * textLabel;
@property(nonatomic, retain) UIActivityIndicatorView * activityView;
@property(nonatomic, readwrite) CGRect savedFrame;
@end

@implementation LoadingMoreFooterView
@synthesize textLabel = _textLabel;
@synthesize activityView = _activityView;
@synthesize showActivityIndicator = _showActivityIndicator;
@synthesize refreshing = _refreshing;
@synthesize enabled = _enabled;
@synthesize savedFrame = _savedFrame;


- (void) dealloc {
    self.textLabel = nil;
    self.activityView = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showActivityIndicator = NO;
        self.enabled = YES;
        self.refreshing = NO;
        
        self.textLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)] autorelease];
        self.textLabel.textAlignment = UITextAlignmentCenter;
        self.textLabel.text =  @"上拉加载更多...";
        self.textLabel.textColor = TEXT_COLOR;
        self.textLabel.font=[UIFont systemFontOfSize:15];
        [self addSubview:self.textLabel];
        
        self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    self.savedFrame = frame;
    [super setFrame:frame];
}

- (void) setTextAlignment:(UITextAlignment)textAlignment {
    self.textLabel.textAlignment = textAlignment;
}

- (UITextAlignment) textAlignment {
    return self.textAlignment;
}

- (void) setShowActivityIndicator:(BOOL)showActivityIndicator {
    _showActivityIndicator = showActivityIndicator;
    if (showActivityIndicator && !self.activityView) {
        self.activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        self.activityView.center = CGPointMake(self.frame.size.width-40, self.frame.size.height / 2);
        [self addSubview:self.activityView];
        [self.activityView startAnimating];
        self.textLabel.text =@"加载中...";
    }
    else if (!showActivityIndicator) {
        [self.activityView stopAnimating];
        [self.activityView removeFromSuperview];
        self.activityView = nil;
        self.textLabel.text = @"下拉加载更多";
    }
}

- (void) setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if (enabled) {
        [super setFrame:self.savedFrame];
        self.hidden = NO;
    }
    else {
        [super setFrame:CGRectZero];
        self.hidden = YES;
    }
}

@end
