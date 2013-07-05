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
    
    self.label.layer.shadowColor = [UIColor grayColor].CGColor;
    self.label.layer.shadowOpacity = 0.7;
    self.label.layer.shadowRadius = 1.0;
    self.label.layer.shadowOffset = CGSizeMake(3, 3);
    self.label.clipsToBounds = NO;
}


@end
