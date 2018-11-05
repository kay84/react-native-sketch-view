
#import "RNSketchViewManager.h"
#import <React/RCTBridge.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTUIManager.h>
#import "SketchViewContainer.h"



@implementation RNSketchViewManager

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(RNSketchView)

RCT_CUSTOM_VIEW_PROPERTY(selectedTool, NSInteger, SketchViewContainer)
{
    SketchViewContainer *currentView = !view ? defaultView : view;
    [currentView.sketchView setToolType:[RCTConvert NSInteger:json]];
}

RCT_CUSTOM_VIEW_PROPERTY(toolColor, UIColor, SketchViewContainer)
{
    SketchViewContainer *currentView = !view ? defaultView : view;
    [currentView.sketchView setToolColor:[RCTConvert UIColor:json]];
}

RCT_CUSTOM_VIEW_PROPERTY(toolThickness, CGFloat, SketchViewContainer)
{
    SketchViewContainer *currentView = !view ? defaultView : view;
    [currentView.sketchView setToolThickness:[RCTConvert CGFloat:json]];
}

RCT_CUSTOM_VIEW_PROPERTY(localSourceImagePath, NSString, SketchViewContainer)
{
    SketchViewContainer *currentView = !view ? defaultView : view;
    NSString *localFilePath = [RCTConvert NSString:json];
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentView openSketchFile:localFilePath];
    });
}

RCT_EXPORT_VIEW_PROPERTY(onSketchViewEdited, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onExportSketch, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onSaveSketch, RCTBubblingEventBlock)

-(UIView *)view
{
    SketchViewContainer *sketchViewContainer = [[[NSBundle mainBundle] loadNibNamed:@"SketchViewContainer" owner:self options:nil] firstObject];
    sketchViewContainer.sketchView.editedCallback = ^(Boolean edited) {
        if (sketchViewContainer.onSketchViewEdited) {
            sketchViewContainer.onSketchViewEdited(@{
                                                     @"edited": @(edited)
                                                     });
        }
    };
    return sketchViewContainer;
}

RCT_EXPORT_METHOD(loadSketch:(nonnull NSNumber *)reactTag path:(nonnull NSString *)path) {
    
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,SketchViewContainer *> *viewRegistry) {
        SketchViewContainer *view = (SketchViewContainer *)viewRegistry[reactTag];
        if (![view isKindOfClass:[SketchViewContainer class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RCTCamera, got: %@", view);
        } else {
            [view openSketchFile:path];
        }
    }];
    
}


RCT_EXPORT_METHOD(saveSketch:(nonnull NSNumber *)reactTag) {
    
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,SketchViewContainer *> *viewRegistry) {
        SketchViewContainer *sketchViewContainer = (SketchViewContainer *)viewRegistry[reactTag];
        if (![sketchViewContainer isKindOfClass:[SketchViewContainer class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RCTCamera, got: %@", sketchViewContainer);
        } else {
            SketchFile *sketchFile = [sketchViewContainer saveToLocalCache];
            if (sketchViewContainer.onSaveSketch) {
                sketchViewContainer.onSaveSketch(@{
                                                   @"localFilePath": sketchFile.localFilePath,
                                                   @"imageWidth": [NSNumber numberWithFloat:sketchFile.size.width],
                                                   @"imageHeight": [NSNumber numberWithFloat:sketchFile.size.height]
                                                   });
            }
        }
    }];
    
}

RCT_EXPORT_METHOD(exportSketch:(nonnull NSNumber *)reactTag) {
    
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,SketchViewContainer *> *viewRegistry) {
        SketchViewContainer *sketchViewContainer = (SketchViewContainer *)viewRegistry[reactTag];
        if (![sketchViewContainer isKindOfClass:[SketchViewContainer class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RCTCamera, got: %@", sketchViewContainer);
        } else {
            NSString *base64 = [sketchViewContainer getBase64];
            if (sketchViewContainer.onExportSketch) {
                sketchViewContainer.onExportSketch(@{
                                                     @"base64Encoded": base64,
                                                     });
            }
        }
    }];
    
}

RCT_EXPORT_METHOD(clearSketch:(nonnull NSNumber *)reactTag) {
    
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,SketchViewContainer *> *viewRegistry) {
        SketchViewContainer *view = (SketchViewContainer *)viewRegistry[reactTag];
        if (![view isKindOfClass:[SketchViewContainer class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RCTCamera, got: %@", view);
        } else {
            [view.sketchView clear];
        }
    }];
    
}

RCT_EXPORT_METHOD(changeTool:(nonnull NSNumber *)reactTag toolId:(NSInteger) toolId) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,SketchViewContainer *> *viewRegistry) {
        SketchViewContainer *view = (SketchViewContainer *)viewRegistry[reactTag];
        if (![view isKindOfClass:[SketchViewContainer class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RCTCamera, got: %@", view);
        } else {
            [view.sketchView setToolType:toolId];
        }
    }];
    
}

@end

