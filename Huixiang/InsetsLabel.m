//
//  InsetsLabel.m
//  Huixiang
//
//  Created by ltebean on 13-7-4.
//  Copyright (c) 2013年 ltebean. All rights reserved.
//

#import "InsetsLabel.h"

@implementation InsetsLabel
- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {10, 20, 0, 20};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
@end
