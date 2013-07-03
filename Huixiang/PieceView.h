//
//  PieceView.h
//  Huixiang
//
//  Created by ltebean on 13-7-2.
//  Copyright (c) 2013年 ltebean. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PieceViewDelegate <NSObject>
-(void)didSelectPiece:(NSDictionary*)peice;
@end


@interface PieceView : UIView

@property(nonatomic,strong) NSDictionary* piece;
@property(nonatomic,weak) id<PieceViewDelegate> delegate;

@end
