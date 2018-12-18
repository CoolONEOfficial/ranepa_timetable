//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <android_intent/AndroidIntentPlugin.h>
#import <device_calendar/DeviceCalendarPlugin.h>
#import <shared_preferences/SharedPreferencesPlugin.h>

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FLTAndroidIntentPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTAndroidIntentPlugin"]];
  [DeviceCalendarPlugin registerWithRegistrar:[registry registrarForPlugin:@"DeviceCalendarPlugin"]];
  [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
}

@end
