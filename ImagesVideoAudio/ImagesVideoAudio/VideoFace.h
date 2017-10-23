//
//  VideoFace.h
//  ImagesVideoAudio
//
//  Created by soson on 2017/10/23.
//  Copyright © 2017年 com.demo.app. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoFace : NSObject

+ (void)splitVideo:(AVURLAsset *)avasset cachePath:(NSString *)cachePath ACompletedBlock:(void (^)(NSMutableArray *times, float fps))completionBlock;

+(void)playAction:(NSString *)theVideoPath view:(UIView *)view;

+(void)getAudioForVideoAsset:(AVURLAsset *)avasset cachePath:(NSString *)cachePath;
+(void)testCompressionSession:(NSString *)movieP imageArr:(NSMutableArray *)imageArray times:(NSMutableArray *)times fps:(float)fps;

+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

@end

