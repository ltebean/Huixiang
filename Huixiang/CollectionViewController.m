//
//  CollectionViewController.m
//  Huixiang
//
//  Created by ltebean on 13-7-3.
//  Copyright (c) 2013年 ltebean. All rights reserved.
//

#import "CollectionViewController.h"
#import "PieceCell.h"
#import "Settings.h"
#import "SVProgressHUD.h"
#import "HTTP.h"
#import "EGORefreshTableHeaderView.h"
#import "LoadingMoreFooterView.h"
#import "WeiboHTTP.h"
#import "UIHelper.h"

@interface CollectionViewController ()<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,UIScrollViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
@property(nonatomic,strong) NSMutableArray* pieces;
@property(nonatomic) int currentIndex;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic)BOOL loaded;
@property(nonatomic)int page;

@property (nonatomic,weak)EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic,strong)LoadingMoreFooterView *loadFooterView;
@property(nonatomic) BOOL reloading;
@property(nonatomic) BOOL loadingmore;
@end

@implementation CollectionViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if(self){
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"收藏" image:nil tag:0];
        [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"favorites.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"favorites.png"]];
        [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f], UITextAttributeTextColor,
                                                   nil] forState:UIControlStateNormal];
    }
    return self;
}

- (void)viewDidLoad
{
    self.loaded=NO;
    [super viewDidLoad];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
	// Do any additional setup after loading the view.
    self.page=1;
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    NSDictionary* user=[Settings getUser];
    if(!user){
        [self showAuthConfirm];
        return;
    }
    
    if(!self.loaded){
        [self refresh];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1){
        [self goToAuth];
    }
}

-(void)goToAuth
{
    [self performSegueWithIdentifier:@"auth" sender:nil];
}

-(void)showAuthConfirm
{
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:nil message:@"需要登录才能收藏哦" delegate:self cancelButtonTitle:nil otherButtonTitles:@"不了",@"通过微博登录",nil];
    [alert show];
}

-(void)refresh
{
    NSDictionary* user=[Settings getUser];
    if(!user){
        [self showAuthConfirm];
        return;
    }
    self.page=1;
    [SVProgressHUD showWithStatus:@"加载中"];
    [HTTP sendRequestToPath:@"/mine/favs" method:@"GET" params:nil cookies:@{@"cu":user[@"client_hash"]}  completionHandler:^(NSArray* data) {
        if(data && data.count>0){
            self.pieces=[data mutableCopy];
            self.loaded=YES;
            self.page++;
            
            [SVProgressHUD dismiss];
            [self.tableView reloadData];
        }else{
            [SVProgressHUD showErrorWithStatus:@"还没有收藏过任何句子"];
        }
   
    }];
}

-(void)loadMore
{
    NSDictionary* user=[Settings getUser];
    if(!user){
        [self showAuthConfirm];
        return;
    }
    [HTTP sendRequestToPath:@"/mine/favs" method:@"GET" params:@{@"page":[NSString stringWithFormat:@"%d",self.page]} cookies:@{@"cu":user[@"client_hash"]}  completionHandler:^(NSArray* data) {
        if(data && data.count>0){
            [self.pieces addObjectsFromArray:data];
            [self.tableView reloadData];
            self.page++;
            
        }else{
            [SVProgressHUD showErrorWithStatus:@"没有更多咯"];
        }
        [self didLoadMore];
    }];
}

#pragma mark UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pieces.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PieceCell";
    PieceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell=[[PieceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.piece=[self.pieces objectAtIndex:indexPath.row];
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentIndex=indexPath.row;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:@"从收藏中删除"
                                              otherButtonTitles:@"分享到微博",nil];
    
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:[self.view window]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0){
        [self deletePiece];
    }else if(buttonIndex==1){
        [self shareToWeibo];
    }
}

-(void)deletePiece
{
    [SVProgressHUD showWithStatus:@"删除"];
    NSDictionary* user=[Settings getUser];
    [HTTP sendRequestToPath:@"/unfav" method:@"POST" params:@{@"pieceid":self.pieces[self.currentIndex][@"id"]} cookies:@{@"cu":user[@"client_hash"]}  completionHandler:^(NSArray* data) {
        [self.pieces removeObjectAtIndex:self.currentIndex];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [SVProgressHUD dismiss];
    }];
}

-(void)shareToWeibo
{
    NSDictionary* user=[Settings getUser];
    if(!user){
        [self performSegueWithIdentifier:@"auth" sender:nil];
        return;
    }
    [SVProgressHUD showWithStatus:@"分享"];
    NSString* content=self.pieces[self.currentIndex][@"content"];
    [WeiboHTTP sendRequestToPath:@"/statuses/update.json" method:@"POST" params:@{@"access_token":user[@"weibo_access_token"],@"status":content} completionHandler:^(id data) {
        [SVProgressHUD showSuccessWithStatus:@"成功"];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath  *)indexPath
{
    NSString* content=self.pieces[indexPath.row][@"content"];
    return [UIHelper measureTextHeight:content UIFont:[UIFont fontWithName:LABEL_FONT_NAME size:LABEL_FONT_SIZE] constrainedToSize:LABEL_SIZE].height+58;
}

#pragma mark UITableViewDelegate
- (void)didLoadMore
{
    if(self.loadingmore)
    {
        self.loadingmore = NO;
        self.loadFooterView.showActivityIndicator = NO;
    }
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource
{
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    _reloading=YES;
    [self refresh];
}

- (void)didRefresh
{
    _reloading=NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	
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

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self reloadTableViewDataSource];
    self.reloading=YES;
	[self performSelector:@selector(didRefresh) withObject:nil afterDelay:1.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return self.reloading; // should return if data source model is reloadi
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last change
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
