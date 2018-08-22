//
//  ViewController.m
//  GTNetworkDemo
//
//  Created by law on 2018/8/22.
//  Copyright © 2018年 Goldx4. All rights reserved.
//

#import "ViewController.h"
#import "GTNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [GTNetworking GET:@"https://www.v2ex.com/api/topics/hot.json" parameters:@{} success:^(id responseData) {
        
    } faliure:^(NSError *error) {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
