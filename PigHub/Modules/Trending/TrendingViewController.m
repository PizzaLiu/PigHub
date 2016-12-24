//
//  TrendingViewController.m
//  PigHub
//
//  Created by Rainbow on 2016/12/19.
//  Copyright © 2016年 PizzaLiu. All rights reserved.
//

#import "TrendingViewController.h"
#import "SegmentBarView.h"

@interface TrendingViewController () <UITableViewDelegate, UITableViewDataSource, UIToolbarDelegate>

@property (weak, nonatomic) IBOutlet SegmentBarView *segmentBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UIImage *shadowImageView;
@property (weak, nonatomic) UIImageView *navHairline;

@end

@implementation TrendingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navHairline = [self findNavBarHairline];

    //if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    //}
    self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(40, 0, 0, 0);

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.segmentBar setHidden:NO];
    [self.navHairline setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.segmentBar setHidden:YES];
    [self.navHairline setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [self randomColor];

    return cell;
}

- (UIColor *)randomColor
{
    CGFloat r = arc4random_uniform(255);
    CGFloat g = arc4random_uniform(255);
    CGFloat b = arc4random_uniform(255);

    return [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:1];
}

#pragma mark - navbar

- (UIImageView *)findNavBarHairline
{
    for (UIView *aView in self.navigationController.navigationBar.subviews) {
        for (UIView *bView in aView.subviews) {
            if ([bView isKindOfClass:[UIImageView class]] &&
                bView.bounds.size.width == self.navigationController.navigationBar.frame.size.width &&
                bView.bounds.size.height < 2) {
                return (UIImageView *)bView;
            }
        }
    }

    return nil;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
