//
//  Settings.h
//  yueyue
//
//  Created by Yu Cong on 12-11-21.
//  Copyright (c) 2012年 Yu Cong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

+(NSDictionary*) getUser;
+(void)saveUser:(NSDictionary*)user;

@end
