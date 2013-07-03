//
//  YCTableViewController.h
//  yueyue
//
//  Created by Yu Cong on 12-11-18.
//  Copyright (c) 2012年 Yu Cong. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YCTableViewController : UITableViewController
-(void)refresh;
-(void)loadMore;


- (void)didRefresh;
- (void)didLoadMore;
@end
