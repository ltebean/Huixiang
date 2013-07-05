//
//  PieceView.m
//  Huixiang
//
//  Created by ltebean on 13-7-2.
//  Copyright (c) 2013年 ltebean. All rights reserved.
//

#import "PieceView.h"
#import <QuartzCore/CoreAnimation.h>
@interface PieceView()
@property (weak, nonatomic) IBOutlet UILabel *label;
@end
@implementation PieceView



-(void)setPiece:(NSDictionary *)piece
{
    _piece=piece;
    [self updateUI];

}

-(void)updateUI
{
    CGSize size=[self measureTextHeight:self.piece[@"content"] fontSize:19 constrainedToSize:CGSizeMake(250, 350)];
    self.label.bounds=CGRectMake(self.label.bounds.origin.x,self.label.bounds.origin.y, size.width+50, size.height+30);
    self.label.text=self.piece[@"content"];
    
    self.label.layer.shadowColor = [UIColor grayColor].CGColor;
    self.label.layer.shadowOpacity = 0.7;
    self.label.layer.shadowRadius = 1.0;
    self.label.layer.shadowOffset = CGSizeMake(3, 3);
    self.label.clipsToBounds = NO;
}

-(CGSize)measureTextHeight:(NSString*)text fontSize:(CGFloat)fontSize constrainedToSize:(CGSize)constrainedToSize
{
    CGSize mTempSize = [text sizeWithFont:[UIFont fontWithName:@"Hiragino Kaku Gothic ProN" size:fontSize] constrainedToSize:constrainedToSize lineBreakMode:UILineBreakModeWordWrap];
    return mTempSize;
}

@end
