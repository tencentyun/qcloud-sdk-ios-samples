#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "QCloudCopyFileRequest.h"
#import "QCloudCOS.h"
#import "QCloudCOSV4Error.h"
#import "QCloudCOSV4Service+Configuration.h"
#import "QCloudCOSV4Service+Private.h"
#import "QCloudCOSV4Service.h"
#import "QCloudCOSV4TransferManagerService.h"
#import "QCloudCOSV4UploadObjectRequest.h"
#import "QCloudCreateDirectoryRequest.h"
#import "QCloudCreateDirectoryResult.h"
#import "QCloudCreateResult.h"
#import "QCloudDeleteDirectoryRequest.h"
#import "QCloudDeleteFileRequest.h"
#import "QCloudDirecotryInfo.h"
#import "QCloudDirectoryAttributesRequest.h"
#import "QCloudDirectoryAttributesResult.h"
#import "QCloudDownloadFileRequest+Custom.h"
#import "QCloudDownloadFileRequest.h"
#import "QCloudFileAttributesRequest.h"
#import "QCloudFileCustomHeaders.h"
#import "QCloudFileInfo.h"
#import "QCloudFileMultiPart.h"
#import "QCloudListDirectoryRequest.h"
#import "QCloudListDirectoryResult.h"
#import "QCloudListUploadSliceRequest.h"
#import "QCloudListUploadSliceResult.h"
#import "QCloudMoveFileRequest.h"
#import "QCloudNewCOSV4Version.h"
#import "QCloudRequestData+COSV4Version.h"
#import "QCloudUpdateAttributeFlagEnum.h"
#import "QCloudUpdateDirectoryAttributesRequest.h"
#import "QCloudUpdateFileAttributesRequest+Custom.h"
#import "QCloudUpdateFileAttributesRequest.h"
#import "QCloudUploadObjectMultiSliceOperation.h"
#import "QCloudUploadObjectRequest.h"
#import "QCloudUploadObjectRequest_Private.h"
#import "QCloudUploadObjectResult.h"
#import "QCloudUploadObjectSimpleRequest.h"
#import "QCloudUploadSliceDataRequest+Custom.h"
#import "QCloudUploadSliceDataRequest.h"
#import "QCloudUploadSliceFinishRequest.h"
#import "QCloudUploadSliceFinishResult.h"
#import "QCloudUploadSliceInfo.h"
#import "QCloudUploadSliceInitRequest+Custom.h"
#import "QCloudUploadSliceInitRequest.h"
#import "QCloudUploadSliceInitResult.h"
#import "QCloudUploadSliceListRequest.h"
#import "QCloudUploadSliceListResult.h"
#import "QCloudUploadSliceResult.h"
#import "QCloudV4EndPoint.h"

FOUNDATION_EXPORT double QCloudNewCOSV4VersionNumber;
FOUNDATION_EXPORT const unsigned char QCloudNewCOSV4VersionString[];

