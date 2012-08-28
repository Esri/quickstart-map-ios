//
//  AGSGraphicsLayer+GeneralUtilities.h
//  iOSLite
//
//  Created by Nicholas Furness on 7/4/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface AGSGraphicsLayer (EQSGeneral)
- (void) addGraphic:(AGSGraphic *)graphic withID:(NSString *)graphicID;
- (AGSGraphic *) getGraphicForID:(NSString *)graphicID;
@end
