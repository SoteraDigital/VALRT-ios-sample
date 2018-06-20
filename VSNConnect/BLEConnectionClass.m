/**
 * BLEConnectionClass.m
 *
 * This class contains the delegate method of connect,disconnect and other ble features
 * @category   Contus
 * @package    com.vsnmobil.valrt
 * @version    1.1
 * @author     Contus Team <developers@contus.in>
 * @copyright  Copyright (C) 2014 Contus. All rights reserved.
 
 */

#import "BLEConnectionClass.h"
#import "SharedData.h"
//#import "commonnotifyalert.h"
//#import "Constants.h"
//#import "ManageDevicesViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "AppDelegate.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
//#import "logfile.h"
@implementation BLEConnectionClass

@synthesize delegate;
@synthesize CM,PM;
@synthesize peripherals;
@synthesize activePeripheral;
@synthesize batteryLevel;
@synthesize signalLevel;
@synthesize key1;
@synthesize key2;
@synthesize x;
@synthesize y;
@synthesize z;
@synthesize TXPwrLevel;
@synthesize BLEDeviceConnectbtn,isFullyConnected,isFullyDisconnected;


/*!
 *  @method initConnectButtonPointer
 *
 *  @param b Pointer to the button
 *
 *  @discussion Used to change the text of the button label during the connection cycle.
 */
-(void) initConnectButtonPointer:(UIButton *)b {
    BLEDeviceConnectbtn = b;
}

/*!
 *  @method soundBuzzer:
 *
 *  @param buzVal The data to write
 *  @param p CBPeripheral to write to
 *
 *  @discussion Sound the buzzer on a TI keyfob. This method writes a value to the proximity alert service
 *
 */
-(void) soundBuzzer:(Byte)buzVal p:(CBPeripheral *)p {
    
    NSData *d = [[NSData alloc] initWithBytes:&buzVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
    [self writeValue:TI_KEYFOB_PROXIMITY_ALERT_UUID characteristicUUID:TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID p:p data:d];
}

/**
 *  read Rssi value
 *
 *  @param p peripheral to read rssi value
 */
-(void) readRssi:(CBPeripheral *)p
{
    p.delegate= self;
    [p readRSSI];
}
-(void) enablefall:(Byte)buzVal p:(CBPeripheral *)p
{
    NSData *d = [[NSData alloc] initWithBytes:&buzVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
    [self writeValue:TI_KEYFOB_PROXIMITY_ALERT_UUID characteristicUUID:TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID p:p data:d];
    
}
-(void) silentNormalmode:(Byte)byteVal periperal:(CBPeripheral *)periperal
{
    
    NSData *d = [[NSData alloc] initWithBytes:&byteVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
    [self writeValue:BLE_FALL_KEYPRESS_SERVICE_UUID characteristicUUID:BLE_SILENT_NORMAL_MODE p:periperal data:d];
    
}

/*!
 *  @method adjustInterval:
 *
 *  @param p CBPeripheral to read from
 *
 *  @discussion write value to adjust the connection interval
 *
 */
-(void) adjustInterval:(CBPeripheral *)p
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    if ([platform hasPrefix:@"iPhone7"] || [platform hasPrefix:@"iPhone8"]) {
        NSLog(@"iPhone 6 detected");
    } else {
        //8403940300005802
        NSData *data = [NSData dataWithBytes:(Byte[]){0x10,0x03,0x20,0x03,0x01,0x00,0x58,0x02} length:8];   // 980ms, 1000ms, 1, 6s
        //NSData *data = [NSData dataWithBytes:(Byte[]){0xB0,0x04,0xC0,0x04,0x00,0x00,0x58,0x02} length:8]; // 1500ms, 1520ms, 0, 6s
        //NSData *data = [NSData dataWithBytes:(Byte[]){0xE8,0x03,0xF8,0x03,0x00,0x00,0x58,0x02} length:8]; // 1250ms, 1270ms, 0, 6s
        [self writeValue:SERVICE_ADJUST_CONNECTION_INTERVAL characteristicUUID:CHAR_ADJUST_CONNECTION_INTERVAL p:p data:data];
    }
    
    free(machine);
}


/*!
 *  @method readBattery:
 *
 *  @param p CBPeripheral to read from
 *
 *  @discussion Start a battery level read cycle from the battery level service
 *
 */
-(void) readBattery:(CBPeripheral *)p {
    [self readValue:TI_KEYFOB_BATT_SERVICE_UUID characteristicUUID:TI_KEYFOB_LEVEL_SERVICE_UUID p:p];
}

/*!
 *  @method readSerialNumber:
 *
 *  @param p CBPeripheral to read from
 *
 *  @discussion Start a Device info level read cycle from the Serial number of the device level service
 *
 */
-(void) readSerialNumber:(CBPeripheral *)p {
    [self readValue:SERVICE_DEVICE_INFO characteristicUUID:CHAR_SERIAL_NUMBER p:p];
}

/*!
 *  @method readSoftwareRev:
 *
 *  @param p CBPeripheral to read from
 *
 *  @discussion Start a Device info level read cycle from the software dev of the level service
 *
 */
-(void) readSoftwareRev:(CBPeripheral *)p {
    [self readValue:SERVICE_DEVICE_INFO characteristicUUID:CHAR_SOFTWARE_REV p:p];
}

/*!
 *  @method readSoftwareRev:
 *
 *  @param p CBPeripheral to read from
 *
 *  @discussion Start a Device info level read cycle from the software dev of the level service
 *
 */
-(void) readMacAddress:(CBPeripheral *)p {
    [self readValue:BLE_KEYPRESS_SERVICE_UUID characteristicUUID:CHAR_SOFTWARE_REV p:p];
}

//Clean up the characteristic
-(void)cleanup:(CBPeripheral *)p {
    // See if we are subscribed to a characteristic on the peripheral
    if (p.services != nil) {
        for (CBService *service in p.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    
                    if (characteristic.isNotifying) {
                        [p setNotifyValue:NO forCharacteristic:characteristic];
                        return;
                    }
                    
                }
            }
        }
    }
    [self.CM cancelPeripheralConnection:p];
}

//

/*!
 *  @method enableAccelerometer:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Enables the accelerometer and enables notifications on X,Y and Z axis
 *
 */
-(void) enableAccelerometer:(CBPeripheral *)p
{
    char data;
    /*NSString *_date=[[SharedData sharedConstants] currentDate];
    dConnect = [[dbConnect alloc]init];
    //insert the device connection status
    NSString *strID = [NSString stringWithFormat:@"%@",p.identifier];
    
    if([strID length] >20)
    {
        
        strID = [strID substringFromIndex: [strID length] - 20];
        if([dConnect checkfallenableDevice:strID] ==1)
        {
            data = 0x06;
            [dConnect addStatus:[NSString stringWithFormat:@"%@",_date]  bleName:[DEFAULTS objectForKey:strID] bleAddress:strID bleStatus:NSLocalizedString(@"db_fall_enable", nil)];
        }
        else
        {
            data = 0x02;
            [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:[DEFAULTS objectForKey:strID] bleAddress:strID bleStatus: NSLocalizedString(@"db_fall_diable", nil)];
        }
    }
    else
    {
        data = 0x02;
        [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:[DEFAULTS objectForKey:strID] bleAddress:strID bleStatus: NSLocalizedString(@"db_fall_diable", nil)];
    }*/
    NSData *d = [[NSData alloc] initWithBytes:&data length:1];
    //Read Serial Number
    
    
    [self writeValue:BLE_FALL_KEYPRESS_SERVICE_UUID characteristicUUID:BLE_KEYPRESS_DETECTION_UUID p:p data:d];
    [self notification:BLE_FALL_SERVICE_UUID characteristicUUID:BLE_DETECTION_UUID p:p on:YES];
}

//Set Normal mode for fall detect and keypress
-(void) normalmode:(CBPeripheral *)p
{
    char data = 0x00;
    NSData *d = [[NSData alloc] initWithBytes:&data length:1];
    [self writeValue:BLE_KEYPRESS_SERVICE_UUID characteristicUUID:BLE_KEYPRESS_FALLDETECT_ACK p:p data:d];
    
}



/*!
 *  @method enableButtons:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Enables notifications on the simple keypress service
 *
 */
