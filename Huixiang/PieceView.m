//
//  PieceView.m
//  Huixiang
//
//  Created by ltebean on 13-7-2.
//  Copyright (c) 2013年 ltebean. All rights reserved.
//

#import "PieceView.h"
#import <QuartzCore/CoreAnimation.h>
#import "UIHelper.h"

@interface PieceView()
@property (weak, nonatomic) IBOutlet UILabel *label;
@end
@implementation PieceView

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.label.layer.shadowColor = [UIColor grayColor].CGColor;
    self.label.layer.shadowOpacity = 0.5;
    self.label.layer.shadowRadius = 5.0;
    self.label.layer.shadowOffset = CGSizeMake(0, 0);
    self.label.clipsToBounds = NO;
    self.label.font=[UIFont fontWithName:@"HiraginoSansGB-W3" size:19];
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handle:)];
    [self addGestureRecognizer:recognizer];
}

-(void)handle:(UIPanGestureRecognizer *)recognizer {
    CGPoint velocity = [recognizer velocityInView:self];

    if([recognizer state] == UIGestureRecognizerStateEnded && velocity.x > 0) {
        [self.delegate didSwipe];
    }
}


-(void)setPiece:(NSDictionary *)piece
{
    _piece=piece;
    [self updateUI];
}


-(void)updateUI
{
    CGSize size=[UIHelper measureTextHeight:self.piece[@"content"] UIFont:self.label.font constrainedToSize:CGSizeMake(250, 400)];
    self.label.bounds=CGRectMake(self.label.bounds.origin.x,self.label.bounds.origin.y, size.width+50, size.height+30);
    self.label.text=self.piece[@"content"];
    self.label.textAlignment = UITextAlignmentLeft;
}


@end
