#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"

static NSString *logPath = @"/var/log/syslog";
static NSString *filePath = @"/etc/syslog.conf";
static BOOL syslogEnabled;

@interface SyslogToggleSwitch : NSObject <FSSwitchDataSource>
@end

@implementation SyslogToggleSwitch

- (id)init
{
	if ((self = [super init])) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        NSData *data = [fileHandle readDataToEndOfFile];
        NSString *str = [[NSString alloc]initWithData:data
                                             encoding:NSUTF8StringEncoding];
        syslogEnabled = [str hasPrefix:@"*.* /var/log/syslog"];
        [fileHandle closeFile];
	}
	return self;
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	return syslogEnabled;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
	if (newState == FSSwitchStateIndeterminate)
		return;
    
    syslogEnabled = newState;
    
    system("/Library/Switches/SyslogToggle.bundle/syslogsw");
}

- (void)applyAlternateActionForSwitchIdentifier:(NSString *)switchIdentifier
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *attribute = [fm attributesOfItemAtPath:logPath error:nil];
    NSNumber *fileSize = [attribute objectForKey:NSFileSize];
    float num = [fileSize floatValue];
    num /= 1028;
    NSString *logSize = [[NSString alloc] initWithFormat:@"%.0f KB",roundf(num)];
    
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:@"Logfile Size\nLocation: /var/log/syslog"
                               message:logSize
                              delegate:self
                     cancelButtonTitle:@"Dismiss"
                     otherButtonTitles:@"Clear File",nil];
    [alert show];
    [alert release];
    
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {//Dismiss
    } else if (buttonIndex == 1) {
        system("touch /var/mobile/Library/Caches/syslogclear");
        system("/Library/Switches/SyslogToggle.bundle/syslogsw");
        syslogEnabled = NO;
    }
}

@end