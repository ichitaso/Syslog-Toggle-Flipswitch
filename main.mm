#import <Foundation/Foundation.h>
#import <Foundation/NSTask.h>

static NSString *clearCache = @"/var/mobile/Library/Caches/syslogclear";
static NSString *logPath = @"/var/log/syslog";
static NSString *filePath = @"/etc/syslog.conf";
static BOOL syslogEnabled;

int main(int argc, char **argv, char **envp) {
    @autoreleasepool {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        NSData *data = [fileHandle readDataToEndOfFile];
        NSString *str = [[NSString alloc]initWithData:data
                                             encoding:NSUTF8StringEncoding];
        syslogEnabled = [str hasPrefix:@"*.* /var/log/syslog"];
        [fileHandle closeFile];
        
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath: @"/bin/launchctl"];
        NSArray *unload = [NSArray arrayWithObjects: @"unload", @"/System/Library/LaunchDaemons/com.apple.syslogd.plist", nil];
        NSArray *load = [NSArray arrayWithObjects: @"load", @"/System/Library/LaunchDaemons/com.apple.syslogd.plist", nil];
        
        NSString *str1 = @"#*.* /var/log/syslog\n";
        NSString *str2 = @"*.* /var/log/syslog\n";
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        if ([manager removeItemAtPath:clearCache error:nil]) {
            [manager removeItemAtPath:logPath error:nil];
            
            [str1 writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            [task setArguments:unload];
            [task launch];
            
            [task setArguments:load];
            [task launch];
        } else if ([manager removeItemAtPath:filePath error:nil]) {
            [manager createFileAtPath:filePath contents:nil attributes:nil];
            
            if (syslogEnabled) {
                [str1 writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                [task setArguments:unload];
                [task launch];
                
                [task setArguments:load];
                [task launch];
            } else {
                [str2 writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                [task setArguments:load];
                [task launch];
            }
        }
    }
    
    return 0;
}