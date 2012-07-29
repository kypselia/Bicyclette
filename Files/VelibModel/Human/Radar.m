#import "Radar.h"
#import "Station.h"
#import "NSMutableArray+Locatable.h"

const struct RadarIdentifiers RadarIdentifiers = {
	.userLocation = @"userLocationRadar",
	.screenCenter = @"screenCenterRadar",
};


@interface Radar()
@property (nonatomic) NSArray * stationsWithinRadarRegion;
@end

@implementation Radar
@synthesize stationsWithinRadarRegion=_stationsWithinRadarRegion;
@synthesize wantsImmediateSummary=_wantsImmediateSummary;

/****************************************************************************/
#pragma mark NSManagedObject

- (void) awakeFromFetch
{
    [super awakeFromFetch];
    [self startObserving];
}

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    [self startObserving];
}

- (void) willTurnIntoFault
{
    [super willTurnIntoFault];
    [self stopObserving];
}

/****************************************************************************/
#pragma mark KVO

- (void) startObserving
{
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"RadarDistance" options:0 context:(__bridge void *)([Radar class])];
}

- (void) stopObserving
{
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"RadarDistance" context:(__bridge void *)([Radar class])];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)([Radar class])) {
        [self willChangeValueForKey:@"radarRegion"];
        [self willChangeValueForKey:@"clRegion"];
        [self didChangeValueForKey:@"radarRegion"];
        [self didChangeValueForKey:@"clRegion"];
        [self updateStationsWithinRadarRegion];
        self.wantsImmediateSummary = NO;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/****************************************************************************/
#pragma mark RadarRegion

- (MKCoordinateRegion) radarRegion
{
    CLLocationDistance radarDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadarDistance"];
    return MKCoordinateRegionMakeWithDistance(self.coordinate, radarDistance*2, radarDistance*2);
}

+ (NSSet *)keyPathsForValuesAffectingRadarRegion
{
    return [NSSet setWithObject:@"coordinate"];
}

/****************************************************************************/
#pragma mark Monitoring

- (CLRegion*) monitoringRegion
{
    CLLocationDistance radarDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadarDistance"];
    CLLocationDistance monitorDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"MonitorDistance"];
    return [[CLRegion alloc] initCircularRegionWithCenter:self.coordinate radius:radarDistance+monitorDistance identifier:self.identifier];
}

+ (NSSet *)keyPathsForValuesAffectingClRegion
{
    return [NSSet setWithObject:@"coordinate"];
}

- (void) setWantsImmediateSummary:(BOOL)wantsImmediateSummary_
{
    _wantsImmediateSummary = wantsImmediateSummary_;
    for (Station * station in self.stationsWithinRadarRegion) {
        NSLog(@"want summary %d for %@",wantsImmediateSummary_, station.cleanName);
        station.wantsImmediateSummary = wantsImmediateSummary_;
    }
}

/****************************************************************************/
#pragma mark stationsWithinRadarRegion

- (NSArray *) stationsWithinRadarRegion
{
    if(_stationsWithinRadarRegion == nil)
        [self updateStationsWithinRadarRegion];

    return _stationsWithinRadarRegion;
}

- (void) updateStationsWithinRadarRegion
{
    // Fetch in a square
    MKCoordinateRegion region = [self radarRegion];
    NSMutableArray * stations = [[Station fetchStationsWithinRange:self.managedObjectContext
                                                       minLatitude:@(region.center.latitude - region.span.latitudeDelta/2)
                                                       maxLatitude:@(region.center.latitude + region.span.latitudeDelta/2)
                                                      minLongitude:@(region.center.longitude - region.span.longitudeDelta/2)
                                                      maxLongitude:@(region.center.longitude + region.span.longitudeDelta/2)] mutableCopy];
    
    // chop those that are actually farther
    CLLocationDistance radarDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"RadarDistance"];
    CLLocation * location = [[CLLocation alloc] initWithLatitude:self.latitudeValue longitude:self.longitudeValue];
    [stations filterWithinDistance:radarDistance fromLocation:location];
    [stations sortByDistanceFromLocation:location];
    self.stationsWithinRadarRegion = [stations copy]; // compare first !
}

/****************************************************************************/
#pragma mark Location / Coordinate

- (CLLocation*) location
{
    return [[CLLocation alloc] initWithLatitude:self.latitudeValue longitude:self.longitudeValue];
}

- (CLLocationCoordinate2D) coordinate
{
    return CLLocationCoordinate2DMake(self.latitudeValue, self.longitudeValue);
}

- (void) setCoordinate:(CLLocationCoordinate2D)coordinate
{
    if(self.latitudeValue!=coordinate.latitude || self.longitudeValue != coordinate.longitude)
    {
        self.latitudeValue = coordinate.latitude;
        self.longitudeValue = coordinate.longitude;
        [self updateStationsWithinRadarRegion];
        self.wantsImmediateSummary = NO;
    }
}
@end