-(void) enableButtons:(CBPeripheral *)p {
    
    char data ;
    NSString *strID = [NSString stringWithFormat:@"%@",p.identifier];
    if([strID length] >20)
    {
        strID = [strID substringFromIndex: [strID length] - 20];
            dConnect = [[dbConnect alloc]init];
        if ([dConnect checkfallenableDevice:strID]==1)
        {
            data = 0x06;
        }
        else
        {
            data = 0x02;
        }
    }
    else
    {
        data = 0x02;
    }
    [SharedData sharedConstants].fallMode =1;
    NSData *d = [[NSData alloc] initWithBytes:&data length:1];
    [self writeValue:BLE_FALL_DETECTION_SERVICE_UUID characteristicUUID:BLE_FALL_DETECTION_UUID p:p data:d];
    [self notification:BLE_FALL_SERVICE_UUID characteristicUUID:BLE_DETECTION_UUID p:p on:YES];
    
    [self notification:TI_KEYFOB_BATT_SERVICE_UUID characteristicUUID:TI_KEYFOB_LEVEL_SERVICE_UUID p:p on:YES];
    
    [SharedData sharedConstants].notifyserialSoft = 1;
    [self readSerialNumber:p];
    [SharedData sharedConstants].notifyserialSoft = 0;
    [SharedData sharedConstants].readSoftver = 1;
    [self readSoftwareRev:p];
    [SharedData sharedConstants].readSoftver =0;
    [SharedData sharedConstants].readMac =1;
    [self readMacAddress:p];
}




/*!
 *  @method Enable Fall Detection:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Disables notifications on the Notify when Enable Fall Detction
 *
 */

-(void) enableFallDetection:(CBPeripheral *)p{
    
    //[self notification:BLE_FALL_DETECTION_SERVICE_UUID characteristicUUID:BLE_FALL_DETECTION_UUID p:p on:YES];
}
/*!
 *  @method verifyMode:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Write the value to the app to verify the app(old version)
 *
 */
//verify mode
-(void) verifyMode:(CBPeripheral *)p
{
    // char data = 0x00;
    [SharedData sharedConstants].verifyMode =1;
    //  NSData *d = [[NSData alloc] initWithBytes:&data length:1];
    NSData *data = [NSData dataWithBytes:(Byte[]){0xBC,0xF5,0xAC,0x48,0x40} length:5];
    [self writeValue:BLE_KEYPRESS_SERVICE_UUID characteristicUUID:BLE_KEYPRESS_FALLDETECT_NORMAL p:p data:data];
}

/*!
 *  @method verifyModetemp:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Write the value to the app to verify the app(newer version)
 *
 */
//verify mode
-(void) verifyModetemp:(CBPeripheral *)p
{
    
    [SharedData sharedConstants].verifyMode =1;
    NSData *data = [NSData dataWithBytes:(Byte[]){0x80,0xBE,0xF5,0xAC,0xFF} length:5];
    [self writeValue:BLE_KEYPRESS_SERVICE_UUID characteristicUUID:BLE_KEYPRESS_FALLDETECT_NORMAL p:p data:data];
}


/*!
 *  @method cancelMode:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Cancel all peripheral
 *
 */
//verify mode
-(void) cancelMode:(CBPeripheral *)p
{
    [self.CM cancelPeripheralConnection:p];
    
    [self centralManager:self.CM didDisconnectPeripheral:p error:Nil];
}

/*!
 *  @method writeValue:
 *
 *  @param serviceUUID Service UUID to write to (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to write to (e.g. 0x2401)
 *  @param data Data to write to peripheral
 *  @param p CBPeripheral to write to
 *
 *  @discussion Main routine for writeValue request, writes without feedback. It converts integer into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service.
 *  If this is found, value is written. If not nothing is done.
 *
 */

-(void) writeValue:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    
    
    UInt16 s = [self swap:[serviceUUID integerValue]];
    UInt16 c = [self swap:[characteristicUUID integerValue]];
    
    
    NSLog(@"s %d",s);
    NSLog(@"c %d",c);
    
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    
    NSLog(@"s %@",su);
    NSLog(@"c %@",cu);
    CBService *service = [self findServiceFromUUID:su p:p data:data];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef)(p.identifier)]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service data:data];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef)(p.identifier)]);
        return;
    }
    char buzVal=0x02;
    //Just check buzdata is 0x02 then write value without response
    //@discussion -For find me if we write value with with response its not working properly,so for find me only we write value to puck with without response.
    //@comments-OX02 to write value for find me.
    NSData *buzdata = [[NSData alloc] initWithBytes:&buzVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
    if([data isEqualToData:buzdata] && [SharedData sharedConstants].fallMode !=1)
    {
        [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    }
    else
    {
        
        
        [SharedData sharedConstants].fallMode =0;
        [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
    
    //Writing value to the log for  check characteristic and service
    dConnect = [[dbConnect alloc]init];
    //insert the device connection status
   // NSString *strID = [NSString stringWithFormat:@"%@",p.identifier];
   // strID = [strID substringFromIndex: [strID length] - 20];
    // [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:[NSString stringWithFormat:@"Writecharacteristic-%@",strID] bleAddress:[NSString stringWithFormat:@"UUID-%@",characteristic.UUID] bleStatus:[NSString stringWithFormat:@"Byte-%@",data]];
    
    
}

/*!
 *  @method readValue:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for read value request. It converts integers into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service.
 *  If this is found, the read value is started. When value is read the didUpdateValueForCharacteristic
 *  routine is called.
 *
 *  @see didUpdateValueForCharacteristic
 */

-(void) readValue: (NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID p:(CBPeripheral *)p {
    UInt16 s = [self swap:[serviceUUID integerValue]];
    UInt16 c = [self swap:[characteristicUUID integerValue]];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p data:nil];
    if (!service)
    {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef)(p.identifier)]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service data:nil];
    if (!characteristic)
    {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef)(p.identifier)]);
        return;
    }
    [p readValueForCharacteristic:characteristic];
    
    
    //Add value to the datbase to check read value
    //NSString *_date=[[SharedData sharedConstants] currentDate];
    dConnect = [[dbConnect alloc]init];
    //insert the device connection status
    //NSString *strID = [NSString stringWithFormat:@"%@",p.identifier];
    //strID = [strID substringFromIndex: [strID length] - 20];
    
    //   [dConnect addStatus:[NSString stringWithFormat:@"%@",_date]  bleName:[NSString stringWithFormat:@"Readvaluecharacteristic-%@",strID] bleAddress:[NSString stringWithFormat:@"UUID-%@",characteristic.UUID] bleStatus:[NSString stringWithFormat:@"no byte"]];
}


/*!
 *  @method notification:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for enabling and disabling notification services. It converts integers
 *  into CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service.
 *  If this is found, the notfication is set.
 *
 */
-(void) notification:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on
{
    UInt16 s = [self swap:[serviceUUID integerValue]];
    UInt16 c = [self swap:[characteristicUUID integerValue]];
    
    NSLog(@"s %d",s);
    NSLog(@"c %d",c);
    
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self notifyfindServiceFromUUID:su p:p];
    if (!service)
    {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef)(p.identifier)]);
        return;
    }
    CBCharacteristic *characteristic = [self notifyfindCharacteristicFromUUID:cu service:service];
    if (!characteristic)
    {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef)(p.identifier)]);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
    
    //Add value to the datbase to check notify
    //NSString *_date=[[SharedData sharedConstants] currentDate];
    dConnect = [[dbConnect alloc]init];
    //insert the device connection status
   // NSString *strID = [NSString stringWithFormat:@"%@",p.identifier];
    //strID = [strID substringFromIndex: [strID length] - 20];
    
    // [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:[NSString stringWithFormat:@"Notification-%@",strID] bleAddress:[NSString stringWithFormat:@"UUID-%@",characteristic.UUID] bleStatus:[NSString stringWithFormat:@"no byte"]];
}


/*!
 *  @method swap:
 *
 *  @param s Uint16 value to byteswap
 *
 *  @discussion swap byteswaps a UInt16
 *
 *  @return Byteswapped UInt16
 */

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

/*!
 *  @method controlSetup:
 *
 *  @param s Not used
 *
 *  @return Allways 0 (Success)
 *
 *  @discussion controlSetup enables CoreBluetooths Central Manager and sets delegate to TIBLECBKeyfob class
 *
 */

- (int) controlSetup: (int) s{
    
    dispatch_queue_t centralQueue = dispatch_queue_create("mycentral", DISPATCH_QUEUE_SERIAL);// or however you want to create your dispatch_queue_t
    NSDictionary *options = @{
                              CBCentralManagerOptionRestoreIdentifierKey:@"valrtrestore",
                              CBCentralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:YES],
                              };
    
    //NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE], CBCentralManagerOptionShowPowerAlertKey, nil];
    self.CM = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue options:options];
    self.PM = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil options:nil];
    return 0;
}

