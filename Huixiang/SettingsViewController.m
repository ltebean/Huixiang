//
//  SettingsViewController.m
//  cartoon
//
//  Created by  on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import "Settings.h"
#import "HuixiangIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "SVProgressHUD.h"

@interface SettingsViewController ()<MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *productLabel;
@property (weak, nonatomic) IBOutlet UILabel *weiboNameLabel;
@property(nonatomic,strong)SKProduct * product;
@end

@implementation SettingsViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setColor:[UIColor colorWithRed:60.0f/255.0f green:58.0f/255.0f blue:55.0f/255.0f alpha:1.0f]];

    self=[super initWithCoder:aDecoder];
    if(self){
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"设置" image:nil tag:0];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"settings.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"settings.png"]];
        [self.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f], UITextAttributeTextColor,
                                                   nil] forState:UIControlStateNormal];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    if([Settings getUser]){
        self.weiboNameLabel.text=[Settings getUser][@"name"];
    }
}

- (IBAction)buy:(id)sender {
    [SVProgressHUD showWithStatus:@"加载信息"];
    [[HuixiangIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            self.product = (SKProduct *) products[0];
            [[HuixiangIAPHelper sharedInstance] buyProduct:self.product];
        }
        [SVProgressHUD dismiss];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];

}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [SVProgressHUD showSuccessWithStatus:@"捐赠成功"];
    
}



- (IBAction)changeAccount:(id)sender {
    [self performSegueWithIdentifier:@"auth" sender:self];

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1&&indexPath.row==0){
        [self sendMail];
    }else if(indexPath.section==1&&indexPath.row==1){
        [self goToRating];
    }else if(indexPath.section==2&&indexPath.row==0){
        NSString *url = @"http://huixiang.im";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

-(void)goToRating
{
    NSString *REVIEW_URL = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=669860898&onlyLatestVersion=true&type=Purple+Software";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:REVIEW_URL]];
}


-(void)sendMail
{
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.navigationBar.tintColor=[UIColor blackColor];
        picker.mailComposeDelegate = self;
        [picker setSubject:@"茴香反馈意见"];
        [picker setToRecipients:[NSArray arrayWithObjects:@"yucong1118@gmail.com", nil]];
        [self presentModalViewController:picker animated:YES];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"您还没有设置邮件帐号" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
    // Notifies users about errors associated with the interface
    NSString* message=nil;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            message=@"已存储草稿";
            break;
        case MFMailComposeResultSent:
            message=@"邮件已添加至发送队列";
            break;
        case MFMailComposeResultFailed:
            message=@"发送失败";
            break;
        default:
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
    if(message){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:message message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        [alert show];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [self setWeiboNameLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
