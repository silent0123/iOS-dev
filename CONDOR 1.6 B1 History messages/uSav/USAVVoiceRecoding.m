//
//  USAVVoiceRecoding.m
//  CONDOR
//
//  Created by Luca on 23/3/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import "USAVVoiceRecoding.h"

@implementation USAVVoiceRecoding


- (USAVVoiceRecoding *)initWithAudioSession {

    self.audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];
    
    return self;
}

#pragma mark - Record
- (NSURL *)startRecord {
    
    NSError *error;
    
    if (!self.audioSession) {
    
        [self initWithAudioSession];
    
    }
        
    [self.audioSession setActive:YES error: &error];
    
    //Set up the recording info
    NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];   //format
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];   //sample rate
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];  //recording channels
    
    //Set up the recording file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM_dd_yyyy_HH_mm_ss"];
    NSString *filename = [dateFormatter stringFromDate:[NSDate date]];
    
    self.recordedTmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat:@"/Voice_%@.m4a", filename]]];
    NSLog(@"Using Recording File called: %@", self.recordedTmpFile);
    
    //Set up a recorder to use this file
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.recordedTmpFile settings:recordSetting error:&error];
    
    if (error) {
        NSLog(@"Error while recording: %@", error);
        return nil;
    }
    
    [self.recorder setDelegate:self];
    [self.recorder prepareToRecord];
    [self.recorder record];

    return self.recordedTmpFile;
    
}
- (void)endRecord {
    
    if (!self.audioSession) {
        
        [self initWithAudioSession];
        
    }
        
    if (self.recorder) {
        
        [self.recorder stop];
        
    } else {
        NSLog(@"Recorder not exists");
    }
}

- (void)cancelRecord {
    
    [self.recorder stop];
    
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtURL:self.recordedTmpFile error:&error];
    
    if (error) {
        NSLog(@"Error while canceling: %@", error);
        return;
    }
    
}
#pragma mark - Play

- (void)startPlay: (NSURL *)url {
    
    NSError *error;
    self.avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (error) {
        NSLog(@"Error while playing: %@", error);
        return;
    }
    
    [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.avPlayer prepareToPlay];
    [self.avPlayer play];
    
}

- (void)endPlay {
    
    if (self.avPlayer) {
        [self.avPlayer stop];
    }
}

@end