/*!
 *  @method findBLEPeripherals:
 *
 *  @param timeout timeout in seconds to search for BLE peripherals
 *
 *  @return 0 (Success), -1 (Fault)
 *
 *  @discussion findBLEPeripherals searches for BLE peripherals and sets a timeout when scanning is stopped
 *
 */
- (int) findBLEPeripherals:(int) timeout
{
    if(self.CM.state ==CBCentralManagerStatePoweredOn)
    {
        //Store and Show the paired devices
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        if(self.CM.state == CBCentralManagerStatePoweredOn)
        {
            [self.CM scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"1802"]] options:options];
            [BLEDeviceConnectbtn setTitle:@"Scanning.." forState:UIControlStateNormal];
        }
    }
    return 0; // Started scanning OK !
}


/*!
 *  @method connectPeripheral:
 *
 *  @param p Peripheral to connect to
 *
 *  @discussion connectPeripheral connects to a given peripheral and sets the activePeripheral property of TIBLECBKeyfob.
 *
 */
- (void) connectPeripheral:(CBPeripheral *)peripheral
{
    
    peripheral.delegate = self;
    activePeripheral = peripheral;
    activePeripheral.delegate = self;
    
    
    
    [CM connectPeripheral:activePeripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey: @YES,
                                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES,
                                                     CBConnectPeripheralOptionNotifyOnNotificationKey: @YES}];
    
    NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:BLE_DISCOVERED_UUIDS];
    NSArray *defaultUUIDS = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
    if (defaultUUIDS != nil){
        [SharedData sharedConstants].arrDiscovereUUIDs = [[NSMutableArray alloc] initWithArray:defaultUUIDS];
    }
    
    NSUUID *uiid = peripheral.identifier;
    
    if (![[SharedData sharedConstants].arrDiscovereUUIDs containsObject:uiid])
    {
        [[SharedData sharedConstants].arrDiscovereUUIDs addObject:[uiid UUIDString]];
    }
    
    //[DEFAULTS setValue:@"1" forKey:@"AlreadyConnected"];
    if([[SharedData sharedConstants].arrDiscovereUUIDs count]>0){
    [DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:[SharedData sharedConstants].arrDiscovereUUIDs] forKey:BLE_DISCOVERED_UUIDS];
    [DEFAULTS synchronize];
    }
    //Maintaining periperal names in singelton class
    [[SharedData sharedConstants].arrPeriperhalNames removeObject:peripheral];
    
    //Maintaining discovered uuid in singelton class
    if (![[SharedData sharedConstants].arrDiscovereUUIDs containsObject:uiid])
    {
        [[SharedData sharedConstants].arrDiscovereUUIDs addObject:[uiid UUIDString]];
        
    }
    
    //Add the periperal to active periperal if singleton class not containg active periperals
    if (![[SharedData sharedConstants].arrActiveIdentifiers containsObject:peripheral.identifier])
    {
        [[SharedData sharedConstants].arrActivePeripherals removeAllObjects];
        //peripheral.services
        NSString*state = [NSString stringWithFormat:@"%ld",(long)peripheral.state];
        NSString*Identifier = [NSString stringWithFormat:@"%@",peripheral.identifier];
        [[SharedData sharedConstants].laststateIdentifiers setValue:state forKey:Identifier];
        [[SharedData sharedConstants].arrActiveIdentifiers addObject:peripheral.identifier];
        [[SharedData sharedConstants].arrActivePeripherals addObject:peripheral];
#ifdef __LOG_FILE__
        //@log to check the issue
        NSString*logValue = [NSString stringWithFormat:@"last connected peripheral ID-%@ Time Stamp -%@",Identifier,[[SharedData sharedConstants] currentDate]];

        [[logfile logfileObj] writeLog:logValue];
#endif
    }
    
}


/*!
 *  @method centralManagerStateToString:
 *
 *  @param state State to print info of
 *
 *  @discussion centralManagerStateToString prints information text about a given CBCentralManager state
 *
 */
- (const char *) centralManagerStateToString: (int)state{
    switch(state)
    {
        case CBCentralManagerStateUnknown:
            return "State unknown (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateResetting:
            return "State resetting (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateUnsupported:
            return "State BLE unsupported (CBCentralManagerStateResetting)";
        case CBCentralManagerStateUnauthorized:
            return "State unauthorized (CBCentralManagerStateUnauthorized)";
        case CBCentralManagerStatePoweredOff:
            return "State BLE powered off (CBCentralManagerStatePoweredOff)";
        case CBCentralManagerStatePoweredOn:
            return "State powered up and ready (CBCentralManagerStatePoweredOn)";
        default:
            return "State unknown";
    }
    return "Unknown state";
}

/*!
 *  @method scanTimer:
 *
 *  @param timer Backpointer to timer
 *
 *  @discussion scanTimer is called when findBLEPeripherals has timed out, it stops the CentralManager from scanning further and prints out information about known peripherals
 *
 */
- (void) scanTimer:(NSTimer *)timer {
    //[self.CM stopScan];
    // printf("Stopped Scanning\r\n");
    printf("Known peripherals : %lu\r\n",(unsigned long)[self->peripherals count]);
    [self printKnownPeripherals];
}

/*!
 *  @method printKnownPeripherals:
 *
 *  @discussion printKnownPeripherals prints all curenntly known peripherals stored in the peripherals array of TIBLECBKeyfob class
 *
 */
- (void) printKnownPeripherals
{
    int i;
    NSLog(@"count %lu",(unsigned long)self->peripherals.count);
    for (i=0; i < self->peripherals.count; i++)
    {
        CBPeripheral *p = [self->peripherals objectAtIndex:i];
        CFStringRef s = CFUUIDCreateString(NULL, (__bridge CFUUIDRef)(p.identifier));
        printf("%d  |  %s\r\n",i,CFStringGetCStringPtr(s, 0));
        
    }
}

/*
 *  @method printPeripheralInfo:
 *
 *  @param peripheral Peripheral to print info of
 *
 *  @discussion printPeripheralInfo prints detailed info about peripheral
 *
 */
- (void) printPeripheralInfo:(CBPeripheral*)peripheral {
    
    
    CFStringRef s = CFUUIDCreateString(NULL, (__bridge CFUUIDRef)(peripheral.identifier));
    printf("------------------------------------\r\n");
    printf("Peripheral Info :\r\n");
    printf("UUID : %s\r\n",CFStringGetCStringPtr(s, 0));
    //printf("RSSI : %d\r\n",[peripheral.RSSI intValue]);
    NSLog(@"Name : %@\r\n",peripheral.name);
    NSLog(@"Name : %@\r\n",s);
    // printf("isConnected : %d\r\n",peripheral.isConnected);
    printf("-------------------------------------\r\n");
    
}

/*
 *  @method UUIDSAreEqual:
 *
 *  @param u1 CFUUIDRef 1 to compare
 *  @param u2 CFUUIDRef 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compares two CFUUIDRef's
 *
 */

- (int) UUIDSAreEqual:(CFUUIDRef)u1 u2:(CFUUIDRef)u2 {
    CFUUIDBytes b1 = CFUUIDGetUUIDBytes(u1);
    CFUUIDBytes b2 = CFUUIDGetUUIDBytes(u2);
    if (memcmp(&b1, &b2, 16) == 0) {
        return 1;
    }
    else return 0;
}


/*
 *  @method getAllServicesFromKeyfob
 *
 *  @param p Peripheral to scan
 *
 *
 *  @discussion getAllServicesFromKeyfob starts a service discovery on a peripheral pointed to by p.
 *  When services are found the didDiscoverServices method is called
 *
 */
-(void) getAllServicesFromKeyfob:(CBPeripheral *)p{
    [BLEDeviceConnectbtn setTitle:@"Discovering services.." forState:UIControlStateNormal];
    [p discoverServices:nil]; // Discover all services without filter
}

/*
 *  @method getAllCharacteristicsFromKeyfob
 *
 *  @param p Peripheral to scan
 *
 *
 *  @discussion getAllCharacteristicsFromKeyfob starts a characteristics discovery on a peripheral
 *  pointed to by p
 *
 */
-(void) getAllCharacteristicsFromKeyfob:(CBPeripheral *)p{
    
    NSLog(@"p  serv %@",p.services);
    for (int i=0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        NSLog(@"service %@,service uuid %@",s,s.UUID);
        printf("Fetching characteristics for service with UUID : %s\r\n",[self CBUUIDToString:s.UUID]);
        [p discoverCharacteristics:nil forService:s];
    }
    
}


