//
//  EQSGraphicCalloutVCViewController.m
//  esriQuickStartApp
//
//  Created by Nicholas Furness on 8/29/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EQSGraphicCalloutViewController.h"
#import <ArcGIS/ArcGIS.h>
#import "AGSPoint+GeneralUtilities.h"

#import "EQSHelper.h"

@interface EQSGraphicCalloutViewController ()
@property (nonatomic, weak) AGSGraphic *graphic;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel2;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel3;
@end

@implementation EQSGraphicCalloutViewController
@synthesize infoLabel;
@synthesize infoLabel2;
@synthesize infoLabel3;
@synthesize graphic = _graphic;

+ (EQSGraphicCalloutViewController *)defaultVCForGraphic:(AGSGraphic *)graphic
{
    static EQSGraphicCalloutViewController *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EQSGraphicCalloutViewController alloc] initWithNibName:nil bundle:nil];
    });
    
    sharedInstance.graphic = graphic;
    
    return sharedInstance;
}

- (void) setGraphic:(AGSGraphic *)graphic
{
    _graphic = graphic;
    if (self.view)
    {
        NSString *geomType = AGSGeometryTypeString(AGSGeometryTypeForGeometry(self.graphic.geometry));
        geomType = [geomType substringFromIndex:@"esriGeometry".length];
        NSString *info1 = geomType, *info2 = @"", *info3 = @"";
        AGSGeometryEngine *ge = [AGSGeometryEngine defaultGeometryEngine];
        switch (AGSGeometryTypeForGeometry(self.graphic.geometry))
        {
            case AGSGeometryTypePolygon:
            {
                AGSPolygon *poly = (AGSPolygon *)self.graphic.geometry;
                AGSSRUnit polyUnit = poly.spatialReference.unit;
                AGSUnits lengthUnit = AGSUnitsFromSpatialReference(poly.spatialReference);
                NSString *lengthStr = AGSUnitsAbbreviatedString(lengthUnit);
                AGSAreaUnits areaUnit = AGSAreaUnitsFromAGSUnits(lengthUnit);
                NSString *areaStr = AGSAreaUnitsAbbreviatedString(areaUnit);
                info2 = [NSString stringWithFormat:@"Area: %.2f%@", [ge shapePreservingAreaOfGeometry:poly
                                                                                               inUnit:areaUnit], areaStr];
                info3 = [NSString stringWithFormat:@"Outline length: %.2f%@", [ge shapePreservingLengthOfGeometry:poly
                                                                                                           inUnit:polyUnit], lengthStr];
            }
                break;
            case AGSGeometryTypePolyline:
            {
                AGSPolyline *line = (AGSPolyline *)self.graphic.geometry;
                AGSSRUnit lineUnit = line.spatialReference.unit;
                AGSUnits lengthUnit = AGSUnitsFromSpatialReference(line.spatialReference);
                NSString *lengthStr = AGSUnitsAbbreviatedString(lengthUnit);
                double len = [ge shapePreservingLengthOfGeometry:line inUnit:lineUnit];
                info2 = [NSString stringWithFormat:@"Length: %.2f%@", len, lengthStr];
            }
                break;
            case AGSGeometryTypePoint:
            {
                AGSPoint *pt = (AGSPoint *)self.graphic.geometry;
                info2 = [NSString stringWithFormat:@"Point: %.4f,%.4f", pt.latitude, pt.longitude];
            }
                break;
                
            default:
                break;
        }
        self.infoLabel.text = info1;
        self.infoLabel2.text = info2;
        self.infoLabel3.text = info3;
        self.view.layer.cornerRadius = 7;
    }
}

- (void)viewDidUnload
{
    [self setInfoLabel:nil];
    [self setInfoLabel2:nil];
    [self setInfoLabel3:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
@end
