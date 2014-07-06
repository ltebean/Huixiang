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
#import "Seaport.h"
#import "SeaportHttp.h"
#import "SeaportWebViewBridge.h"

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
@property (nonatomic,strong) Seaport* seaport ;
@property(strong,nonatomic) SeaportWebViewBridge *bridge;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
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

       self.count=0;
    self.loaded=NO;
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent=NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar-bg@2x.png"] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    
    self.seaport = [Seaport sharedInstance];
    self.seaport.deletage=self;
    self.bridge = [SeaportWebViewBridge bridgeForWebView:self.webView param:@{@"city":@"shanghai",@"name": @"ltebean"} dataHandler:^(id data) {
        NSLog(@"receive data: %@",data);
        [self performSegueWithIdentifier:@"category" sender:data];
    }];
    self.webView.scrollView.showsVerticalScrollIndicator = NO;

  
}


-(void)viewWillAppear:(BOOL)animated

{
    [self refreshData];
}


-(void)refreshData
{
//    NSString *rootPath = [self.seaport packagePath:@"all"];
//    if(rootPath){
//        NSString *filePath = [rootPath stringByAppendingPathComponent:@"index.html"];
//        NSURL *localURL=[NSURL fileURLWithPath:filePath];
//        
//        NSURL *debugURL=[NSURL URLWithString:@"http://localhost:8080/index.html"];
//        
//        NSURLRequest *request=[NSURLRequest requestWithURL:debugURL];
//        [self.webView loadRequest:request];
//    }
    
    NSURL *debugURL=[NSURL URLWithString:@"http://localhost:8080/index.html"];
    
    NSURLRequest *request=[NSURLRequest requestWithURL:debugURL];
    [self.webView loadRequest:request];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==alertViewTypeWeiboShareConfirm){
        if(buttonIndex==1){
            //[self shareToWeibo];
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
    
    NSDictionary* piece=nil;
    //animation
    
    [HTTP sendRequestToPath:@"/fav" method:@"POST" params:@{@"pieceid":piece[@"id"]} cookies:@{@"cu":user[@"client_hash"]} completionHandler:^(id data) {
        if(data){
            [SVProgressHUD showSuccessWithStatus:@"已收藏"];
        }else{
            [SVProgressHUD showErrorWithStatus:@"失败"];
        }
    }];
}

//-(void)shareToWeibo
//{
//    NSDictionary* user=[Settings getUser];
//    if(!user){
//        [self performSegueWithIdentifier:@"auth" sender:nil];
//        return;
//    }
//    NSDictionary* piece=self.pieces[self.carousel.currentItemIndex];
//
//    [SVProgressHUD showWithStatus:@"分享"];
//    NSString* content=[NSString stringWithFormat:@"「%@」-摘自#茴香# http://huixiang.im/piece/%@",piece[@"content"],piece[@"id"]];
//
//    [WeiboHTTP sendRequestToPath:@"/statuses/update.json" method:@"POST" params:@{@"access_token":user[@"weibo_access_token"],@"status":content} completionHandler:^(id data) {
//        if(!data){
//            [SVProgressHUD showErrorWithStatus:@"网络连接出错啦"];
//            return;
//        }
//        if([data[@"error_code"] isEqualToNumber:[NSNumber numberWithInt:21327]]||[data[@"error_code"] isEqualToNumber:[NSNumber numberWithInt:21332]]){
//            [SVProgressHUD showErrorWithStatus:@"授权过期，请重新授权"];
//        }else{
//            [SVProgressHUD showSuccessWithStatus:@"成功"];
//        }
//    }];
//}

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
    
    NSDictionary *piece=nil;
    NSString* content=[NSString stringWithFormat:@"「%@」-摘自茴香 http://huixiang.im/piece/%@",piece[@"content"],piece[@"id"]];    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText=YES;
    req.text = content;
    if(isTimeLine){
        req.scene=WXSceneTimeline;
    }
    [WXApi sendReq:req];
}



@end