/*
 *  @method CBUUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion CBUUIDToString converts the data of a CBUUID class to a character pointer for easy printout using printf()
 *
 */
-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}


/*
 *  @method UUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion UUIDToString converts the data of a CFUUIDRef class to a character pointer for easy printout using printf()
 *
 */
-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
    
}

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

/*
 *  @method compareCBUUIDToInt
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UInt16 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUIDToInt compares a CBUUID to a UInt16 representation of a UUID and returns 1
 *  if they are equal and 0 if they are not
 *
 */
-(int) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2 {
    char b1[16];
    [UUID1.data getBytes:b1 length:16];
    UInt16 b2 = [self swap:UUID2];
    if (memcmp(b1, (char *)&b2, 2) == 0) return 1;
    else return 0;
}
/*
 *  @method CBUUIDToInt
 *
 *  @param UUID1 UUID 1 to convert
 *
 *  @returns UInt16 representation of the CBUUID
 *
 *  @discussion CBUUIDToInt converts a CBUUID to a Uint16 representation of the UUID
 *
 */
-(UInt16) CBUUIDToInt:(CBUUID *) UUID {
    char b1[16];
    [UUID.data getBytes:b1 length:16];
    return ((b1[0] << 8) | b1[1]);
}

/*
 *  @method IntToCBUUID
 *
 *  @param UInt16 representation of a UUID
 *
 *  @return The converted CBUUID
 *
 *  @discussion IntToCBUUID converts a UInt16 UUID to a CBUUID
 *
 */

-(CBUUID *) IntToCBUUID:(UInt16)UUID {
    char t[16];
    t[0] = ((UUID >> 8) & 0xff); t[1] = (UUID & 0xff);
    NSData *data = [[NSData alloc] initWithBytes:t length:16];
    return [CBUUID UUIDWithData:data];
}


/*
 *  @method findServiceFromUUID:
 *
 *  @param UUID CBUUID to find in service list
 *  @param p Peripheral to find service on
 *
 *  @return pointer to CBService if found, nil if not
 *
 *  @discussion findServiceFromUUID searches through the services list of a peripheral to find a
 *  service with a specific UUID
 *
 */
