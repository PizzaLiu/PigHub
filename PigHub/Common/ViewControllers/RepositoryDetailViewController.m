//
//  RepositoryDetailViewController.m
//  PigHub
//
//  Created by Rainbow on 2017/1/17.
//  Copyright © 2017年 PizzaLiu. All rights reserved.
//

#import "RepositoryDetailViewController.h"

@interface RepositoryDetailViewController ()


@end

@implementation RepositoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.repo.name;

    UIWebView *webView = [[UIWebView alloc] init];
    [webView setScalesPageToFit:YES];
    self.view = webView;


    NSString *uri = [NSString stringWithFormat:@"https://github.com%@", self.repo.href];
    NSURL *url = [NSURL URLWithString:uri];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL: url];
    [(UIWebView *)self.view loadRequest:req];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
