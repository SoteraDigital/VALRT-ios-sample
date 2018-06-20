/**
 *dbConnect.h
 *
 * This class database  connect function and is used to insert,delete,update records in the database
 * @category   Contus
 * @package    com.vsnmobil.valrt
 * @version    1.1
 * @author     Contus Team <developers@contus.in>
 * @copyright  Copyright (C) 2014 Contus. All rights reserved.
 
 */

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface dbConnect : NSObject {


	NSString *databaseName;
	NSString *documentsDir;
	NSString *documentsPath;
    NSString *idValue;
    NSString *date;
    NSString *deviceName;
	NSString *macaddr;
    NSString *status;
    NSString *softvers;
    NSString *serialno;
    NSString*macId;
    
	sqlite3 *database;
}

-(void)openDB;
-(void)verifyDatabase:(NSString *)dbName databasePath:(NSString *)dbPath;
-(void)addStatus:(NSString *)bledate bleName:(NSString *)bleName  bleAddress:(NSString *)bleAddress bleStatus:(NSString *)bleStatus;
-(void)adddeviceinfo:(NSString *)bleserialno bleName:(NSString *)bleName bleAddress:(NSString *)bleAddress softwarever:(NSString *)softwarever;
-(NSMutableArray *)fetchTable;
-(void)deleteDeviceInfo:(NSString *)StrId;
-(void)updatedeviceinfo:(NSString *)fieldName value:(NSString *)Value mac:(NSString *)StrId;
-(void)updatestatus:(NSString *)fieldName value:(NSString *)FieldValue mac:(NSString *)StrId;
-(void)addfallenableDevice:(NSString *)bleaddress bleFlag:(NSString *)bleFlag;
-(int)checkfallenableDevice:(NSString *)address;
-(void)addBatteryStatus:(NSString *)bleaddress batteryPercent:(NSString *)batteryPercent;
-(int)getBattertyStatus:(NSString *)address;
-(NSMutableDictionary *) getDeviceInfo:(NSString *)deviceId;
-(NSMutableArray *)fetchDeviceinfo;
@end
