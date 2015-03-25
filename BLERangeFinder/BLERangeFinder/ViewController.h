//
//  ViewController.h
//  BLERangeFinder
//
//  Created by Jeziel Jones on 3/23/15.
//  Copyright (c) 2015 Jeziel Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"

extern NSMutableArray *globalArray;

@interface ViewController : UIViewController<BLEDelegate>
{
    IBOutlet UIButton *btnConnect;
    //IBOutlet UIActivityIndicatorView *indConnecting;
    IBOutlet UILabel *lblRSSI;
    //IBOutlet UILabel *lblRSSIclose;
    //IBOutlet UILabel *lblRSSIfar;
    IBOutlet UIImageView *rssiClose;
    IBOutlet UIImageView *rssiTenFeet;
    IBOutlet UIImageView *rssiTwenty;
    IBOutlet UIImageView *rssiThirty;
    IBOutlet UIImageView *rssiFourty;
    NSTimer *rssiTimer;
    NSMutableArray *globalArray;
    float sumTotal;
    float average;
}

@property (strong, nonatomic) BLE *ble;

@end

