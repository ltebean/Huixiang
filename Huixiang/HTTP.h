//
//  HTTP.h
//  yueyue
//
//  Created by Yu Cong on 12-11-17.
//  Copyright (c) 2012年 Yu Cong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DOMAIN_URL @"http://huixiang.im/ajax"

@interface HTTP : NSObject

+(void)sendRequestToPath:(NSString*)url method:(NSString*)method params:(NSDictionary*)params cookies:(NSDictionary*)cookies  completionHandler:(void (^)(id)) completionHandler ;


+(void)postJsonToPath:(NSString*)url id:object cookies:(NSDictionary*)cookies  completionHandler:(void (^)(id)) completionHandler;

@end
