#import <Foundation/Foundation.h>
#import <Foundation/NSTask.h>

static NSString *clearCache = @"/var/mobile/Library/Caches/syslogclear";
static NSString *logPath = @"/var/log/syslog";
static NSString *filePath = @"/etc/syslog.conf";
static BOOL syslogEnabled;
static BOOL iOS8() {
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/LaunchDaemons/com.apple.syslogd.plist"]) {
        return YES;
    }
    return NO;
}

int main(int argc, char **argv, char **envp) {
    @autoreleasepool {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        NSData *data = [fileHandle readDataToEndOfFile];
        NSString *str = [[NSString alloc]initWithData:data
                                             encoding:NSUTF8StringEncoding];
        syslogEnabled = [str hasPrefix:@"*.* /var/log/syslog"];
        [fileHandle closeFile];
        
        NSTask *task1 = [[NSTask alloc] init];
        [task1 setLaunchPath: @"/bin/launchctl"];
        // iOS 8
        NSArray *unload8 = [NSArray arrayWithObjects: @"unload", @"/Library/LaunchDaemons/com.apple.syslogd.plist", nil];
        
        NSTask *task2 = [[NSTask alloc] init];
        [task2 setLaunchPath: @"/bin/launchctl"];
        
        NSArray *load8 = [NSArray arrayWithObjects: @"load", @"/Library/LaunchDaemons/com.apple.syslogd.plist", nil];
        // iOS 7 or less
        NSArray *unload = [NSArray arrayWithObjects: @"unload", @"/System/Library/LaunchDaemons/com.apple.syslogd.plist", nil];
        NSArray *load = [NSArray arrayWithObjects: @"load", @"/System/Library/LaunchDaemons/com.apple.syslogd.plist", nil];
        
        NSString *str1 = @"#*.* /var/log/syslog\n";
        NSString *str2 = @"*.* /var/log/syslog\n";
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        if ([manager removeItemAtPath:clearCache error:nil]) {
            [manager removeItemAtPath:logPath error:nil];
            
            [str1 writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            if (iOS8() || kCFCoreFoundationVersionNumber >= 1140.10) {
                [task1 setArguments:unload8];
                [task1 launch];
                
                [NSThread sleepForTimeInterval:0.8f];
                
                [task2 setArguments:load8];
                [task2 launch];
            } else {
                [task1 setArguments:unload];
                [task1 launch];
                
                [task2 setArguments:load];
                [task2 launch];
            }
            
        } else if ([manager removeItemAtPath:filePath error:nil]) {
            [manager createFileAtPath:filePath contents:nil attributes:nil];
            
            if (syslogEnabled) {
                [str1 writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                if (iOS8() || kCFCoreFoundationVersionNumber >= 1140.10) {
                    [task1 setArguments:unload8];
                    [task1 launch];
                    
                    [NSThread sleepForTimeInterval:0.8f];
                    
                    [task2 setArguments:load8];
                    [task2 launch];
                } else {
                    [task1 setArguments:unload];
                    [task1 launch];
                    
                    [task2 setArguments:load];
                    [task2 launch];
                }
                
            } else {
                [str2 writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                if (iOS8() || kCFCoreFoundationVersionNumber >= 1140.10) {
                    [task1 setArguments:unload8];
                    [task1 launch];
                    
                    [NSThread sleepForTimeInterval:0.8f];
                    
                    [task2 setArguments:load8];
                    [task2 launch];
                } else {
                    [task1 setArguments:unload];
                    [task1 launch];
                    
                    [task2 setArguments:load];
                    [task2 launch];
                }
            }
        }
    }
    return 0;
}