//
//  EDNTiledAppleLayer.m
//  MapTest1
//
//  Created by Nicholas Furness on 3/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "EDNTiledAppleLayer.h"
#import "EDNAppleTileOperation.h"

@interface EDNTiledAppleLayer ()
{
@protected
    AGSTileInfo* _tileInfo;
    AGSEnvelope* _fullEnvelope;
    AGSEnvelope* _initialEnvelope;
    AGSUnits _units;    
    AGSSpatialReference* _sr;
    NSArray* _lods;
    AGSOpenStreetMapLayer *_osmLayer;
}
@end

@implementation EDNTiledAppleLayer
-(id)init
{
    if (self = [super init])
    {
        _osmLayer = [AGSOpenStreetMapLayer openStreetMapLayer];
        [self layerDidLoad];
    }
    
    return self;
}


-(AGSSpatialReference*) spatialReference {
    if (_sr == nil)
    {
        _sr = [AGSSpatialReference spatialReferenceWithWKID:102100];
    }
    return _sr;
}
-(BOOL)renderNativeResolution
{
    return NO;
}

-(AGSUnits) units {
//    return _osmLayer.units;
    return AGSUnitsMeters;
}

-(NSArray *) LODS {
//    return _osmLayer.tileInfo.lods;
    if (_lods == nil)
    {
        _lods = [NSArray arrayWithObjects:
                 [[AGSLOD alloc] initWithLevel:4 resolution:9783.93962049996 scale:36978595.474472],
                 [[AGSLOD alloc] initWithLevel:5 resolution:4891.96981024998 scale:18489297.737236],
                 [[AGSLOD alloc] initWithLevel:6 resolution:2445.98490512499 scale:9244648.868618],
                 [[AGSLOD alloc] initWithLevel:7 resolution:1222.99245256249 scale:4622324.434309],
                 [[AGSLOD alloc] initWithLevel:8 resolution:611.49622628138 scale:2311162.217155],
                 [[AGSLOD alloc] initWithLevel:9 resolution:305.748113140558 scale:1155581.108577],
                 [[AGSLOD alloc] initWithLevel:10 resolution:152.874056570411 scale:577790.554289],
                 [[AGSLOD alloc] initWithLevel:11 resolution:76.4370282850732 scale:288895.277144],
                 [[AGSLOD alloc] initWithLevel:12 resolution:38.2185141425366 scale:144447.638572],
                 [[AGSLOD alloc] initWithLevel:13 resolution:19.1092570712683 scale:72223.819286], nil];
    }
    
    return _lods;
}

-(AGSEnvelope*) fullEnvelope {
    //return _osmLayer.fullEnvelope;
    if (_fullEnvelope == nil)
    {
        double yLimit = 20971868.8804086;
        _fullEnvelope = [AGSEnvelope envelopeWithXmin:-20037507.0671618 
                                                 ymin:-yLimit
                                                 xmax:20037507.0671618 
                                                 ymax:yLimit 
                                     spatialReference:self.spatialReference];    

    }
    
    return _fullEnvelope;
}

-(AGSEnvelope*) initialEnvelope
{
    //return _osmLayer.initialEnvelope;
    return self.fullEnvelope;
    if (_initialEnvelope == nil)
    {
        _initialEnvelope = [AGSEnvelope envelopeWithXmin:-20037507.0671618 
                                                 ymin:-20037507.0671618
                                                 xmax:20037507.0671618
                                                 ymax:20037507.0671619
                                     spatialReference:self.spatialReference];    
        
    }
    
    return _initialEnvelope;
}

-(AGSTileInfo*) tileInfo
{ 
    if (_tileInfo == nil)
    {
        AGSTileInfo *osmTileInfo = _osmLayer.tileInfo;
        NSMutableArray *newLods = [[NSMutableArray alloc] init];
        NSMutableArray *newLods2 = [NSMutableArray arrayWithArray:osmTileInfo.lods];
        
        NSInteger minLOD = 3;
        NSInteger maxLOD = 14;

        // Creating my own new LODs doesn't work.
        for (AGSLOD *lod in osmTileInfo.lods)
        {
           if (lod.level >= minLOD && lod.level <= maxLOD)
            {
//                NSLog(@"Adding LOD %d %f %f", lod.level, lod.resolution, lod.scale);
                AGSLOD* newLOD = [[AGSLOD alloc] initWithLevel:lod.level resolution:lod.resolution scale:lod.scale];
                [newLods addObject:newLOD];
            }
        }
        
        // Copying the array and removing LODs I don't want does work. I'm confused!!!
        for (int i = newLods2.count -1; i>=0; i--)
        {
            AGSLOD *tmpLod = [newLods2 objectAtIndex:i];
            if (tmpLod.level > maxLOD ||
                tmpLod.level < minLOD)
            {
                [newLods2 removeObjectAtIndex:i];
            }
        }
        
//        NSLog(@"%@\n#####%@", newLods, newLods2);
        
        AGSPoint *newOrigin = [AGSPoint pointWithX:osmTileInfo.origin.x 
                                                 y:osmTileInfo.origin.y 
                                  spatialReference:[AGSSpatialReference spatialReferenceWithWKID:102100]];
        _tileInfo = [[AGSTileInfo alloc] initWithDpi:96 // Should be 72 - need to be able to create LODs first...
                                              format:@"JPEG"
                                                lods:newLods2
                                              origin:newOrigin
                                    spatialReference:[AGSSpatialReference spatialReferenceWithWKID:102100]
                                            tileSize:CGSizeMake(osmTileInfo.tileSize.width, osmTileInfo.tileSize.height)];

//        AGSPoint *originPoint = [AGSPoint pointWithX:-20037507.0671618 y:19971868.880408 spatialReference:self.spatialReference];
//        
//        _tileInfo = [[AGSTileInfo alloc] initWithDpi:72
//                                              format:@"jpg"
//                                                lods:self.LODS
//                                              origin:originPoint
//                                    spatialReference:self.spatialReference
//                                            tileSize:CGSizeMake(256, 256)];
        //_osmLayer = nil;
    }
    
    //NSLog(@"Returning Tile Info: %@", _tileInfo);
    
    return _tileInfo;
//    return _osmLayer.tileInfo;
}

- (void) didFinishOperation:(NSOperation<AGSTileOperation>*)op {
    //If tile was found ...
    if (op.tile.image!=nil) {
        //... notify tileDelegate of success
//        NSLog(@"Tile [%d,%d,%d] OK", op.tile.row, op.tile.column, op.tile.level);
        [self.tileDelegate tiledLayer:self operationDidGetTile:op];
    }else {
        //... notify tileDelegate of failure
//        NSLog(@"Tile [%d,%d,%d] FAILED", op.tile.row, op.tile.column, op.tile.level);
        [self.tileDelegate tiledLayer:self operationDidFailToGetTile:op];
    }
}

-(NSOperation<AGSTileOperation>*)retrieveImageAsyncForTile:(AGSTile *)tile
{
//    NSLog(@"Get me a tile [%d,%d,%d]!", tile.row, tile.column, tile.level);
    EDNAppleTileOperation *op = [[EDNAppleTileOperation alloc] initWithTile:tile 
                                                                     target:self
                                                                     action:@selector(didFinishOperation:)];
    [super.operationQueue addOperation:op];
    return op;
}

-(void)dealloc
{
    _sr = nil;
    _tileInfo = nil;
    _fullEnvelope = nil;
    _lods = nil;
    _osmLayer = nil;
}
@end
