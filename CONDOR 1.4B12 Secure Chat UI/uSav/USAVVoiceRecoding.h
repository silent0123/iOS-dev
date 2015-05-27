//
//  USAVVoiceRecoding.h
//  CONDOR
//
//  Created by Luca on 23/3/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface USAVVoiceRecoding : NSObject <AVAudioRecorderDelegate>

@property (strong, nonatomic) AVAudioSession *audioSession;
@property (strong, nonatomic) NSURL *recordedTmpFile;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer * avPlayer;

- (USAVVoiceRecoding *)initWithAudioSession;
- (NSURL *)startRecord;
- (void)endRecord;
- (void)cancelRecord;
- (void)startPlay: (NSURL *)url;
- (void)endPlay;

@end
