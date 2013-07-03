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
@interface CollectionViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSMutableArray* pieces;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic)BOOL loaded;

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
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
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
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath  *)indexPath
{
    return 204;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
