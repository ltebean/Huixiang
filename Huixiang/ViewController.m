//
//  ViewController.m
//  Huixiang
//
//  Created by ltebean on 13-6-13.
//  Copyright (c) 2013年 ltebean. All rights reserved.
//

#import "ViewController.h"
#import "HTTP.h"
#import "PieceView.h"
#import "iCarousel.h"
#import "HMSideMenu.h"
#import "Settings.h"
#import "SVProgressHUD.h"
#import "WeiboHTTP.h"
#import <QuartzCore/QuartzCore.h>
#import "WXApi.h"
#import "UIView+Genie.h"

#define NUMBER_OF_VISIBLE_ITEMS 1
#define ITEM_SPACING 130.0f
#define INCLUDE_PLACEHOLDERS NO

typedef enum
{
    alertViewTypeWeiboShareConfirm = 10,
    alertViewTypeAuthConfirm,
    alertViewTypeShareInput
}
alertViewType;

@interface ViewController ()<iCarouselDataSource, iCarouselDelegate,UIAlertViewDelegate,PieceViewDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property(nonatomic,strong) NSMutableArray* pieces;
@property (nonatomic, strong) HMSideMenu *sideMenu;
@property int count;
@property BOOL loaded;
@end

@implementation ViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if(self){
        [super viewDidLoad];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"看看" image:nil tag:0];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"leaf.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"leaf.png"]];
        [self.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f], UITextAttributeTextColor,
                                                   nil] forState:UIControlStateNormal];
        [self.tabBarController setSelectedIndex:0];

    }
    return self;
}

-(void)initSideView
{
    //favItem
    UIView *favItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [favItem setMenuActionWithBlock:^{
        if(![Settings getUser]){
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:nil message:@"需要登录才能收藏哦" delegate:self cancelButtonTitle:nil otherButtonTitles:@"不了",@"通过微博登录",nil];
            alert.tag=alertViewTypeAuthConfirm;
            [alert show];
        }else{
            [self addToFav];
        }
    }];
    UIImageView *favIcon = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 27, 27)];
    [favIcon setImage:[UIImage imageNamed:@"fav"]];
    [favItem addSubview:favIcon];
    
    //weiboItem
    UIView *weiboItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [weiboItem setMenuActionWithBlock:^{
        if(![Settings getUser]){
            [self performSegueWithIdentifier:@"auth" sender:nil];
            return;
        }else{
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:nil message:@"转发到微博" delegate:self cancelButtonTitle:nil otherButtonTitles:@"取消",@"好的",nil];
            alert.tag=alertViewTypeWeiboShareConfirm;
            [alert show];
        }
    }];
    UIImageView *weiboIcon = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 38, 38)];
    [weiboIcon setImage:[UIImage imageNamed:@"weibo"]];
    [weiboItem addSubview:weiboIcon];
    
    //weiboItem
    UIView *weixinItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [weixinItem setMenuActionWithBlock:^{
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"分享给微信好友",@"分享到微信朋友圈",nil];
        
        sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [sheet showInView:[self.view window]];
    }];
    UIImageView *weixinIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 40, 40)];
    [weixinIcon setImage:[UIImage imageNamed:@"weixin"]];
    [weixinItem addSubview:weixinIcon];

    
    self.sideMenu = [[HMSideMenu alloc] initWithItems:@[favItem,weiboItem,weixinItem]];
    self.sideMenu.menuPosition=HMSideMenuPositionTop;
    [self.sideMenu setItemSpacing:20.0f];
    [self.view addSubview:self.sideMenu];

}

- (void)viewDidLoad
{
   
    [self initSideView];

    self.carousel.dataSource=self;
    self.carousel.delegate=self;
    self.carousel.type = iCarouselTypeTimeMachine;
    self.carousel.scrollEnabled=NO;
    self.count=0;
    self.loaded=NO;
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent=NO;
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar-bg@2x.png"] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    

  
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if(!self.loaded){
        [SVProgressHUD showWithStatus:@"加载中"];
        [self refreshData];
    }
}


