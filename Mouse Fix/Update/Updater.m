//
// --------------------------------------------------------------------------
// Updater.m
// Created for: Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by: Noah Nuebling in 2019
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import "Updater.h"
#import "UpdateWindow.h"
#import "../PrefPaneDelegate.h"
#import "../MoreSheet/MoreSheet.h"
#import "../Config/ConfigFileInterface_PrefPane.h"



@interface Updater ()
@end

@implementation Updater

# pragma mark - Class Properties

static NSURL *_baseRemoteURL;

static NSURLSessionDownloadTask *_downloadTask1;
static NSURLSessionDownloadTask *_downloadTask2;
static NSURLSession *_downloadSession;
static UpdateWindow *_windowController;
static NSInteger _availableVersion;
static NSURL *_updateLocation;
static NSURL *_updateNotesLocation;

# pragma mark - Class Methods

+(void)load {
    _baseRemoteURL = [NSURL URLWithString:@"https://mousefix.org/maindownload/"];
//    _baseRemoteURL = [NSURL fileURLWithPath:@"/Users/Noah/Documents/GitHub/Mac-Mouse-Fix-Website/maindownload"];
}

+ (void)setupDownloadSession {
    
    NSURLSessionConfiguration *downloadSessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration;
        downloadSessionConfiguration.allowsCellularAccess = NO;
        if (@available(macOS 10.13, *)) {
            downloadSessionConfiguration.waitsForConnectivity = YES;
        }
    _downloadSession = [NSURLSession sessionWithConfiguration:downloadSessionConfiguration];
}

+ (void)reset {
    [_windowController close];
    
    [_downloadTask1 cancel];
    _downloadTask1 = nil;
    [_downloadTask2 cancel];
    _downloadTask2 = nil;
    [_downloadSession invalidateAndCancel];
}

+ (void)checkForUpdate {
    
//    [MoreSheet endMoreSheetAttachedToMainWindow];
    
    NSLog(@"checking for update...");
    
    // TODO: make sure this works (on a slow connection)
    [self reset];
    
    [self setupDownloadSession];
    
    // clean up before starting the update procedure again
    
    _downloadTask1 = [_downloadSession downloadTaskWithURL:[_baseRemoteURL URLByAppendingPathComponent:@"/bundleversion"] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != NULL){
            NSLog(@"checking for updates failed");
            NSLog(@"Error: \n%@", error);
            return;
        }
        NSInteger currentVersion = [[[NSBundle bundleForClass:self] objectForInfoDictionaryKey:@"CFBundleVersion"] integerValue];
        _availableVersion = [[NSString stringWithContentsOfURL:location encoding:NSUTF8StringEncoding error:NULL] integerValue];
        NSLog(@"currentVersion: %ld, availableVersion: %ld", (long)currentVersion, (long)_availableVersion);
        NSInteger skippedVersion = [[ConfigFileInterface_PrefPane.config valueForKeyPath:@"Other.skippedBundleVersion"] integerValue];
        if (currentVersion < _availableVersion && _availableVersion != skippedVersion) {
            [self downloadAndPresent];
        } else {
            NSLog(@"Not downloading update. Either no new version available or available version has been skipped");
        }
    }];
    [_downloadTask1 resume];
}
+ (void)downloadAndPresent {
}
    

+ (void)presentUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        _windowController = [UpdateWindow alloc];
        _windowController = [_windowController init];
        [_windowController startWithUpdateNotes:_updateNotesLocation];
        
        [_windowController showWindow:nil];
        [_windowController.window makeKeyAndOrderFront:nil];
//        [NSApplication.sharedApplication beginModalSessionForWindow:_windowController.window];
        
    });
}

+ (void)skipAvailableVersion {
    [ConfigFileInterface_PrefPane.config setValue:@(_availableVersion) forKeyPath:@"Other.skippedBundleVersion"];
    [ConfigFileInterface_PrefPane writeConfigToFile];
}

+ (void)update {
}

@end
