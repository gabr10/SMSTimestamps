BOOL soDoWeOrNot;
unsigned int whatDidWeSelect;
NSDictionary *prefs;
NSDate *oldDate;
NSDate *lastDisplayed;


static void LoadSettings() { 
    prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.gabriobarbieri.SMSTimestamps.plist"];	
    soDoWeOrNot = (BOOL)[[prefs objectForKey:@"SwitchCell5"] boolValue];
    whatDidWeSelect = [[prefs objectForKey:@"LinkListCell7"] intValue];
	[prefs release];
}

static void SettingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	LoadSettings();
	}

static BOOL CheckForDifference(NSDate *date, int lapse){
    if(oldDate == nil){//should happen upon the first table load.
        oldDate = date;
        lastDisplayed = date;
        
        return YES;
    }else{//means this is not the first one, do our thang.
        NSDate *thisMsg = date;
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *components = [gregorianCalendar components:unitFlags
                                                        fromDate:lastDisplayed
                                                          toDate:thisMsg
                                                         options:0];
                                                         
    int c = [components minute];
    [gregorianCalendar release];
    oldDate = date;
    
        if(c >=lapse){
        lastDisplayed = date;
            return YES;
        }else{
        
        return NO;}
        
    }

}

%hook CKTranscriptBubbleData



- (BOOL)_shouldShowTimestampForDate:(id)arg1{
    LoadSettings();
    if(!soDoWeOrNot) {
       return %orig(arg1);
    }
    switch (whatDidWeSelect) {
        case 1:
            return YES;
        case 2:
            return CheckForDifference(arg1, 1);
        case 3:
            return CheckForDifference(arg1, 5);
        case 4:
            return CheckForDifference(arg1, 10);
        default:
            return YES;
            
    }
}



%end

%hook CKTranscriptController

- (void)viewWillDisappear:(BOOL)arg1{
    oldDate = nil;
    %orig(arg1);
}
- (void)viewDidDisappear:(BOOL)arg1{
    oldDate = nil;
    %orig(arg1);
}

%end


%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	%init;
	LoadSettings();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, SettingsChanged, CFSTR("com.gabriobarbieri.SMSTimestamps-preferencesChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	[pool drain];
}