-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p data:(NSData *)data {
    
    //[p.services containsObject:[CBUUID UUIDWithString:BLE_KEYPRESS_SERVICE_UUID]];
    for(int i = 0; i < p.services.count; i++)
    {
        CBService *s = [p.services objectAtIndex:i];
        UInt16 characteristicUUID = [self CBUUIDToInt:s.UUID];
        
        //Buz value data for enable fall and key press
        char buzVal=0x06;
        NSData *buzdata = [[NSData alloc] initWithBytes:&buzVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
        
        //Acknowledge byte for fall detect/key press
        char fallVal=0x01;
        NSData *falldata = [[NSData alloc] initWithBytes:&fallVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
        
        //Byte for find me ,keypress enable
        char soundVal=0x02;
        NSData *sounddata = [[NSData alloc] initWithBytes:&soundVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
        
        //Normal mode for puck ,cancel acknowledge for fall detect/keypress
        char normalmodeVal=0x00;
        NSData *normalmodedata = [[NSData alloc] initWithBytes:&normalmodeVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
        
        //Silent mode enable data for puck
        char silentmodeVal=0x03;
        NSData *silentmodedata = [[NSData alloc] initWithBytes:&silentmodeVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
        
        if ([s.UUID isEqual:[CBUUID UUIDWithString:BLE_KEYPRESS_SERVICE_UUID]] && ([data isEqualToData:buzdata]  || [ data isEqualToData:sounddata]) && [SharedData sharedConstants].normalMode !=1 && [SharedData sharedConstants].fallMode ==1)
        {
            //If write value to fall enable
            return s;
        }
        else if([s.UUID isEqual:[CBUUID UUIDWithString:BLE_KEYPRESS_SERVICE_UUID]] && ([data isEqualToData:falldata]  || [ data isEqualToData:normalmodedata]) && [SharedData sharedConstants].normalMode ==1)
        {
            //If Normal mode write to puck
            return s;
        }
        else if([s.UUID isEqual:[CBUUID UUIDWithString:BLE_KEYPRESS_SERVICE_UUID]]  && [SharedData sharedConstants].verifyMode ==1)
        {
            //If write verify mode to puck
            return s;
        }
        else if ([s.UUID isEqual:[CBUUID UUIDWithString:BLE_KEYPRESS_SERVICE_UUID]] && ([data isEqualToData:silentmodedata] || [data isEqualToData:normalmodedata]) &&  [SharedData sharedConstants].readMac !=1 )
        {
            //If write silent mode to puck
            return s;
        }
        else if([s.UUID isEqual:[CBUUID UUIDWithString:BLE_ENABLE_ACCEL_SERVICE_UUID]] && [data isEqualToData:falldata] && [SharedData sharedConstants].normalMode !=1)
        {
            return s;
        }
        else if(characteristicUUID ==NOTIFY_ALERT_UUID && [data isEqualToData:sounddata] && [SharedData sharedConstants].fallMode !=1)
        {
            //If write sound buzz(find me) to puck
            return s;
        }
        else if([s.UUID isEqual:[CBUUID UUIDWithString:SERVICE_ADJUST_CONNECTION_INTERVAL]] && [SharedData sharedConstants].adjustMode ==1)
        {
            //If write adjust connection to puck
            return s;
        }
        else if([s.UUID isEqual:[CBUUID UUIDWithString:BLE_KEYPRESS_SERVICE_UUID]] && [SharedData sharedConstants].adjustMode !=1 && [SharedData sharedConstants].readMac ==1 )
        {
            //If write value to read mac address.
            return s;
        }
        else if(characteristicUUID ==NOTIFY_BATT_SERVICE_UUID && [SharedData sharedConstants].readBtry ==1)
        {
            //If write value to read battery
            return s;
        }
        else if(characteristicUUID ==NOTIFY_SERVICE_DEVICE_INFO && [SharedData sharedConstants].notifyserialSoft ==1)
        {
            //If write value  to read software version.
            return s;
        }
        else if(characteristicUUID ==NOTIFY_SERVICE_DEVICE_INFO && [SharedData sharedConstants].readSoftver ==1)
        {
            //If write value to notify device info
            return s;
        }
        else if([self compareCBUUID:s.UUID UUID2:UUID] && data ==nil)
        {
            return s;
        }
    }
    return nil; //Service not found on this peripheral
}

-(CBService *) notifyfindServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p {
    
    
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([s.UUID isEqual:[CBUUID UUIDWithString:BLE_FALL_KEYPRESS_SERVICE_UUID]] )  {
            NSLog(@"VSN Service");
            return s;
        }
        else if ([self compareCBUUID:s.UUID UUID2:UUID])
        {return s;
        }
    }
    return nil; //Service not found on this peripheral
}

/*
 *  @method findCharacteristicFromUUID:
 *
 *  @param UUID CBUUID to find in Characteristic list of service
 *  @param service Pointer to CBService to search for charateristics on
 *
 *  @return pointer to CBCharacteristic if found, nil if not
 *
 *  @discussion findCharacteristicFromUUID searches through the characteristic list of a given service
 *  to find a characteristic with a specific UUID
 *
 */
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service data:(NSData *)data {
    for(int i=0; i < service.characteristics.count; i++)
    {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        
        //Buz value data for enable fall and key press
        char buzVal=0x06;
        NSData *buzdata = [[NSData alloc] initWithBytes:&buzVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
        
        //Acknowledge byte for fall detect/key press
        char fallVal=0x01;
        NSData *falldata = [[NSData alloc] initWithBytes:&fallVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
        
        //Byte for find me and keypress enable
        char soundVal=0x02;
        NSData *sounddata = [[NSData alloc] initWithBytes:&soundVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
        UInt16 characteristicUUID = [self CBUUIDToInt:c.UUID];
        
        //Normal mode for puck ,cancel acknowledge for fall detect/keypress
        char normalmodeVal=0x00;
        NSData *normalmodedata = [[NSData alloc] initWithBytes:&normalmodeVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
        
        //Silent mode enable data for puck
        char silentmodeVal=0x03;
        NSData *silentmodedata = [[NSData alloc] initWithBytes:&silentmodeVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
        
        
        if ([c.UUID isEqual:[CBUUID UUIDWithString:BLE_KEYPRESS_DETECTION_UUID]] && ([data isEqualToData:buzdata]  || [ data isEqualToData:sounddata]) && [SharedData sharedConstants].normalMode !=1 && [SharedData sharedConstants].fallMode ==1)
        {
            //If write value to fall enable
            return c;
        }
        else if([c.UUID isEqual:[CBUUID UUIDWithString:BLE_KEYPRESS_FALLDETECT_ACK]] && ([data isEqualToData:falldata] || [data isEqualToData:normalmodedata]) && [SharedData sharedConstants].normalMode ==1)
        {
            //If Normal mode write to puck
            [SharedData sharedConstants].normalMode =0;
            return c;
        }
        else if([c.UUID isEqual:[CBUUID UUIDWithString:BLE_KEYPRESS_FALLDETECT_NORMAL]]   && [SharedData sharedConstants].verifyMode ==1)
        {
            //If write verify mode to puck
            [SharedData sharedConstants].verifyMode =0;
            return c;
        }
        else  if ([c.UUID isEqual:[CBUUID UUIDWithString:BLE_SILENT_NORMAL_MODE]]  && ([data isEqualToData:silentmodedata] || [data isEqualToData:normalmodedata]) && [SharedData sharedConstants].normalMode !=1 && [SharedData sharedConstants].verifyMode !=1)
        {
            NSLog(@"VSN Service");
            return c;
        }
        else if([c.UUID isEqual:[CBUUID UUIDWithString:BLE_ENABLE_ACCEL_DETECTION_UUID]] && [data isEqualToData:falldata] && [SharedData sharedConstants].normalMode !=1 )
        {
            return c;
        }
        
        else if(characteristicUUID == NOTIFY_ALERT_CHAR_UUID && [data isEqualToData:sounddata] && [SharedData sharedConstants].fallMode !=1)
        {
            //If write sound buzz(find me) to puck
            return c;
        }
        else if([c.UUID isEqual:[CBUUID UUIDWithString:CHAR_ADJUST_CONNECTION_INTERVAL]] && [SharedData sharedConstants].adjustMode ==1)
        {
            //If write adjust connection to puck
            [SharedData sharedConstants].adjustMode =0;
            return c;
        }
        else if([c.UUID isEqual:[CBUUID UUIDWithString:BLE_MAC_ADDR_CHAR]] && [SharedData sharedConstants].adjustMode !=1 && [SharedData sharedConstants].readMac==1)
        {
            //If write value to read mac address.
            [SharedData sharedConstants].readMac =0;
            return c;
        }
        else if(characteristicUUID ==NOTIFY_SERVICE_UUID &&[SharedData sharedConstants].readBtry ==1)
        {
            //If write value to read battery
            [SharedData sharedConstants].readBtry =0;
            return c;
        }
        else if(characteristicUUID ==NOTIFY_CHAR_SERIAL_NUMBER   && [SharedData sharedConstants].notifyserialSoft ==1)
        {
            //[SharedData sharedConstants].notifyserialSoft =0;
            return c;
        }
        else if(characteristicUUID ==NOTIFY_CHAR_SOFTWARE_REV  && [SharedData sharedConstants].readSoftver ==1)
        {
            //If write value  to read software version.
            return c;
        }
        else if([self compareCBUUID:c.UUID UUID2:UUID] && data ==nil)
        {
            return c;
        }
        // if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}
/*
 *  @method notifyfindCharacteristicFromUUID:
 *
 *  @param UUID CBUUID to find in service list
 *  @param p Peripheral to find service on
 *
 *  @return pointer to CBService if found, nil if not
 *
 *  @discussion notifyfindCharacteristicFromUUID searches through the services list of a peripheral to find a
 *  service with a specific UUID
 */


-(CBCharacteristic *) notifyfindCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++)
    {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([c.UUID isEqual:[CBUUID UUIDWithString:BLE_FALL_KEYPRESS_DETECTION_UUID]])
        {
            return c;
        }
        else if ([self compareCBUUID:c.UUID UUID2:UUID])
        {
            return c;
        }
    }
    return nil; //Characteristic not found on this service
}

//----------------------------------------------------------------------------------------------------
//
//
//
//
//CBCentralManagerDelegate protocol methods beneeth here
// Documented in CoreBluetooth documentation
//
//
//
//
//----------------------------------------------------------------------------------------------------


/*
 *  @method peripheralManagerDidUpdateState:
 *
 *  @param p Peripheral to find service on
 *
 *
 *  @discussion peripheralManagerDidUpdateState update the state of the connected peripherals
 */

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSDictionary *advData =
    @{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:@"1802"]]};
    [peripheral startAdvertising:advData];
}


/*
 *  @method centralManagerDidUpdateState:
 *
 *  @param p Peripheral to find service on
 *
 *
 *  @discussion centralManagerDidUpdateState update the state of the  peripherals whether the device is in connected state or notconnected
 Here we are cancelling the peripheral if bluetooth is off state (because sometimes diddisconnect delegate will not automatically
 Here in else condition if the bluetooth is in on state we started scanning the peripherals to connect
 */
#pragma mark - Bluetooth Connected/Disconnected
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
    
    if(central.state == CBCentralManagerStatePoweredOff)
    {
        
        [self localnotify:NSLocalizedString(@"bluetooth_action", nil) deviceStatus:NSLocalizedString(@"bluetooth_diabled", nil)];
        [DEFAULTS setValue:@"off" forKey:@"Bluetooth"];
        [DEFAULTS setValue:@"off" forKey:@"BluetoothStatus"]; // Tracker : Set Flag to know BlueTooth get Connected/Disconnected Just Now
        for(int i=0;i<[SharedData sharedConstants].arrActivePeripherals.count;i++)
        {
            
            [self.CM cancelPeripheralConnection:[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:i]];
            [self centralManager:self.CM didDisconnectPeripheral:[[SharedData sharedConstants].arrActivePeripherals objectAtIndex:i] error:Nil];
        }
        
    }
    else if(central.state == CBCentralManagerStatePoweredOn)
    {
        // If not connected then scan else reconnect
        if(![DEFAULTS boolForKey:IS_CONNECTED] || [[SharedData sharedConstants].arrActivePeripherals count] == 0){
            NSDictionary *options = @{
                                  CBCentralManagerScanOptionAllowDuplicatesKey:[NSNumber numberWithBool:YES]
                                  };
            [self.CM scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"1802"]] options:options];
            [DEFAULTS setValue:@"on" forKey:@"Bluetooth"];
            [DEFAULTS setValue:@"off" forKey:@"BluetoothStatus"]; // Tracker : Set Flag to know BlueTooth get Connected/Disconnected Just Now
        
            //Disconnect the tracker timer
            [disconnectedTimer invalidate];
        
        } else if ([[SharedData sharedConstants].arrActivePeripherals count] > 0){
            // Already connected so reconnect
            [activePeripheral discoverServices:nil];
            [DEFAULTS setValue:@"on" forKey:@"Bluetooth"];
            [DEFAULTS setValue:@"on" forKey:@"BluetoothStatus"]; // Tracker : Set Flag to know BlueTooth get Connected/Disconnected Just Now
            [disconnectedTimer invalidate];
        }
    }
}

/*
 *  @method didDiscoverPeripheral:
 *
 *  @param p Peripheral to find service on
 *
 *
 *  @discussion didDiscoverPeripheral discover all the ble peripherals in a range and filter only the valert devices
 */

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    NSData *dataRepresentingSavedArray = [DEFAULTS objectForKey:BLE_DISCOVERED_UUIDS];
    NSArray *defaultUUIDS = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
    if (defaultUUIDS != nil)
    {
        [SharedData sharedConstants].arrDiscovereUUIDs = [[NSMutableArray alloc] initWithArray:defaultUUIDS];
    }
    

    //Log the saved uuid and current uuid
    if([[SharedData sharedConstants].arrDiscovereUUIDs count]>0)
    {
        
#ifdef __LOG_FILE__
#ifdef HNALERT
        NSString*uuiDName = [NSString stringWithFormat:@"saved-uuid-%@-name-%@",[[SharedData sharedConstants].arrDiscovereUUIDs objectAtIndex:0],[peripheral.name stringByReplacingOccurrencesOfString:@"V.ALRT" withString:@"HN-ALERT"]];
        NSString*currenuuiDName = [NSString stringWithFormat:@"current-uuid-%@-name-%@",[peripheral.identifier UUIDString],[peripheral.name stringByReplacingOccurrencesOfString:@"V.ALRT" withString:@"HN-ALERT"]];

#else
        
#endif
        NSString*uuiDName = [NSString stringWithFormat:@"saved-uuid-%@-name-%@",[[SharedData sharedConstants].arrDiscovereUUIDs objectAtIndex:0],peripheral.name];
        NSString*currenuuiDName = [NSString stringWithFormat:@"current-uuid-%@-name-%@",[peripheral.identifier UUIDString],peripheral.name];
        [[logfile logfileObj] writeLog:logValue];

        [[logfile logfileObj]  writeLog:uuiDName];
        [[logfile logfileObj]  writeLog:currenuuiDName];
#endif
        NSArray*periper;
        if([[SharedData sharedConstants].arrDiscovereUUIDs count]>0 && [[SharedData sharedConstants].arrDiscovereUUIDs isKindOfClass:[NSMutableArray class]])
        {
          
            //If the device is already paired and not in connected state
            if([[[SharedData sharedConstants].arrDiscovereUUIDs objectAtIndex:0] isKindOfClass:[NSString class]])
            {
                periper=  [self.CM retrievePeripheralsWithIdentifiers:[NSArray arrayWithObject:[CBUUID UUIDWithString:[[SharedData sharedConstants].arrDiscovereUUIDs objectAtIndex:0] ]]];
                //@For ios 10@For ios 10
                //@comment - Not able to retreive the peripheral using identifier so we just compare the scanned peripherial identifier with the stored identifier
                if([[peripheral.identifier UUIDString] isEqualToString:[[SharedData sharedConstants].arrDiscovereUUIDs objectAtIndex:0]]){
                    periper = [NSArray arrayWithObject:peripheral];
                }
            }
            else
            {
                
                periper=  [self.CM retrievePeripheralsWithIdentifiers:[NSArray arrayWithObject:[CBUUID UUIDWithString:[[[SharedData sharedConstants].arrDiscovereUUIDs objectAtIndex:0] UUIDString]]]];
                //@For ios 10
                //@comment - Not able to retreive the peripheral using identifier so we just compare the scanned peripherial identifier with the stored identifier
                if([[peripheral.identifier UUIDString] isEqualToString:[[[SharedData sharedConstants].arrDiscovereUUIDs objectAtIndex:0] UUIDString]]){
                    periper = [NSArray arrayWithObject:peripheral];
                }
            }
             
            
        }
        if([periper count]>0)
        {
            CBPeripheral*retrPer = [periper objectAtIndex:0];
            if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF] && retrPer.state ==0)
            {
                [self connectPeripheral:[periper objectAtIndex:0]];
            }
        }
        
    }
    else
    {
        
        NSUUID *uiid = peripheral.identifier;
#ifdef HNALERT
        NSLog(@"uuid-%@ and name-%@",peripheral.identifier,[peripheral.name stringByReplacingOccurrencesOfString:@"V.ALRT" withString:@"HN-ALERT"]);
#else
        NSLog(@"uuid-%@ and name-%@",peripheral.identifier,peripheral.name);
#endif
        
        if (![[SharedData sharedConstants].arrDiscovereUUIDs containsObject:[uiid UUIDString]])
        {
            if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
            {

                BOOL containlocalname = [[SharedData sharedConstants] ContainValue:localName];
                BOOL containPeripheralname = [[SharedData sharedConstants] ContainValue:peripheral.name];

                if (![[SharedData sharedConstants].arrAvailableIdentifiers containsObject:peripheral.identifier] && peripheral.name !=nil && ![peripheral.name isEqualToString:@""] && peripheral.name.length !=0 && peripheral.name.length !=0 && (containlocalname||containPeripheralname))
                {
                    
                    [[SharedData sharedConstants].arrAvailableIdentifiers addObject:peripheral.identifier];
                    if(![[SharedData sharedConstants].arrPeriperhalNames containsObject:peripheral])
                    {
                        [[SharedData sharedConstants].arrPeriperhalNames addObject:peripheral];
                    }
                    NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
                    strID = [strID substringFromIndex: [strID length] - 20];
                    
                    if (localName.length == 0 || [localName isEqual:[NSNull null]] || [localName isEqualToString:@""])
                    {
                        if([peripheral.name isEqualToString:@""] || [peripheral.name isEqual:[NSNull null]] )
                        {
#ifdef HNALERT
                            [DEFAULTS setObject:@"HNALERT" forKey:strID];
#else
                            [DEFAULTS setObject:@"Vsnvalert" forKey:strID];
#endif
                        }
                        else
                        {
#ifdef HNALERT
                            [DEFAULTS setObject:[peripheral.name stringByReplacingOccurrencesOfString:@"V.ALRT" withString:@"HN-ALERT"] forKey:strID];

#else
                            [DEFAULTS setObject:peripheral.name forKey:strID];
#endif
                        }
                    }
                    else
                    {
#ifdef HNALERT
                        localName = [localName stringByReplacingOccurrencesOfString:@"V.ALRT" withString:@"HN-ALERT"];
#endif
                        [DEFAULTS setObject:localName forKey:strID];
                    }
                    [DEFAULTS synchronize];
                }
            }
        }
        else
        {
            //Connect the peripheral if already the peripheral is in paired device(but in disconnected state)
            if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
            {
                // [self connectPeripheral:peripheral];
            }
        }
    }
    
}

