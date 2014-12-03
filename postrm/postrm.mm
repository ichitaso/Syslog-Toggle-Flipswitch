#import <Foundation/Foundation.h>

int main(int argc, const char *argv[]) {
    if (argc < 2 || (
        strcmp(argv[1], "abort-install") != 0 &&
        strcmp(argv[1], "remove") != 0 &&
    true)) return 0;
    
    @autoreleasepool {
        NSString *lPath = @"/Library/LaunchDaemons/com.apple.syslogd.plist";
        NSString *sPath = @"/System/Library/LaunchDaemons/com.apple.syslogd.plist";
        BOOL isFirmware8_1_x = (kCFCoreFoundationVersionNumber >= 1141.16) ? YES : NO;
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        if (isFirmware8_1_x && [manager fileExistsAtPath:lPath] && [manager fileExistsAtPath:sPath]) {
            [manager removeItemAtPath:lPath error:nil];
        }
    }
    return 0;
}