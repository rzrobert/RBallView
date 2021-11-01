#import "Flutter3dBallPlugin.h"
#if __has_include(<flutter_3d_ball/flutter_3d_ball-Swift.h>)
#import <flutter_3d_ball/flutter_3d_ball-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_3d_ball-Swift.h"
#endif

@implementation Flutter3dBallPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutter3dBallPlugin registerWithRegistrar:registrar];
}
@end
