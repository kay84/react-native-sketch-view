//
//  SketchViewContainer.h
//  Sketch
//
//  Created by Keshav on 06/04/17.
//  Copyright © 2017 Particle41. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SketchView.h"
#import "SketchFile.h"
#import <React/RCTComponent.h>

@interface SketchViewContainer : UIView

@property (nonatomic, copy) RCTBubblingEventBlock onSketchViewEdited;
@property (nonatomic, copy) RCTBubblingEventBlock onExportSketch;
@property (nonatomic, copy) RCTBubblingEventBlock onSaveSketch;

@property (unsafe_unretained, nonatomic) IBOutlet SketchView *sketchView;

-(SketchFile *)saveToLocalCache;
-(NSString *)getBase64;
-(BOOL)openSketchFile:(NSString *)localFilePath;


@end
