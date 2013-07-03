//
//  YCTableViewController.m
//  yueyue
//
//  Created by Yu Cong on 12-11-18.
//  Copyright (c) 2012年 Yu Cong. All rights reserved.
//

#import "YCTableViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "LoadingMoreFooterView.h"

@interface YCTableViewController ()<EGORefreshTableHeaderDelegate,UIScrollViewDelegate>
@property (nonatomic,weak)EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic,strong)LoadingMoreFooterView *loadFooterView;
@property(nonatomic) BOOL reloading;
@property(nonatomic) BOOL loadingmore;


@end

@implementation YCTableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

    self.reloading=NO;
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    self.loadFooterView = [[LoadingMoreFooterView alloc]initWithFrame:CGRectMake(0, 0, 320, 44.f)];
    self.loadingmore = NO;
    self.tableView.tableFooterView= self.loadFooterView;
    
}




- (void)didLoadMore{
	
    if(self.loadingmore)
    {
        self.loadingmore = NO;
        self.loadFooterView.showActivityIndicator = NO;
    }
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    _reloading=YES;
    [self refresh];
}

- (void)didRefresh{
	
    _reloading=NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if (scrollView.contentOffset.y>0&&bottomEdge >= scrollView.contentSize.height)
    {
        if (self.loadingmore) return;
        
        self.loadingmore = YES;
        self.loadFooterView.showActivityIndicator = YES;
        
        [self loadMore];
        
        [self performSelector:@selector(didLoadMore) withObject:nil afterDelay:1.0];
    }
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
    self.reloading=YES;
	[self performSelector:@selector(didRefresh) withObject:nil afterDelay:1.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return self.reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


@end
