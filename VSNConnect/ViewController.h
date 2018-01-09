//
//  ViewController.h
//  VSNConnect
//
//  Created by Ed Gilmore on 8/12/14.
//  Copyright (c) 2014 Ed Gilmore - Onn, Inc. All rights reserved.
//  www.onncreative.com
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <QuartzCore/QuartzCore.h>



@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate, UITextViewDelegate>
{
    IBOutlet UILabel * buttonStatusLabel;
    IBOutlet UILabel * deviceStatusLabel;
    IBOutlet UILabel * deviceAddressLabel;
    
}


@property (nonatomic, retain) IBOutlet UILabel *deviceAddressLabel;

@property (nonatomic, retain) IBOutlet UILabel *buttonStatusLabel;

// Properties for our Object controls
@property (nonatomic, strong) IBOutlet UIImageView *puckImageView;
@property (nonatomic, strong) IBOutlet UITextView  *deviceInfoTextView;

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral     *valertPeripheral;

// Properties to hold data characteristics for the peripheral device
@property (nonatomic, strong) NSString   *connected;   
@property (nonatomic, strong) NSString   *manufacturer;


@end
