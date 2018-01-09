//
//  BluetoothConstants.h
//  VSNConnect
//
//  Created by Ed Gilmore on 8/12/14.
//  Copyright (c) 2014 Ed Gilmore - Onn, Inc. All rights reserved.
//  www.onncreative.com
//

#import <Foundation/Foundation.h>

#ifndef TI_BLE_Demo_TIBLECBKeyfobDefines_h
#define TI_BLE_Demo_TIBLECBKeyfobDefines_h

#define TI_KEYFOB_PROXIMITY_ALERT_UUID                      @"0x1802"
#define TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID             @"0x2a06"
#define TI_KEYFOB_PROXIMITY_ALERT_ON_VAL                    0x01
#define TI_KEYFOB_PROXIMITY_ALERT_OFF_VAL                   0x00
#define TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN                 1
#define TI_KEYFOB_PROXIMITY_TX_PWR_SERVICE_UUID             @"0x1804"
#define TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID        @"0x2A07"
#define TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_READ_LEN    1

#define TI_KEYFOB_BATT_SERVICE_UUID                         @"0x180F"
#define TI_KEYFOB_LEVEL_SERVICE_UUID                        @"0x2A19"
#define TI_KEYFOB_LEVEL_SERVICE_READ_LEN                    1

#define TI_KEYFOB_ACCEL_SERVICE_UUID                        @"0xFFA0"
#define TI_KEYFOB_ACCEL_ENABLER_UUID                        @"0xFFA1"
#define TI_KEYFOB_ACCEL_RANGE_UUID                          0xFFA2
#define TI_KEYFOB_ACCEL_READ_LEN                            1
#define TI_KEYFOB_ACCEL_X_UUID                              @"0xFFA3"
#define TI_KEYFOB_ACCEL_Y_UUID                              @"0xFFA4"
#define TI_KEYFOB_ACCEL_Z_UUID                              @"0xFFA5"

//For m3 devices
#define TI_KEYFOB_KEYS_SERVICE_UUID                         @"0xFFE0"
#define TI_KEYFOB_KEYS_NOTIFICATION_UUID                    @"0xFFE1"
#define TI_KEYFOB_KEYS_NOTIFICATION_READ_LEN                00

#define BLE_FALL_DETECTION_SERVICE_UUID                      @"0xFFF0"
#define BLE_FALL_DETECTION_UUID                              @"0xFFF2"
#define BLE_FALL_DETECTION_BYTE                              1

#define BLE_FALL_SERVICE_UUID                           @"0xFFF0"
#define BLE_DETECTION_UUID                              @"0xFFF4"



#define BLE_VSN_GATT_SERVICE_UUID        @"fffffff0-00f7-4000-b000-000000000000" //Vsn Gatt service

#define BLE_SILENT_NORMAL_MODE           @"fffffff1-00f7-4000-b000-000000000000" //Stealth mode Characteristic
#define BLE_KEYPRESS_DETECTION_UUID      @"fffffff2-00f7-4000-b000-000000000000" //Notification characteristic for Keypress
#define BLE_KEYPRESS_FALLDETECT_ACK      @"fffffff3-00f7-4000-b000-000000000000" //Acknowledge characteristic for keypress & fall detect.
#define BLE_FALL_KEYPRESS_DETECTION_UUID @"fffffff4-00f7-4000-b000-000000000000" //Notification characteristic for fall detect
#define BLE_VERIFICATION_SERVICE_UUID    @"fffffff5-00f7-4000-b000-000000000000" //V.BTTN Verification Characteristic
#define BLE_MAC_ADDR_CHAR                @"fffffff8-00f7-4000-b000-000000000000" //Read mac address Characteristic




#define BLE_ENABLE_ACCEL_SERVICE_UUID   @"ffffffA0-00f7-4000-b000-000000000000"//Not used
#define BLE_ENABLE_ACCEL_DETECTION_UUID @"ffffffA1-00f7-4000-b000-000000000000"//Not used







//Connection Control service
#define SERVICE_ADJUST_CONNECTION_INTERVAL @"ffffccc0-00f7-4000-b000-000000000000"//Service for adjust connection control for 1.5 sec
#define CHAR_ADJUST_CONNECTION_INTERVAL    @"ffffccc2-00f7-4000-b000-000000000000"//Characteristic for adjust connection control for 1.5 sec

#define TRANSFER_CHARACTERISTIC_UUID    @"EB6727C4-F184-497A-A656-76B0CDAC633A"

#define SERVICE_DEVICE_INFO     @"0x180A"
#define CHAR_SERIAL_NUMBER     @"0x2A25"
#define CHAR_SOFTWARE_REV     @"0x2A28"


#define NOTIFY_BATT_SERVICE_UUID                         0x180F
#define NOTIFY_SERVICE_DEVICE_INFO             0x180A
#define NOTIFY_CHAR_SERIAL_NUMBER              0x2A25
#define NOTIFY_CHAR_SOFTWARE_REV              0x2A28
#define NOTIFY_ALERT_CHAR_UUID             0x2a06
#define NOTIFY_ALERT_UUID 0x1802
#define NOTIFY_CHAR_REV 0x2A28
#define NOTIFY_SERVICE_UUID                        0x2A19
#define NOTIFY_CHAR_SERIAL_NUMBER     0x2A25
#define NOTIFY_NOTIFICATION_UUID                    0xFFE1
#define NOTIFY_ACCEL_X_UUID                              0xFFA3
#define NOTIFY_ACCEL_Y_UUID                              0xFFA4
#define NOTIFY_ACCEL_Z_UUID                              0xFFA5
#define NOTIFY_PROXIMITY_TX_PWR_NOTIFICATION_UUID        0x2A07

#endif



@interface BluetoothConstants : NSObject

@end
