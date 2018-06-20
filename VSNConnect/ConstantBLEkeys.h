/**
 * ConstantBLEkeys.h
 *
 * This class contains constant the constant keys
 * @category   Contus
 * @package    com.vsnmobil.valrt
 * @version    1.1
 * @author     Contus Team <developers@contus.in>
 * @copyright  Copyright (C) 2014 Contus. All rights reserved.
 
 */
#import <Foundation/Foundation.h>

#ifndef TI_BLE_Demo_TIBLECBKeyfobDefines_h
#define TI_BLE_Demo_TIBLECBKeyfobDefines_h

#define TI_KEYFOB_PROXIMITY_ALERT_UUID                      @"0x1802"//Find me Service
#define TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID             @"0x2a06"//Find me Characteristic
#define TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN                 1
#define TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_READ_LEN    1

#define TI_KEYFOB_BATT_SERVICE_UUID                         @"0x180F"//Battery read service
#define TI_KEYFOB_LEVEL_SERVICE_UUID                        @"0x2A19"//Battery read characteristic
#define TI_KEYFOB_LEVEL_SERVICE_READ_LEN                    1



//For m3 devices
#define TI_KEYFOB_KEYS_NOTIFICATION_READ_LEN                00

#define BLE_FALL_DETECTION_SERVICE_UUID                      @"0xFFF0"//Write service for fall enable
#define BLE_FALL_DETECTION_UUID                              @"0xFFF2"//Write characteristic for fall enable
#define BLE_FALL_DETECTION_BYTE                              1

#define BLE_FALL_SERVICE_UUID                           @"0xFFF0"//Notify service for fall enable
#define BLE_DETECTION_UUID                              @"0xFFF4"//Notify Characteristic for fall enable

#define BLE_FALL_KEYPRESS_DETECTION_UUID  @"fffffff4-00f7-4000-b000-000000000000"//Notification characteristic for fall detect

#define BLE_FALL_KEYPRESS_SERVICE_UUID @"fffffff0-00f7-4000-b000-000000000000"//Stealth mode service,Accelerometer Service

#define BLE_ENABLE_ACCEL_SERVICE_UUID @"ffffffA0-00f7-4000-b000-000000000000"//Not used

#define BLE_ENABLE_ACCEL_DETECTION_UUID @"ffffffA1-00f7-4000-b000-000000000000"//Not used

#define BLE_KEYPRESS_DETECTION_UUID @"fffffff2-00f7-4000-b000-000000000000"//Notification characteristic for Keypress

#define BLE_KEYPRESS_SERVICE_UUID @"fffffff0-00f7-4000-b000-000000000000"//Vsn Gatt service

#define BLE_KEYPRESS_FALLDETECT_ACK @"fffffff3-00f7-4000-b000-000000000000"//Acknowledge characteristic for keypress and fall detect.

#define BLE_KEYPRESS_FALLDETECT_NORMAL @"fffffff5-00f7-4000-b000-000000000000"//V.BTTN Verification Characteristic

#define BLE_SILENT_NORMAL_MODE @"fffffff1-00f7-4000-b000-000000000000"//Stealth mode Characteristic

#define BLE_MAC_ADDR_CHAR @"fffffff8-00f7-4000-b000-000000000000"//Read mac address Characteristic

//Connection Control service
#define SERVICE_ADJUST_CONNECTION_INTERVAL @"ffffccc0-00f7-4000-b000-000000000000"//Service for adjust connection control for 1.5 sec
#define CHAR_ADJUST_CONNECTION_INTERVAL @"ffffccc2-00f7-4000-b000-000000000000"//Characteristic for adjust connection control for 1.5 sec

#define TRANSFER_CHARACTERISTIC_UUID    @"EB6727C4-F184-497A-A656-76B0CDAC633A"

#define SERVICE_DEVICE_INFO     @"0x180A"//read Service to get device information
#define CHAR_SERIAL_NUMBER     @"0x2A25"//read Characteristic to get serial number
#define CHAR_SOFTWARE_REV     @"0x2A28"//read Characteristic to get software version


//Notify For Device information starts
#define NOTIFY_BATT_SERVICE_UUID                         0x180F
#define NOTIFY_SERVICE_DEVICE_INFO             0x180A
#define NOTIFY_CHAR_SERIAL_NUMBER              0x2A25
#define NOTIFY_CHAR_SOFTWARE_REV              0x2A28
//Notify for device information ends
#define NOTIFY_ALERT_CHAR_UUID             0x2a06//Notify characterstic for sound buzz(find me)
#define NOTIFY_ALERT_UUID 0x1802//Notify service for sound buzz(find me)
#define NOTIFY_CHAR_REV 0x2A28//Notify from puck for software version
#define NOTIFY_SERVICE_UUID                        0x2A19//Notify from puck for battery level
#define NOTIFY_CHAR_SERIAL_NUMBER     0x2A25//Notify from puck for serial number
#define NOTIFY_NOTIFICATION_UUID                    0xFFE1//Notify from puck for keypress 
#define NOTIFY_PROXIMITY_TX_PWR_NOTIFICATION_UUID        0x2A07//Notify from puck for proximity

#endif


@interface ConstantBLEkeys : NSObject

@end
