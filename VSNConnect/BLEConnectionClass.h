/**
 * BLEConnectionClass.h
 *
 * This class contains the delegate method of connect,disconnect and other ble features
 * @category   Contus
 * @package    com.vsnmobil.valrt
 * @version    1.1
 * @author     Contus Team <developers@contus.in>
 * @copyright  Copyright (C) 2014 Contus. All rights reserved.
 
 */
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import "ConstantBLEkeys.h"
#import "dbConnect.h"

@protocol BLEConnectionDelegate
@optional
-(void) keyfobReady;
-(void)getCurrentBatteryStatus:(CBPeripheral *)peripheral ;
-(void) keyValuesUpdated:(CBPeripheral *)peripheral ;
-(void) fallDetectValuesUpdated:(CBPeripheral *)peripheral;
-(void) deviceDisconnected; // Tracker: When Periferal Device get disconnected
-(void) deviceConnectedAgain; // Tracker : Periferal Device get Connected Again
@required
@end



@interface BLEConnectionClass : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate>{
    
    dbConnect *dConnect;
     BOOL isFullyConnected;
    NSDate*connectedEarlierTime;
    NSDate*disconnectedEarlierTime;
    NSTimer *disconnectedTimer;
    BOOL  isFullyDisconnected;
    NSString *peripheralID;
}

@property (nonatomic)   float batteryLevel;
@property (nonatomic)   float signalLevel;

@property (nonatomic)   BOOL key1;
@property (nonatomic)   BOOL key2;

@property (nonatomic)   char x;
@property (nonatomic)   char y;
@property (nonatomic)   char z;
@property (nonatomic)   char TXPwrLevel;

@property (assign)      BOOL isFullyConnected;
@property (assign)      BOOL isFullyDisconnected;
@property (nonatomic,assign) id <BLEConnectionDelegate> delegate;
@property (strong, nonatomic)  NSMutableArray *peripherals;
@property (strong, nonatomic) CBCentralManager *CM;
@property (strong, nonatomic) CBPeripheralManager *PM;
@property (strong, nonatomic) CBPeripheral *activePeripheral;

@property (strong, nonatomic) UIButton *BLEDeviceConnectbtn;


-(void) cleanup:(CBPeripheral *)p;
-(void) initConnectButtonPointer:(UIButton *)b;
-(void) soundBuzzer:(Byte)buzVal p:(CBPeripheral *)p;
-(void) readRssi:(CBPeripheral *)p;
-(void) readBattery:(CBPeripheral *)p;
-(void) readSerialNumber:(CBPeripheral *)p;
-(void) readSoftwareRev:(CBPeripheral *)p;
-(void) readMacAddress:(CBPeripheral *)p;
-(void) enableAccelerometer:(CBPeripheral *)p;
-(void) enableButtons:(CBPeripheral *)p;
-(void) normalmode:(CBPeripheral *)p;
-(void) cancelMode:(CBPeripheral *)p;
-(void) verifyMode:(CBPeripheral *)p;
-(void) verifyModetemp:(CBPeripheral *)p;
//Fall Detection
-(void)localnotify:(NSString *)deviceName deviceStatus:(NSString *)deviceStatus;
-(void) enableFallDetection:(CBPeripheral *)p;
-(void) silentNormalmode:(Byte)byteVal periperal:(CBPeripheral *)periperal;
-(void) adjustInterval:(CBPeripheral *)p;
-(void) getDeviceInfo:(NSString *)deviceId;



-(void) writeValue:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID  p:(CBPeripheral *)p data:(NSData *)data;
-(void) readValue: (NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID  p:(CBPeripheral *)p;
-(void) notification:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID  p:(CBPeripheral *)p on:(BOOL)on;


-(UInt16) swap:(UInt16) s;
-(int) controlSetup:(int) s;
-(int) findBLEPeripherals:(int) timeout;
-(const char *) centralManagerStateToString:(int)state;
-(void) scanTimer:(NSTimer *)timer;
-(void) printKnownPeripherals;
-(void) printPeripheralInfo:(CBPeripheral*)peripheral;
-(void) connectPeripheral:(CBPeripheral *)peripheral;
-(void) enablefall:(Byte)buzVal p:(CBPeripheral *)p;
-(void) getAllServicesFromKeyfob:(CBPeripheral *)p;
-(void) getAllCharacteristicsFromKeyfob:(CBPeripheral *)p;
-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p data:(NSData *)data;
-(CBService *) notifyfindServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p;
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service data:(NSData *)data;
-(CBCharacteristic *) notifyfindCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service;
-(const char *) UUIDToString:(CFUUIDRef) UUID;
-(const char *) CBUUIDToString:(CBUUID *) UUID;
-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2;
-(int) compareCBUUIDToInt:(CBUUID *) UUID1 UUID2:(UInt16)UUID2;
-(UInt16) CBUUIDToInt:(CBUUID *) UUID;
-(int) UUIDSAreEqual:(CFUUIDRef)u1 u2:(CFUUIDRef)u2;

@end
