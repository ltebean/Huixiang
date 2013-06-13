//
//  ViewController.m
//  Huixiang
//
//  Created by ltebean on 13-6-13.
//  Copyright (c) 2013年 ltebean. All rights reserved.
//

#import "ViewController.h"
#import "HTTP.h"

@interface ViewController ()
@property(nonatomic,strong) NSMutableArray* pieces;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property int currentIndex;
@property BOOL start;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentIndex=0;
    self.start=NO;
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [self refreshData];
}


-(void)refreshData
{
    [HTTP sendRequestToPath:@"pieces" method:@"GET" params:nil completionHandler:^(id data) {
        self.pieces=data;
        self.start=YES;
        [self startAnimation];
    }];
}

-(void)startAnimation
{
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.label.alpha=1.0;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:1.0 delay:2.0 options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              self.label.alpha=0.0;
                                              
                                          }
                                          completion:^(BOOL finished){
                                              self.currentIndex++;
                                              if(self.currentIndex==self.pieces.count){
                                                  self.currentIndex=0;
                                              }
                                              CGFloat height=[self measureTextHeight:self.pieces[self.currentIndex][@"content"] fontSize:18 constrainedToSize:CGSizeMake(369, 960)];
                                              self.label.bounds=CGRectMake(self.label.bounds.origin.x,self.label.bounds.origin.y, self.label.bounds.size.width, height+20);
                                              self.label.text=self.pieces[self.currentIndex][@"content"];
                                              if(self.start){
                                                  [self startAnimation];
                                              }else{
                                                  return;
                                              }
                                              
                                              
                                          }
                          ];
                     }
     ];
}

-(CGFloat)measureTextHeight:(NSString*)text fontSize:(CGFloat)fontSize constrainedToSize:(CGSize)constrainedToSize
{
    CGSize mTempSize = [text sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:constrainedToSize lineBreakMode:UILineBreakModeCharacterWrap];
    return mTempSize.height;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.start=NO;
    [super viewWillDisappear:YES];
}



@end
