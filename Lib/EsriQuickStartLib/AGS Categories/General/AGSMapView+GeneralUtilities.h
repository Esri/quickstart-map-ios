//
//  AGSMapView+GeneralUtilities.h
//  EsriQuickStartApp
//
//  Created by Nicholas Furness on 6/4/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSMapView (EQSGeneral)
// Get layer based off the name.
- (AGSLayer *) getLayerForName:(NSString *)layerName;

// Perform an operation, but if it needs to wait until the AGSMapView has loaded, wait until then.
- (void) doActionWhenLoaded:(void (^)(void))actionBlock;

//TODO - Functionality still being developed.
- (AGSEnvelope *) getEnvelopeToFitViewAspectRatio:(AGSEnvelope *)sourceEnvelope;
- (CGRect) getMinOrthoVisibleArea;
@end
