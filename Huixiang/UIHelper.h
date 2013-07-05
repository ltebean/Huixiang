//
//  UIHelper.h
//  Huixiang
//
//  Created by ltebean on 13-7-5.
//  Copyright (c) 2013年 ltebean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIHelper : NSObject
+(CGSize)measureTextHeight:(NSString*)text UIFont:font constrainedToSize:(CGSize)constrainedToSize;
@end
