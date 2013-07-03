//
//  SinaWeiboAuthViewController.m
//  Memories
//
//  Created by  on 12-4-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SinaWeiboAuthViewController.h"
#import "SVProgressHUD.h"
#import "HTTP.h"
#import "Settings.h"

@interface SinaWeiboAuthViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation SinaWeiboAuthViewController
@synthesize webView=_webView;

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *url = 
    @"https://api.weibo.com/oauth2/authorize?redirect_uri=http://huixiang.im/auth/weibo&response_type=token&client_id=2630274144&display=mobile";
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];  
    [self.webView setDelegate:self];  
    [self.webView loadRequest:request];  
    
    [SVProgressHUD showWithStatus:@"发送请求"];
	
}

-(void)webViewDidFinishLoad:(UIWebView *)webView  
{  
    NSString *url = self.webView.request.URL.absoluteString;
    NSString* access_token = nil;
    NSString* uid = nil;

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"access_token=(.+)&remind" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *matches = [regex matchesInString:url
                                      options:0
                                        range:NSMakeRange(0, [url length])];
    if(matches.count>0){
        NSRange range=[[matches lastObject]range];
        access_token=[url substringWithRange:NSMakeRange(range.location+13, 32)];
        
    }
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"uid=(.+)" options:NSRegularExpressionCaseInsensitive error:nil];
    
    matches = [regex matchesInString:url
                                      options:0
                                        range:NSMakeRange(0, [url length])];
    if(matches.count>0){
        NSRange range=[[matches lastObject]range];
        uid=[url substringWithRange:NSMakeRange(range.location+4, range.length-4)];
    }
                                  
    if(access_token && uid)
    {      
        [self getUserInfoWithToken:access_token uid:uid];
    }
    
    [SVProgressHUD showSuccessWithStatus:@"成功"];

}

-(void)getUserInfoWithToken:(NSString *)access_token uid:(NSString *)uid
{
    [HTTP sendRequestToPath:@"/authuser" method:@"POST" params:@{@"name":@"weibo",@"access_token":access_token} cookies:nil completionHandler:^(id data) {
        NSMutableDictionary* user=[NSMutableDictionary dictionary];
        user[@"id"]=data[@"msg"][@"id"];
        user[@"weibo_access_token"]=data[@"msg"][@"weibo_access_token"];
        user[@"name"]=data[@"msg"][@"name"];
        user[@"client_hash"]=data[@"msg"][@"client_hash"];
        user[@"weibo_id"]=data[@"msg"][@"weibo_id"];
        [Settings saveUser:user];
        //[self dismissModalViewControllerAnimated:YES]
    }];

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:@"网络连接出错啦"];
}


- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

@end
