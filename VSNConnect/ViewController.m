//
//  ViewController.m
//  VSNConnect
//
//  Created by Ed Gilmore on 8/12/14.
//  Copyright (c) 2014 Ed Gilmore - Onn, Inc. All rights reserved.
//  www.onncreative.com
//

#import "ViewController.h"
#import "BluetoothConstants.h"

#define VALRT_DEVICE_LOCAL_NAME @"V.ALRT A5:B1:4D" //get the address your V.ALRT and put it here

@interface ViewController ()

@end

@implementation ViewController

@synthesize deviceInfoTextView, deviceAddressLabel, buttonStatusLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [deviceAddressLabel setText:VALRT_DEVICE_LOCAL_NAME];
    
    // Scan for all available CoreBluetooth LE devices
	//NSArray *services = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"1802"]];
	CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    //scan for devices
	//[centralManager scanForPeripheralsWithServices:services options:nil];
	self.centralManager = centralManager;
}

// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	// Determine the state of the peripheral
	if ([central state] == CBCentralManagerStatePoweredOff) {
		NSLog(@"CoreBluetooth BLE hardware is powered off");
	}
	else if ([central state] == CBCentralManagerStatePoweredOn) {
		NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        // Scan for all available CoreBluetooth LE devices
        NSArray *services = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"1802"]];
        //scan for devices
        [self.centralManager scanForPeripheralsWithServices:services options:nil];
	}
	else if ([central state] == CBCentralManagerStateUnauthorized) {
		NSLog(@"CoreBluetooth BLE state is unauthorized");
	}
	else if ([central state] == CBCentralManagerStateUnknown) {
		NSLog(@"CoreBluetooth BLE state is unknown");
	}
	else if ([central state] == CBCentralManagerStateUnsupported) {
		NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
	}
}

// method called whenever we have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	[peripheral setDelegate:self];
    [peripheral discoverServices:nil];
	
    self.connected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
    self.deviceInfoTextView.text = [NSString stringWithFormat:@"%@\n", self.connected];

    
    
}

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	for (CBService *service in peripheral.services) {
        
		[peripheral discoverCharacteristics:nil forService:service];
	}
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    //This sample code is just picking the device we set above in our #define, but normally
    //you would save all of the disocvered devices in an array, and then present those to
    //the user in some sort of tableview to the user so that they can pick which device
    //they want to connect to.
    
    //get the local name of the device we just found
	NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    //check if it's equal to the device you're looking for (your device)
	if ([localName isEqual:VALRT_DEVICE_LOCAL_NAME])
    {
		// We found the Heart Rate Monitor
		[self.centralManager stopScan];
		self.valertPeripheral = peripheral;
		peripheral.delegate = self;
		[self.centralManager connectPeripheral:peripheral options:nil];
	}
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    NSLog(@"-CBService is: %@", [service.UUID description]);
    
    if([self compareCBUUID:service.UUID UUID2:[CBUUID UUIDWithString:BLE_VSN_GATT_SERVICE_UUID]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
		{
			
            
            //check if this is the verification service
			if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_VERIFICATION_SERVICE_UUID]]) { // 2
                
              
                
                //write the verification key
                [self writeVerificationKey:peripheral characteristic:aChar error:nil];
                
                //now we need to enable our device to detect for button presses
                [self enableButton:peripheral];
                
                //Note --
                //If you wanted to enable Fall detection or some of the other features, you
                //could do that here by creating a function.  You could start by copying the
                //enableButton function and then modifying it to write the correct values for the
                //appropriate characteristic/service.
                
                // Add our constructed device information to our UITextView
                NSString *temporaryText = [NSString stringWithFormat:@"%@\n", @"Ready..."];  // 4
                
                //update the status in the UI
                self.deviceInfoTextView.text = [self.deviceInfoTextView.text stringByAppendingString:temporaryText];
			}
            
			
		}
    }
    
	
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didUpdateValueForCharacteristic");
    
	// Add our constructed device information to our UITextView
	NSString *temporaryText = [NSString stringWithFormat:@"%@\n", characteristic.UUID];  // 4
    
    self.deviceInfoTextView.text = [self.deviceInfoTextView.text stringByAppendingString:temporaryText];

}

/*
 *  @method didWriteValueForCharacteristic
 *
 *  @param peripheral Pheripheral that got updated
 *  @param characteristic Characteristic that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didWriteValueForCharacteristic is called when write value got a error
 *  Here we get the error reposnse for write value
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //@TODO You should really check the value that is returned to see if it was successful for that characteristic
    NSLog(@"error-%@",[error localizedDescription]);
}


/*
 *  @method writeVerificationKey:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Write the value to the app to verify the app(newer version)
 *
 */
-(void) writeVerificationKey:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)aChar error:(NSError *)error
{
    
    // Add our constructed device information to our UITextView
    NSString *temporaryText = [NSString stringWithFormat:@"%@\n", @"writing verification key..."];  // 4
    self.deviceInfoTextView.text = [self.deviceInfoTextView.text stringByAppendingString:temporaryText];
    
    //write the verification key
    NSData *data = [NSData dataWithBytes:(Byte[]){0x80,0xBE,0xF5,0xAC,0xFF} length:5];
    [peripheral writeValue:data forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
    
    

}

/*
 *  @method enableButton:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Enables notifications on the simple keypress service
 *
 */
//3
-(void)enableButton:(CBPeripheral *)peripheral
{
    
    NSLog(@"enableButton -");
    
    
    for (CBService *service in peripheral.services) {
        
        
        if([self compareCBUUID:service.UUID UUID2:[CBUUID UUIDWithString:BLE_VSN_GATT_SERVICE_UUID]])
        {
            for (CBCharacteristic *aChar in service.characteristics)
            {
                // enable the button short press
                if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_KEYPRESS_DETECTION_UUID]])
                { // 2
                    
                    // Add our constructed device information to our UITextView
                    NSString *temporaryText = [NSString stringWithFormat:@"%@\n", @"Enabling button short press..."];  // 4
                    
                    self.deviceInfoTextView.text = [self.deviceInfoTextView.text stringByAppendingString:temporaryText];
                    
                    NSLog(@"CBService is: %@", [service.UUID description]);
                    NSLog(@"  characteristic is: %@", [aChar.UUID description]);
                    
                    char val = 0x01;
                    NSData *data = [[NSData alloc] initWithBytes:&val length:1];
                    [peripheral writeValue:data forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
                    
                    
               
                    
                }
                else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:BLE_FALL_KEYPRESS_DETECTION_UUID]]) { // 2
                    [peripheral setNotifyValue:YES forCharacteristic:aChar];
                }
            }
        }
	}
}


// instance method to stop the device from rotating - only support the Portrait orientation
- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
}



#pragma mark - helper functions

/*
 *  @method compareCBUUID
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUID compares two CBUUID's to each other and returns 1 if they are equal and 0 if they are not
 *
 */

-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[128];
    char b2[128];
    [UUID1.data getBytes:b1 length:128];
    [UUID2.data getBytes:b2 length:128];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