/*
 *  @method didDisconnectPeripheral:
 *
 *  @param p Peripheral to find service on
 *
 *
 *  @discussion didDisconnectPeripheral the delegate method will call once the device has been disconnected.
 */

#pragma mark - Periferal Device Disconnected

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    NSLog(@"Disconnect");
    NSLog(@"Error: %@", error);
    [self findBLEPeripherals:5];
    
    //Set bool to no to specify the puck is disconnected
    [DEFAULTS setBool:NO forKey:IS_CONNECTED];
    
    if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
    {
        
        //Get the peripheral id from identifier
        peripheralID = [NSString stringWithFormat:@"%@",peripheral.identifier];
        peripheralID = [peripheralID substringFromIndex: [peripheralID length] - 20];
        // Tracker : Set The CurrentPeriferalID to use in another file
        [DEFAULTS setValue:peripheralID forKey:CURRENTPERIFERALID];
        [DEFAULTS synchronize];
        
        
        //Notify the user about the disconnected state of the peripheral
        //@discussion - Biren - only show the local notification if we have fully connected
        NSLog(@"Biren Did disconnect *************");
        if (![DEFAULTS boolForKey:IS_DEVICE_REMOVED])
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                disconnectedTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                     target:self
                                                                   selector:@selector(dealaynotifyForDisconnect)
                                                                   userInfo:nil
                                                                    repeats:NO];
            }];
        }
        else
        {
            isFullyConnected = NO;
        }
        [DEFAULTS synchronize];
        
        
        //Notify to device dashboard to change the name od the device to disconnect
        NSMutableDictionary*statedict = [[NSMutableDictionary alloc]init];
        [statedict setObject:peripheralID forKey:@"identifier"];
        [[SharedData sharedConstants].laststateIdentifiers setObject:[NSString stringWithFormat:@"%ld",(long)peripheral.state] forKey:peripheral.identifier];
        //Notify the state change to the device dashboard page
        [[NSNotificationCenter defaultCenter] postNotificationName:@"statechange" object:nil userInfo:statedict];
    }
    else
    {
        isFullyConnected = NO;
    }
}

/*
 *  @method willRestoreState:
 *
 *  @param p Peripheral to find service on
 *
 *
 *  @discussion willRestoreState the delegate method will call once the system terminate the app
 Here wake up the app and search the available device and try to connect.
 */
- (void)centralManager:(CBCentralManager *)central
      willRestoreState:(NSDictionary *)state
{
    
    NSLog(@"Will restore state");
    NSLog(@"active-%@",state[CBCentralManagerRestoredStatePeripheralsKey]);
    self.activePeripheral = [state[CBCentralManagerRestoredStatePeripheralsKey] objectAtIndex:0] ;
    self.activePeripheral.delegate = self;
    //check active peripheral is not nil and array count to 0
    if(activePeripheral !=nil && [SharedData sharedConstants].arrActivePeripherals.count ==0)
    {
        [[SharedData sharedConstants].arrActivePeripherals addObject:activePeripheral];
        [[SharedData sharedConstants].laststateIdentifiers setObject:[NSString stringWithFormat:@"%ld",(long)activePeripheral.state] forKey:activePeripheral.identifier];
    }
    //@discussion – added by ed to reconnect device after restoration
    if(activePeripheral != nil)
    {
        [activePeripheral discoverServices:nil];
#ifdef __LOG_FILE__
        //@log to check the issue
        NSString*logValue = [NSString stringWithFormat:@"will restore state-Time Stamp -%@",[[SharedData sharedConstants] currentDate]];

        [[logfile logfileObj] writeLog:logValue];

#endif
    }
    
}

