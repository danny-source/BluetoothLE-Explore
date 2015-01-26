//
//  ViewController.h
//  BluetoothLE-Explore
//
//  Created by danny on 2014/1/21.
//  Copyright (c) 2014年 danny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate> {
    
}


@property (nonatomic,strong) CBCentralManager *CM;

- (IBAction)buttonScanAndConnect:(id)sender;
- (IBAction)buttonStop:(id)sender;



@end
