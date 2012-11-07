//
//  ViewController.m
//  SDReachabilityDemo
//
//  Created by Olivier Poitrey on 07/11/12.
//  Copyright (c) 2012 Hackemist. All rights reserved.
//

#import "ViewController.h"
#import "SDReachability.h"

@interface ViewController ()

@property (strong, nonatomic) SDReachability *reachability;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.reachability = [SDReachability reachabilityWithTarget:self action:@selector(reachabilityChanged:)];
    [self displayReachabilityInfo:self.reachability];
}

- (void)displayReachabilityInfo:(SDReachability *)reachability
{
    self.reachableLabel.text = self.reachability.reachable ? @"YES" : @"NO";
    self.WWANLabel.text = self.reachability.isReachableViaWWAN ? @"YES" : @"NO";
    self.WiFiLabel.text = self.reachability.isReachableViaWiFi ? @"YES" : @"NO";
}

- (void)reachabilityChanged:(SDReachability *)reachability
{
    [self displayReachabilityInfo:reachability];
}

- (IBAction)dealloc:(id)sender
{
    self.reachability = nil;
}

@end
