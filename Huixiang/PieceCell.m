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
@property BOOL inited;
@end


@implementation PieceCell


-(void)setPiece:(NSDictionary *)piece
{
    _piece=piece;
    [self updateUI];
    if(!self.inited){
        self.label.layer.shadowColor = [UIColor grayColor].CGColor;
        self.label.layer.shadowOpacity = 0.7;
        self.label.layer.shadowRadius = 2.0;
        self.label.layer.shadowOffset = CGSizeMake(0, 1);
        self.label.clipsToBounds = NO;
        self.inited=YES;
    }
    

}

-(void)updateUI
{

    
    CGSize size=[UIHelper measureTextHeight:self.piece[@"content"] UIFont:self.label.font constrainedToSize:LABEL_SIZE];
    
    self.label.bounds=CGRectMake(self.label.bounds.origin.x,self.label.bounds.origin.y, 296, size.height+36);
    self.label.text=self.piece[@"content"];
    self.label.layer.shadowPath=[UIBezierPath bezierPathWithRect:self.label.bounds].CGPath;

}

@end
