#import <substrate.h>
BOOL soDoWeOrNot;
BOOL chopSecondsOff;
NSUInteger whatDidWeSelect;
NSDictionary *prefs;

static void LoadSettings() { 
    prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.gabriobarbieri.SMSTimestamps.plist"];	
    soDoWeOrNot = (BOOL)[[prefs objectForKey:@"SwitchCell5"] boolValue];
    whatDidWeSelect = [[prefs objectForKey:@"LinkListCell7"] intValue];
    chopSecondsOff = (BOOL)[[prefs objectForKey:@"SwitchCell8"] boolValue];
	[prefs release];
}

static void SettingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	LoadSettings();
}

static NSDate* chopSeconds(NSDate *date) {
    NSDateComponents *time = [[NSCalendar currentCalendar] components:NSSecondCalendarUnit
    						                                 fromDate:date];
    NSInteger seconds = [time second];
    NSDate *choped = [date dateByAddingTimeInterval:(-1*seconds)];
    return choped;
}

static NSDate* nextEligible(NSDate *date, int minutes) {
    NSDate *from = (chopSecondsOff) ? [chopSeconds(date) retain] : [date copy];
    NSDate *eligableDate = [from dateByAddingTimeInterval:(60 * minutes)];
    [from release];
    return eligableDate;
}

%hook CKTranscriptBubbleData

- (void)_setupNextEligibleTimestamp:(id)timestamp{
    if(!soDoWeOrNot) {
       return %orig(timestamp);
    }
    
    MSIvarHook(NSDate *, _nextEligibleTimestamp);
    [_nextEligibleTimestamp release];

    switch (whatDidWeSelect) {
        case 2:
            _nextEligibleTimestamp = nextEligible(timestamp, 1);
            break;
        case 3:
            _nextEligibleTimestamp = nextEligible(timestamp, 5);
            break;
        case 4:
            _nextEligibleTimestamp = nextEligible(timestamp, 10);
            break;
        case 1:
        default:
            _nextEligibleTimestamp = nextEligible(timestamp, 0);
    }
    
    [_nextEligibleTimestamp retain];
}

%end

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	%init;
	LoadSettings();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, SettingsChanged, CFSTR("com.gabriobarbieri.SMSTimestamps-preferencesChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	[pool drain];
}