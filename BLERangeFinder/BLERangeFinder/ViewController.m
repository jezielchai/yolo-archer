//
//  ViewController.m
//  BLERangeFinder
//
//  Created by Jeziel Jones on 3/23/15.
//  Copyright (c) 2015 Jeziel Jones. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize ble;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
    
    //lblRSSIclose.layer.cornerRadius = 15;
    //lblRSSIfar.layer.cornerRadius = 15;
    //lblRSSIclose.hidden= YES;
    //lblRSSIfar.hidden = YES;
    rssiClose.hidden = YES;
    rssiTenFeet.hidden = YES;
    rssiTwenty.hidden = YES;
    rssiThirty.hidden = YES;
    rssiFourty.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BLE delegate
- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    //[btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
    //[indConnecting stopAnimating];
    btnConnect.hidden = NO;
    lblRSSI.text = @"---";
    [rssiTimer invalidate];
}

-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    lblRSSI.text = rssi.stringValue;
    //float result = [lblRSSI.text floatValue];
    [globalArray addObject:rssi];
    NSUInteger numObjects = [globalArray count];
    //NSLog(@"my array is %@",globalArray[i]);
    NSLog(@"number of objects in global array %lu:",(unsigned long)numObjects);
    float resultTest = [globalArray.lastObject floatValue];
    if (resultTest < -30 && resultTest > -45)
    {
        rssiClose.hidden = NO;
        rssiTenFeet.hidden = YES;
        rssiTwenty.hidden = YES;
        rssiThirty.hidden = YES;
        rssiFourty.hidden = YES;
    }
    else if (resultTest < -45 && resultTest > -55)
    {
        rssiClose.hidden = YES;
        rssiTenFeet.hidden = NO;
        rssiTwenty.hidden = YES;
        rssiThirty.hidden = YES;
        rssiFourty.hidden = YES;
    }
    else if (resultTest < -55 && resultTest > -65)
    {
        rssiClose.hidden = YES;
        rssiTenFeet.hidden = YES;
        rssiTwenty.hidden = NO;
        rssiThirty.hidden = YES;
        rssiFourty.hidden = YES;
    }
    else if (resultTest < -65 && resultTest > -75)
    {
        rssiClose.hidden = YES;
        rssiTenFeet.hidden = YES;
        rssiTwenty.hidden = YES;
        rssiThirty.hidden = NO;
        rssiFourty.hidden = YES;
    }
    else if (resultTest < -75 && resultTest < -85)
    {
        rssiClose.hidden = YES;
        rssiTenFeet.hidden = YES;
        rssiTwenty.hidden = YES;
        rssiThirty.hidden = YES;
        rssiFourty.hidden = NO;
    }
    
    //when the number of objects in global array is 10
    if(numObjects == 10)
    {
        for(int j=0;j<10;j++)
        {
            float result = [globalArray[j] floatValue];
            sumTotal += result;
            NSLog(@"sumtotal: %f", sumTotal);
        }
        average = sumTotal/10;
        //adding in NSLog for testing
        NSLog(@"Average rssi @ location: %f",average);
        //have to clear array to store 10 new RSSI values.
        [globalArray removeAllObjects];
        //initially didn't have the sumTotal reset which was resulting in a buildup of 'result' values and an ever increasing average.
        sumTotal = 0;
        if (average > -50) {
            //lblRSSIclose.hidden = NO;
            //lblRSSIfar.hidden = YES;
            //rssiClose.hidden = NO;
            NSLog(@"Average is >-50");
        }else if (average < -50){
            //lblRSSIfar.hidden = NO;
            //lblRSSIclose.hidden = YES;
            //rssiClose.hidden = YES;
            NSLog(@"Average is <-50");

        }
    }
    /*
     
     while (numObjects < 10)
     {
     i++;
     
     if (i == 10) {
     break;
     }
     }
     
     for(int j=0; j<=9; j++)
     {
     float result = [globalArray[j] floatValue];
     sumTotal += result;
     average = sumTotal/10;
     j++;
     }*/
    
    /*if (numObjects == 10 ) {
     [globalArray removeAllObjects];
     break;
     }*/
    
    /*if ( result < -55){
     lblRSSIfar.text = rssi.stringValue;
     }
     else if (result > -55 ){
     lblRSSIclose.text = rssi.stringValue;
     }*/
}
-(void) readRSSITimer:(NSTimer *)timer
{
    [ble readRSSI];
    
}

// When disconnected, this will be called
-(void) bleDidConnect
{
    NSLog(@"->Connected");
    btnConnect.hidden = YES;
    //[indConnecting stopAnimating];

    // send reset
    UInt8 buf[] = {0x04, 0x00, 0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    
    globalArray = [[NSMutableArray alloc] init];
    
    // Schedule to read RSSI 1 times per second
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
}

// When data is comming, this will be called
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"Length: %d", length);
    
    // parse data, all commands are in 3-byte
    for (int i = 0; i < length; i+=3)
    {
        
        NSLog(@"0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
        
        /*if (data[i] == 0x0A)
        {
            if (data[i+1] == 0x01)
                swDigitalIn.on = true;
            else
                swDigitalIn.on = false;
        }
        else if (data[i] == 0x0B)
        {
            UInt16 Value;
            
            Value = data[i+2] | data[i+1] << 8;
            lblAnalogIn.text = [NSString stringWithFormat:@"%d", Value];
        }*/
    }
}

#pragma mark - Actions

// Connect button will call to this
- (IBAction)btnScanForPeripherals:(id)sender
{
    if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            //[btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
            btnConnect.hidden = NO;
            return;
        }
    
    if (ble.peripherals)
        ble.peripherals = nil;
    
    //[btnConnect setEnabled:false];
    btnConnect.hidden = YES;
    [ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    //[indConnecting startAnimating];
}

-(void) connectionTimer:(NSTimer *)timer
{
    //[btnConnect setEnabled:true];
    //[btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    if (ble.peripherals.count > 0)
    {
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
    }
    else
    {
        NSLog(@"This would be where an animaton goes");
        //[btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
        //[indConnecting stopAnimating];
    }
}





@end