-(void)refreshData
{
    [HTTP sendRequestToPath:@"/pieces" method:@"GET" params:nil cookies:nil completionHandler:^(id data) {
        if(!data){
            [SVProgressHUD showErrorWithStatus:@"网络连接出错啦"];
            return;
        }
        self.pieces=data;
        self.loaded=YES;
        [SVProgressHUD dismiss];
        [self.carousel reloadData];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==alertViewTypeWeiboShareConfirm){
        if(buttonIndex==1){
            [self shareToWeibo];
        }
    }else if(alertView.tag==alertViewTypeAuthConfirm){
        if(buttonIndex==1){
            [self performSegueWithIdentifier:@"auth" sender:nil];
        }
    }else if(alertView.tag==alertViewTypeShareInput){
        if(buttonIndex==1){
            UITextField *commentField = [alertView textFieldAtIndex:0];
            if(commentField.text.length==0){
                [self showInput];
            }else{
                [self sharePiece:commentField.text];
            }
        }
    }
}

-(void)sharePiece:(NSString*) content
{
    NSDictionary* user=[Settings getUser];
    [SVProgressHUD showWithStatus:@"发送"];
    [HTTP sendRequestToPath:@"/add" method:@"POST" params:@{@"content":content,@"share":@""} cookies:@{@"cu":user[@"client_hash"]} completionHandler:^(id data) {
        if(data){
            [SVProgressHUD showSuccessWithStatus:@"成功"];

        }else{
            [SVProgressHUD showErrorWithStatus:@"失败"];
        }
    }];
}

-(void)addToFav
{
    NSDictionary* user=[Settings getUser];
    if(!user){
        [self performSegueWithIdentifier:@"auth" sender:nil];
        return;
    }
    
    NSDictionary* piece=self.pieces[self.carousel.currentItemIndex];
    //animation
    NSData *tempArchive = [NSKeyedArchiver archivedDataWithRootObject:self.carousel];
    UIView *tempView=[NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
    for(UIView* view in tempView.subviews){
        if([view isKindOfClass:[HMSideMenu class]]){
            [view removeFromSuperview];
            break;
        }
    }
    [self.view addSubview:tempView];
    CGRect endRect = CGRectMake(150, self.view.frame.size.height, 20, 20);
    [tempView genieInTransitionWithDuration:0.7
                            destinationRect:endRect
                            destinationEdge:BCRectEdgeTop
                                 completion:^{
                                     [tempView removeFromSuperview];                                     
                                 }];
    
    [HTTP sendRequestToPath:@"/fav" method:@"POST" params:@{@"pieceid":piece[@"id"]} cookies:@{@"cu":user[@"client_hash"]} completionHandler:^(id data) {
        if(data){
            [SVProgressHUD showSuccessWithStatus:@"已收藏"];
        }else{
            [SVProgressHUD showErrorWithStatus:@"失败"];
        }
    }];
}

-(void)shareToWeibo
{
    NSDictionary* user=[Settings getUser];
    if(!user){
        [self performSegueWithIdentifier:@"auth" sender:nil];
        return;
    }
    NSDictionary* piece=self.pieces[self.carousel.currentItemIndex];

    [SVProgressHUD showWithStatus:@"分享"];
    NSString* content=[NSString stringWithFormat:@"「%@」-摘自#茴香# http://huixiang.im/piece/%@",piece[@"content"],piece[@"id"]];

    [WeiboHTTP sendRequestToPath:@"/statuses/update.json" method:@"POST" params:@{@"access_token":user[@"weibo_access_token"],@"status":content} completionHandler:^(id data) {
        if(!data){
            [SVProgressHUD showErrorWithStatus:@"网络连接出错啦"];
            return;
        }
        if([data[@"error_code"] isEqualToNumber:[NSNumber numberWithInt:21327]]||[data[@"error_code"] isEqualToNumber:[NSNumber numberWithInt:21332]]){
            [SVProgressHUD showErrorWithStatus:@"授权过期，请重新授权"];
        }else{
            [SVProgressHUD showSuccessWithStatus:@"成功"];
        }
    }];
}

- (IBAction)share:(id)sender {
    if(![Settings getUser]){
        [self performSegueWithIdentifier:@"auth" sender:nil];
        return;
    }
    [self showInput];
}

-(void)showInput
{
    UIAlertView* alertView=[[UIAlertView alloc]initWithTitle:@"记一句:" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送",nil];
    alertView.alertViewStyle=UIAlertViewStylePlainTextInput;
    alertView.tag=alertViewTypeShareInput;
    [alertView show];

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0){
        [self shareToWeixinIsTimeLine:NO];
    }else if(buttonIndex==1){
        [self shareToWeixinIsTimeLine:YES];
    }
}

-(void)shareToWeixinIsTimeLine: (BOOL)isTimeLine
{
    if(![WXApi isWXAppInstalled]){
        [SVProgressHUD showErrorWithStatus:@"还没有安装微信"];
        return;
    }
    
    NSDictionary *piece=self.pieces[self.carousel.currentItemIndex];
    NSString* content=[NSString stringWithFormat:@"「%@」-摘自茴香 http://huixiang.im/piece/%@",piece[@"content"],piece[@"id"]];    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText=YES;
    req.text = content;
    if(isTimeLine){
        req.scene=WXSceneTimeline;
    }
    [WXApi sendReq:req];
}


#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.pieces.count;
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    //this also affects the appearance of circular-type carousels
    return NUMBER_OF_VISIBLE_ITEMS;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
	//create new view if no view is available for recycling
	if (view == nil)
	{
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"PieceView"
                                                          owner:self
                                                        options:nil];
        view=[nibViews lastObject];        
    }
    
    ((PieceView*)view).piece=self.pieces[index];
    ((PieceView*)view).delegate=self;

  	return view;
    
}

-(void)didSwipe
{
    if(self.sideMenu.isOpen){
        [self.sideMenu close];
    }
    self.count++;
    if(self.count==self.pieces.count){
        self.count=0;
        [self refreshData];
    }
    [self.carousel scrollByNumberOfItems:-1 duration:0.5];
    
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel;
{
    
}

-(void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    if (!self.sideMenu.isOpen){
        [self.sideMenu open];
    }else{
        [self.sideMenu close];
    }
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //usually this should be slightly wider than the item views
    return ITEM_SPACING;
}

- (CGFloat)carousel:(iCarousel *)carousel itemAlphaForOffset:(CGFloat)offset
{
	//set opacity based on distance from camera
    return 1.0f - fminf(fmaxf(offset, 0.0f), 1.0f);
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * self.carousel.itemWidth);
}


- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    return YES;
}



-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
}



@end
