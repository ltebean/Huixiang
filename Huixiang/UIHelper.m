//
//  UIHelper.m
//  Huixiang
//
//  Created by ltebean on 13-7-5.
//  Copyright (c) 2013年 ltebean. All rights reserved.
//

#import "UIHelper.h"

@implementation UIHelper
+(CGSize)measureTextHeight:(NSString*)text UIFont:font constrainedToSize:(CGSize)constrainedToSize
{
    CGSize mTempSize = [text sizeWithFont:font constrainedToSize:constrainedToSize lineBreakMode:UILineBreakModeWordWrap];
    return mTempSize;
}
@end
