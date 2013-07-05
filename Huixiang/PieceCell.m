//
//  PieceCell.m
//  Huixiang
//
//  Created by ltebean on 13-7-3.
//  Copyright (c) 2013年 ltebean. All rights reserved.
//

#import "PieceCell.h"
#import <QuartzCore/CoreAnimation.h>
#import "UIHelper.h"

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
    CGSize size=[UIHelper measureTextHeight:self.piece[@"content"] UIFont:self.label.font constrainedToSize:LABEL_SIZE];
    
    self.label.bounds=CGRectMake(self.label.bounds.origin.x,self.label.bounds.origin.y, 296, size.height+44);
    self.label.text=self.piece[@"content"];
    
    self.label.layer.shadowColor = [UIColor grayColor].CGColor;
    self.label.layer.shadowOpacity = 0.7;
    self.label.layer.shadowRadius = 1.0;
    self.label.layer.shadowOffset = CGSizeMake(3, 3);
    self.label.clipsToBounds = NO;

}

@end
