#import "RNVideoThumbnail.h"

@implementation RNVideoThumbnail

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(get:(NSString *)filepath resolve:(RCTPromiseResolveBlock)resolve
                               reject:(RCTPromiseRejectBlock)reject)
{
    @try {
        filepath = [filepath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSURL *vidURL = [NSURL fileURLWithPath:filepath];

        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:vidURL options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform = YES;

        NSError *err = NULL;
        CMTime oneSecond = CMTimeMake(1, 60);
        CMTime mid = CMTimeMultiplyByRatio(asset.duration, 1, 2);
        
        CMTime time = CMTimeMinimum(oneSecond, mid);

        CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage *thumbnail = [UIImage imageWithCGImage:imgRef];

        NSMutableDictionary *result = [NSMutableDictionary new];
        if (thumbnail) {
            [result setObject:@(thumbnail.size.width) forKey:@"width"];
            [result setObject:@(thumbnail.size.height) forKey:@"height"];

            NSString *path = [self saveImageToFile:thumbnail];

            [result setObject:path forKey:@"path"];
        }
        CGImageRelease(imgRef);

        resolve(result);

    } @catch(NSException *e) {
        reject(e.reason, nil, nil);
    }
}

- (NSString *)saveImageToFile:(UIImage *)image {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageSubdirectory = [documentsDirectory stringByAppendingPathComponent:@"Thumbnails"];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", [[NSUUID UUID] UUIDString]];
    NSString *filePath = [imageSubdirectory stringByAppendingPathComponent:fileName];

    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    [imageData writeToFile:filePath atomically:YES];
    
    return filePath;
}


@end
