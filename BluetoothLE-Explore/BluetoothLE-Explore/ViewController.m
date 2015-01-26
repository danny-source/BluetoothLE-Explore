//
//  ViewController.m
//  BluetoothLE-Explore
//
//  Created by danny on 2014/04/1.
//  Copyright (c) 2014年 danny. All rights reserved.
//

#import "ViewController.h"


@interface ViewController () {
    CBPeripheral *connectPeripheral;
}
@end


@implementation ViewController

@synthesize CM;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    CM= [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)centralManagerDidUpdateState:(CBCentralManager*)cManager
{
    NSMutableString* nsmstring=[NSMutableString stringWithString:@"UpdateState:"];
    BOOL isWork=FALSE;
    switch (cManager.state) {
        case CBCentralManagerStateUnknown:
            [nsmstring appendString:@"Unknown\n"];
            break;
        case CBCentralManagerStateUnsupported:
            [nsmstring appendString:@"Unsupported\n"];
            break;
        case CBCentralManagerStateUnauthorized:
            [nsmstring appendString:@"Unauthorized\n"];
            break;
        case CBCentralManagerStateResetting:
            [nsmstring appendString:@"Resetting\n"];
            break;
        case CBCentralManagerStatePoweredOff:
            [nsmstring appendString:@"PoweredOff\n"];
            break;
        case CBCentralManagerStatePoweredOn:
            [nsmstring appendString:@"PoweredOn\n"];
            isWork=TRUE;
            break;
        default:
            [nsmstring appendString:@"none\n"];
            break;
    }
    NSLog(@"%@",nsmstring);
}



- (IBAction)buttonScanAndConnect:(id)sender {
    [CM stopScan];
    [CM scanForPeripheralsWithServices:nil options:nil];
    NSLog(@"Scan And Connect");
    
}

- (IBAction)buttonStop:(id)sender {
    
    [CM stopScan];
    NSLog(@"stopScan");
    
    if (connectPeripheral == NULL){
        NSLog(@"connectPeripheral == NULL");
        return;
    }
    
    if (connectPeripheral.state == CBPeripheralStateConnected) {
        [CM cancelPeripheralConnection:connectPeripheral];
        NSLog(@"disconnect-1");

    }
/*
    if ([connectPeripheral isConnected]) {
        [CM cancelPeripheralConnection:connectPeripheral];
        NSLog(@"disconnect-1");
    }
*/
}



- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

    NSLog(@"peripheral\n%@\n",peripheral);
    NSLog(@"advertisementData\n%@\n",advertisementData);
    NSLog(@"RSSI\n%@\n",RSSI);
    
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    NSLog(@"localName:%@",localName);
    //if ([peripheral.name length] && [peripheral.name rangeOfString:@"DannySimpleBLE"].location != NSNotFound) {
    if ([localName length] && [localName rangeOfString:@"Polar"].location != NSNotFound) {
        //抓到週邊後就立即停子Scan
        [CM stopScan];
        NSLog(@"stopScan");
        connectPeripheral = peripheral;
        [CM connectPeripheral:peripheral options:nil];
        NSLog(@"connect to %@",peripheral.name);
    }
    
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"%@",@"connected");
    NSLog(@"Connect To Peripheral with name: %@\nwith UUID:%@\n",peripheral.name,peripheral.identifier.UUIDString);
    
    peripheral.delegate=self;//連線成功後會回傳CBPeripheral，並邊要設定Delegate才能對後續的操作有所反應
    [peripheral discoverServices:nil];//一定要執行"discoverService"功能去尋找可用的Service
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%@",@"disconnect-2");
}


//
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices:\n");
    if( peripheral.identifier == NULL  ) return; // zach ios6 added
    if (!error) {
        NSLog(@"====%@\n",peripheral.name);
        NSLog(@"=========== %ld of service for UUID %@ ===========\n",(long)peripheral.services.count,peripheral.identifier.UUIDString);
        
        for (CBService *p in peripheral.services){
            NSLog(@"Service found with UUID: %@\n", p.UUID);
            [peripheral discoverCharacteristics:nil forService:p];
        }
        
    }
    else {
        NSLog(@"Service discovery was unsuccessfull !\n");
    }
    
}
//
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
    //NSLog(@"=========== Service UUID %s ===========\n",[NSUUID UUID] ini);
    if (!error) {
        NSLog(@"=========== %ld Characteristics of %@ service ",(long)service.characteristics.count,service.UUID);
        
        for(CBCharacteristic *c in service.characteristics){
            
            NSLog(@" %@ \n",c.UUID);
            //  CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
            if(service.UUID == NULL || s.UUID == NULL) return; // zach ios6 added

            
        }
        NSLog(@"=== Finished set notification ===\n");
        
        
    }
    else {
        NSLog(@"Characteristic discorvery unsuccessfull !\n");
        
    }

    
}
@end
