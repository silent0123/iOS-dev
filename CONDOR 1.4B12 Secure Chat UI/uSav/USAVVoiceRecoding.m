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
    self.recordedTmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"aac"]]];
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
    
    [self.avPlayer prepareToPlay];
    [self.avPlayer play];
    
}

- (void)endPlay {
    
    if (self.avPlayer) {
        [self.avPlayer stop];
    }
}

@end
