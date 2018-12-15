//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <android_intent/AndroidIntentPlugin.h>
#import <flutter_picker/FlutterPickerPlugin.h>
#import <shared_preferences/SharedPreferencesPlugin.h>

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FLTAndroidIntentPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTAndroidIntentPlugin"]];
  [FlutterPickerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterPickerPlugin"]];
  [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
}

@end
