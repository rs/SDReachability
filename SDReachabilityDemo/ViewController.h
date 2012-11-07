//
//  ViewController.h
//  SDReachabilityDemo
//
//  Created by Olivier Poitrey on 07/11/12.
//  Copyright (c) 2012 Hackemist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *reachableLabel;
@property (weak, nonatomic) IBOutlet UILabel *WWANLabel;
@property (weak, nonatomic) IBOutlet UILabel *WiFiLabel;

- (IBAction)dealloc:(id)sender;

@end