/*
 *  @method didConnectPeripheral:
 *
 *  @param p Peripheral to find service on
 *
 *
 *  @discussion didConnectPeripheral the delegate method will call once the device has been connected
 Here we save all the connected device in a array and notify the connected device to the user.
 */

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    printf("Connection to peripheral with UUID : %s successfull\r\n",[self UUIDToString:(__bridge CFUUIDRef)(peripheral.identifier)]);
    
    //Stop the scan
    // [self.CM stopScan];
    self.activePeripheral = peripheral;
    [self.activePeripheral discoverServices:nil];
    
    //Stop the scan
    [central stopScan];
    
    //Set bool to yes to specify the puck is disconnected
    [DEFAULTS setBool:YES forKey:IS_CONNECTED];
    
    
    //Disconnect the timer and set bool to yes for  Valert_Immediate_Triggered
    //@discussion -so if it in normal disconnect the tracker will popup ,set bool to no in switch off in home view to avoid the track popup when you switch off.
    [disconnectedTimer invalidate];
    [DEFAULTS setBool:YES forKey:Valert_Immediate_Triggered];
    [DEFAULTS synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"statechange" object:nil userInfo:nil];
    //Save the last state of the device@connected/connecting
    [[SharedData sharedConstants].laststateIdentifiers setObject:[NSString stringWithFormat:@"%ld",(long)peripheral.state] forKey:peripheral.identifier];
}

//----------------------------------------------------------------------------------------------------
//
//
//
//
//
//CBPeripheralDelegate protocol methods beneeth here
//
//
//
//
//
//----------------------------------------------------------------------------------------------------


/*
 *  @method didDiscoverCharacteristicsForService
 *
 *  @param peripheral Pheripheral that got updated
 *  @param service Service that characteristics where found on
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverCharacteristicsForService is called when CoreBluetooth has discovered
 *  characteristics on a service, on a peripheral after the discoverCharacteristics routine has been called on the service
 *
 */

#pragma mark - Periferal Device Connected
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        printf("Characteristics of service with UUID : %s found\r\n",[self CBUUIDToString:service.UUID]);
        for(int i=0; i < service.characteristics.count; i++) {
            CBCharacteristic *c = [service.characteristics objectAtIndex:i];
            printf("Found characteristic %s\r\n",[ self CBUUIDToString:c.UUID]);
            CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
            if([self compareCBUUID:service.UUID UUID2:s.UUID])
            {
                printf("Finished discovering characteristics");
                [DEFAULTS setBool:NO forKey:IS_DEVICE_REMOVED];
                [DEFAULTS synchronize];
                
                //Write all values to the puck
                [[self delegate] keyfobReady];
                
                
                //@discussion - Ashok - where is the entry point for this class?
                if(isFullyConnected == NO )
                {
                    [DEFAULTS setBool:YES forKey:Valert_Immediate_Triggered];
                    [DEFAULTS synchronize];
                    //Add connected status to the database
                    //Add device name.status to the db
                    NSString *_date=[[SharedData sharedConstants] currentDate];
                    dConnect = [[dbConnect alloc]init];
                    //insert the device connection status
                    NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
                    strID = [strID substringFromIndex: [strID length] - 20];
                    [[UIApplication sharedApplication] cancelAllLocalNotifications];
                    // Tracker : Hide the Tracker in Progress and Post Notification and Log The History Also
                    if ([DEFAULTS boolForKey:IS_DEVICE_TRAKING_FEATURE_ON])
                    {
                        if ([[DEFAULTS valueForKey:@"ShowPopUp"] isEqualToString:@"0"] )
                        {
                            [DEFAULTS setValue:@"1" forKey:@"ShowPopUp"];
                            //cancel the repeatnotifyForTracker perform selector if puck is connected
                            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(repeatnotifyForTracker) object:nil];
                            [[self delegate] deviceConnectedAgain];
                            
                        }
                    }
                    //Add status to the database ie, puck is connected
                    [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:[DEFAULTS objectForKey:strID] bleAddress:strID bleStatus:NSLocalizedString(@"connected", nil)];
                    
                    //Write device information to the database.
                    NSString*deviceName = [DEFAULTS objectForKey:strID];
                    [dConnect adddeviceinfo:[SharedData sharedConstants].strserialNumber  bleName:deviceName bleAddress:strID softwarever:[SharedData sharedConstants].strSofwareVer];
                    // Do something
                    [self localnotify:NSLocalizedString(@"V.ALRT", nil) deviceStatus:NSLocalizedString(@"connected", nil)];
                    [disconnectedTimer invalidate];
                    isFullyConnected = YES;
                }
                break;
            }
        }
        
    }
    else {
        printf("Characteristic discorvery unsuccessfull !\r\n");
    }
}


//Retrieve the connected peripherals
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)retrieveperipherals {
    
    NSLog(@"didRetrieveConnectedPeripherals");
    if([SharedData sharedConstants].arrActivePeripherals.count ==0)
    {
        //[[SharedData sharedConstants].arrActivePeripherals addObject:[retrieveperipherals objectAtIndex:0]];
    }
}
- (NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDS
{
    return serviceUUIDS;
}


//Periperal for advertising data
-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    
    
}

/*
 *  @method didDiscoverServices
 *
 *  @param peripheral Pheripheral that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverServices is called when CoreBluetooth has discovered services on a
 *  peripheral after the discoverServices routine has been called on the peripheral
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        printf("Services of peripheral with UUID : %s found\r\n",[self UUIDToString:(__bridge CFUUIDRef)(peripheral.identifier)]);
        [self getAllCharacteristicsFromKeyfob:peripheral];
    }
    else {
        printf("Service discovery was unsuccessfull !\r\n");
    }
}

/*
 *  @method didUpdateNotificationStateForCharacteristic
 *
 *  @param peripheral Pheripheral that got updated
 *  @param characteristic Characteristic that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didUpdateNotificationStateForCharacteristic is called when CoreBluetooth has updated a
 *  notification state for a characteristic
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        printf("Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:(__bridge CFUUIDRef)(peripheral.identifier)]);
    }
    else {
        printf("Error in setting notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:(__bridge CFUUIDRef)(peripheral.identifier)]);
        printf("Error code was %s\r\n",[[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    }
}

/*
 *  @method didUpdateValueForCharacteristic
 *
 *  @param peripheral Pheripheral that got updated
 *  @param characteristic Characteristic that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didUpdateValueForCharacteristic is called when CoreBluetooth has updated a
 *  characteristic for a peripheral. All reads and notifications come here to be processed.
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
    if (!error) {
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_FALL_KEYPRESS_DETECTION_UUID]])
        {
            char data = 0x01;
            NSData *d = [[NSData alloc] initWithBytes:&data length:1];
            [SharedData sharedConstants].normalMode = 1;
            [self writeValue:BLE_KEYPRESS_SERVICE_UUID characteristicUUID:BLE_KEYPRESS_FALLDETECT_ACK p:peripheral data:d];
            
            char keys;
            [characteristic.value getBytes:&keys length:TI_KEYFOB_KEYS_NOTIFICATION_READ_LEN];
            char buzVal=0x04;
            NSData *buzdata = [[NSData alloc] initWithBytes:&buzVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
            //Get UUId
            NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
            if ([characteristic.value isEqualToData:buzdata] )
            {
                if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
                {
                    [self getDeviceInfo:strID];
                    [[self delegate] fallDetectValuesUpdated:peripheral];
                }
                
            }
            else
            {
                if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
                {
                    [self getDeviceInfo:strID];
                    [[self delegate] keyValuesUpdated: peripheral];
                }
            }
            //write value to acknowledge fall detect and keypress
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:BLE_MAC_ADDR_CHAR]])
        {
            
            //Add the device info to the table
            dConnect = [[dbConnect alloc]init];
            //insert the device connection status
            NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
            strID = [strID substringFromIndex: [strID length] - 20];
            NSString *value = [NSString stringWithUTF8String:[characteristic.value  bytes]];
            [dConnect updatedeviceinfo:@"macId" value:value mac:strID];
            
        }
        else
        {
            switch(characteristicUUID)
            {
                    
                case NOTIFY_SERVICE_UUID:
                {
                    char batlevel;
                    [characteristic.value getBytes:&batlevel length:10];
                    self.batteryLevel = (float)batlevel;
                    [SharedData sharedConstants].strBatteryLevelStatus= [NSString stringWithFormat:@"%f",self.batteryLevel];
                    //Add the battery status  to the table
                    dConnect = [[dbConnect alloc]init];
                    NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
                    strID = [strID substringFromIndex: [strID length] - 20];
                    [dConnect addBatteryStatus:strID batteryPercent:[SharedData sharedConstants].strBatteryLevelStatus];
                    [[self delegate] getCurrentBatteryStatus:peripheral];
                    break;
                }
                case NOTIFY_CHAR_SERIAL_NUMBER:
                {
                    NSString *value = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
                    [SharedData sharedConstants].strserialNumber = value;
                    //Add the device info to the table
                    dConnect = [[dbConnect alloc]init];
                    //insert the device connection status
                    NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
                    strID = [strID substringFromIndex: [strID length] - 20];
                    value = [NSString stringWithUTF8String:[characteristic.value  bytes]];
                    [dConnect updatedeviceinfo:@"serialno" value:value mac:strID];
                    break;
                }
                case NOTIFY_CHAR_REV:
                {
                    NSString *value = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
                    [SharedData sharedConstants].strSofwareVer = value;
                    //Add the device info to the table
                    dConnect = [[dbConnect alloc]init];
                    //insert the device connection status
                    NSString *strID = [NSString stringWithFormat:@"%@",peripheral.identifier];
                    strID = [strID substringFromIndex: [strID length] - 20];
                    value = [NSString stringWithUTF8String:[characteristic.value  bytes]];
                    [dConnect updatedeviceinfo:@"softwarever" value:value mac:strID];
                    break;
                }
                    
                case NOTIFY_NOTIFICATION_UUID:
                {
                    char keys;
                    [characteristic.value getBytes:&keys length:TI_KEYFOB_KEYS_NOTIFICATION_READ_LEN];
                    if (keys & 0x01) self.key1 = YES;
                    else self.key1 = NO;
                    if (keys & 0x02) self.key2 = YES;
                    else self.key2 = NO;
                    [[self delegate] keyValuesUpdated: peripheral];
                    break;
                }
                case NOTIFY_PROXIMITY_TX_PWR_NOTIFICATION_UUID:
                {
                    char TXLevel;
                    [characteristic.value getBytes:&TXLevel length:TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_READ_LEN];
                    self.TXPwrLevel = TXLevel;
                }
                case 0xFFF0:
                {
                    char fallDetect;
                    [characteristic.value getBytes:&fallDetect length:BLE_FALL_DETECTION_BYTE];
                    NSLog(@"Fall Detected %c",fallDetect);
                    break;
                }
            }
        }
    }
    else {
        printf("updateValueForCharacteristic failed!");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
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
    //@TODO Try to write the value again or disconnect the puck
    NSLog(@"error-%@",[error localizedDescription]);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
}


/**
 *  Read RSSI Value
 *
 *  @param peripheral peripheral  that got updated
 *  @param RSSI       rssi value of the connected device
 *  @param error      if errro to read rssi value
 */
