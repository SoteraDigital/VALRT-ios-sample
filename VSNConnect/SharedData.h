/**
 * SharedData.h
 *
 * This singelton class is used to store all the data
 * @category   Contus
 * @package    com.vsnmobil.valrt
 * @version    1.1
 * @author     Contus Team <developers@contus.in>
 * @copyright  Copyright (C) 2014 Contus. All rights reserved.
 
 */


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Reachability.h"
#define CURRENTPERIFERALID @"Current_periferal_id"
#define IS_DEVICE_REMOVED @"DeviceRemoved"
#define DEVICE_TRAKING_SOUND @"is_device_traking_sound_on"
#define SHOWINGDISCONNECTEDDEVICEPOPUP @"SHOWINGDISCONNECTEDDEVICEPOPUP"
#define Valert_Immediate_Triggered @"Valert_Immediate_Triggered"
#define VALRT_DEVICE_OFF @"device_off"
#define IS_CONNECTED  NSLocalizedString(@"is_connected", nil)
#define IS_DEVICE_TRAKING_FEATURE_ON @"IS_DEVICE_FEATURE_ON"
#define DISABLE_PHONEAPPLICATION_SILENT @"phone_application_silentmode"
#define ENABLED_CALLS @"call_enable"
#define ENABLED_TEXTS @"text_enable"
#define BLE_DISCOVERED_UUIDS  NSLocalizedString(@"discover_uuid", nil)
#define DEFAULTS [NSUserDefaults standardUserDefaults]
@interface SharedData : NSObject
{
    UIAlertView*alert;
}


+ (SharedData *) sharedConstants;
- (BOOL)isReachable;
-(void)localnotify:(NSString *)Status;
-(void)checkDisconnectdevice;
-(void)disconnectNotification:(NSString *)deviceName deviceStatus:(NSString *)deviceStatus;
-(void) alertMessage:(NSString*)alertTitle msg:(NSString*)alertMsg;
-(NSString *)currentDate;
-(NSArray *)getEnabledcalls;
-(NSArray *)getEnabledtexts;
- (BOOL) numericText: (NSString *) numeric;
- (BOOL)ContainValue:(NSString *)substring;
-(void)dismissalert;

//Selected View Id
@property (assign, nonatomic) int selectedLang;
@property (assign, nonatomic) int normalMode;
@property (assign, nonatomic) int fallMode;
@property (assign, nonatomic) int adjustMode;
@property (assign, nonatomic) int fallDetection;

@property (nonatomic, strong) NSString *activeSerialno;
@property (nonatomic, strong) NSString *activeIdentifier;

@property(strong, nonatomic) NSMutableArray *arrPeriperhalNames;

@property(strong, nonatomic) NSMutableArray *arrActivePeripherals;

@property(strong, nonatomic) NSMutableArray *arrActiveIdentifiers;
@property(strong, nonatomic) NSMutableArray *arrAvailableIdentifiers;
@property(strong, nonatomic) NSMutableArray *fallenableIdentifiers;

@property(strong, nonatomic) NSMutableDictionary *laststateIdentifiers;

@property(strong, nonatomic) NSMutableArray *arrConnectedPeripherals;

@property(strong, nonatomic) NSMutableArray *arrDisconnectedIdentifers;

@property(strong, nonatomic) NSMutableArray *arrDiscovereUUIDs;


@property (strong, nonatomic) CBPeripheral *activePeripheral;

@property (nonatomic, strong) NSString *strCurrentPeriPheralName;

@property (nonatomic, strong) NSString *strserialNumber;

@property (nonatomic, strong) NSString *strSofwareVer;

@property (nonatomic, strong) NSString *strBatteryLevelStatus;

@property (nonatomic, strong) NSString *strSignalStregnthstatus;

@property (nonatomic, strong) NSString *strEnteredAlertMessage;

@property (nonatomic, strong) NSMutableArray *arrSelectMultipleContacts;

@property (nonatomic, strong) NSMutableString *strDidSelectContacts;


//Enabled and Disabled Calls and Texts

@property(strong, nonatomic) NSMutableArray *arrEnabledCalls;

@property(strong, nonatomic) NSMutableArray *arrEnabledTexts;

@property (nonatomic, strong) NSString *strChangName;

@property (assign, nonatomic) int verifyMode;
@property (assign, nonatomic) int readMac;
@property (assign, nonatomic) int notifyserialSoft;
@property (assign, nonatomic) int readBtry;
@property (assign, nonatomic) int readSoftver;


@property BOOL isAnswered;
//Reachability
@property (nonatomic,retain) Reachability *internetReachability;
@end
