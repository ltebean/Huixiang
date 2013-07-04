//
//  HuixiangIAPHelper.m
//  Huixiang
//
//  Created by ltebean on 13-7-4.
//  Copyright (c) 2013年 ltebean. All rights reserved.
//

#import "HuixiangIAPHelper.h"


@implementation HuixiangIAPHelper

+ (HuixiangIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static HuixiangIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.my.huixiang.donate",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end