-(void) peripheral:(CBPeripheral *)peripheral
       didReadRSSI:(NSNumber *)RSSI
             error:(NSError *)error
{
    
    [SharedData sharedConstants].strSignalStregnthstatus = [RSSI stringValue];
    
}

/*
 *  @method didRetrievePeripherals
 *
 *  @param peripheral Pheripheral that got updated
 *
 *  @discussion didRetrievePeripherals is reterieve the known Pheripherals
 *
 */

- (void) centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *) retperipherals{
    
    
    
    NSLog(@"retperipherals %@",retperipherals);
    
}


#pragma mark - Post Local Notifocation
//Send local notification when the device is disconnected/conneted/otherstatus
-(void)localnotify:(NSString *)deviceName deviceStatus:(NSString *)deviceStatus
{
    if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
    {
        // Remove previous notifications
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllDeliveredNotifications];
        
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        // Tracker : Check all the conditions for Tracker and sound and for bluetooth
        if (![[DEFAULTS valueForKey:@"BluetoothStatus"] isEqualToString:@"off"] )
        {
            
            localNotification.alertBody = [NSString stringWithFormat:@"%@ %@ %@",deviceName, NSLocalizedString(@"is", nil) , deviceStatus];
            if([DEFAULTS boolForKey:IS_DEVICE_TRAKING_FEATURE_ON] && [deviceName isEqualToString:@"V.ALRT"] && ![deviceStatus isEqualToString:NSLocalizedString(@"connected", nil)])
            {
                if ([DEFAULTS boolForKey:DEVICE_TRAKING_SOUND])
                {
                    localNotification.soundName = @"Siren_noise.wav";
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ( ([[UIApplication sharedApplication]applicationState] != UIApplicationStateActive))
                        {
                            //@Discussion-As per Biren requirement(Requirement- every 5sec need to throw disconnect notification) changed the delay to 5.0
                            [self performSelector:@selector(repeatnotifyForTracker) withObject:nil afterDelay:5.0];
                            
                        }
                    });
                }
            }
            else
            {
                if (![[DEFAULTS valueForKey:SHOWINGDISCONNECTEDDEVICEPOPUP] isEqualToString:@"ShowingYES"]  && ![DEFAULTS boolForKey:DEVICE_TRAKING_SOUND])
                {
                    if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
                    {
                        localNotification.soundName = UILocalNotificationDefaultSoundName;
                    }
                }
            }
        }
        else
        {
            localNotification.alertBody = [NSString stringWithFormat:@"%@ %@ %@",deviceName, NSLocalizedString(@"is", nil), deviceStatus];
            if (![[DEFAULTS valueForKey:SHOWINGDISCONNECTEDDEVICEPOPUP] isEqualToString:@"ShowingYES"]  && ![DEFAULTS boolForKey:DEVICE_TRAKING_SOUND] )
            {
                if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
                {
                    localNotification.soundName = UILocalNotificationDefaultSoundName;
                }
            }
        }
        
        [DEFAULTS setObject:@"on" forKey:@"BluetoothStatus"];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        [DEFAULTS synchronize];
    }
}




//Tracker : Repeat notification for Tracker
-(void)repeatnotifyForTracker
{
    if ((isFullyConnected == NO) && ([[UIApplication sharedApplication]applicationState] != UIApplicationStateActive))
    {
        [self localnotify:NSLocalizedString(@"V.ALRT", nil) deviceStatus:NSLocalizedString(@"disconnected", nil)];
    }
}



/*
 *  @method getDeviceInfo
 *
 *  @param peripheral Pheripheral that got updated
 *
 *  @discussion getDeviceInfo is get the device info from the database.
 *
 */
-(void) getDeviceInfo:(NSString *)deviceId
{
    deviceId = [deviceId substringFromIndex: [deviceId length] - 20];
    dConnect = [[dbConnect alloc]init];
    NSMutableDictionary*deviceInfo = [[NSMutableDictionary alloc]init];
    deviceInfo = [[dConnect getDeviceInfo:deviceId] mutableCopy];
    [SharedData sharedConstants].activeSerialno = [deviceInfo valueForKey:@"serialno"];
    [SharedData sharedConstants].activeIdentifier = [deviceInfo valueForKey:@"macid"];
    
}

/*
 *  @method dealaynotifyForDisconnect
 *
 *  @param peripheral Pheripheral that got updated
 *
 *  @discussion dealaynotifyForDisconnect is called after 5 seconds of disconnect and here we again check right now puck is in  connected or not if not in connected then throw disconnect notification.
 *
 */
-(void)dealaynotifyForDisconnect
{
    if(isFullyConnected == YES )
    {
        isFullyConnected = NO;
        [disconnectedTimer invalidate];
        
        NSString *_date=[[SharedData sharedConstants] currentDate];
        dConnect = [[dbConnect alloc]init];
        
        // Tracker : Fire Tracker in Progress view and Notification and Log History also
        if ( ![[DEFAULTS valueForKey:@"Bluetooth"]isEqualToString:@"off"] && ( [[DEFAULTS objectForKey:@"KeyPressed"] integerValue]  == 0) && [DEFAULTS boolForKey:IS_DEVICE_TRAKING_FEATURE_ON] && ( [[DEFAULTS objectForKey:@"FallDetecct"] integerValue]  == 0) &&  [DEFAULTS boolForKey:Valert_Immediate_Triggered] && [SharedData sharedConstants].arrActivePeripherals.count >0)
        {
            //@Discussion-What is the use of this boolean?
            [DEFAULTS setValue:@"0" forKey:@"ShowPopUp"];
            [[self delegate] deviceDisconnected];
        }
        else
        {
            [[SharedData sharedConstants] checkDisconnectdevice];
        }
        
        //insert device connection status to database
        [dConnect addStatus:[NSString stringWithFormat:@"%@",_date] bleName:[DEFAULTS objectForKey:peripheralID] bleAddress:peripheralID bleStatus:NSLocalizedString(@"disconnected", nil)];
    }
}
@end
