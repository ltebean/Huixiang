//
//  Settings.m
//  yueyue
//
//  Created by Yu Cong on 12-11-21.
//  Copyright (c) 2012年 Yu Cong. All rights reserved.
//

#import "Settings.h"
#import "HTTP.h"

@implementation Settings

+(NSDictionary*) getUser
{
    NSDictionary* user= [[NSUserDefaults standardUserDefaults]objectForKey:@"user"];
    return user;
}

+(void)saveUser:(NSDictionary*)user
{
    [[NSUserDefaults standardUserDefaults]setObject:user forKey:@"user"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
