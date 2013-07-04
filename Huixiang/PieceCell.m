//
//  PieceCell.m
//  Huixiang
//
//  Created by ltebean on 13-7-3.
//  Copyright (c) 2013年 ltebean. All rights reserved.
//

#import "PieceCell.h"
#import <QuartzCore/CoreAnimation.h>

@interface PieceCell()
@property (weak, nonatomic) IBOutlet UILabel *label;
@end


@implementation PieceCell

-(void)setPiece:(NSDictionary *)piece
{
    _piece=piece;
    [self updateUI];
}

-(void)updateUI
{
    CGSize size=[self measureTextHeight:self.piece[@"content"] fontSize:18 constrainedToSize:CGSizeMake(290, 500)];
    self.label.bounds=CGRectMake(self.label.bounds.origin.x,self.label.bounds.origin.y, 296, size.height+44);
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
