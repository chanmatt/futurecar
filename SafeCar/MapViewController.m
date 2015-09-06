//
//  ViewController.m
//  SafeCar
//
//  Created by Matthew Chan on 9/5/15.
//  Copyright (c) 2015 Matthew Chan. All rights reserved.
//

#import "MapViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMotion/CoreMotion.h>

@interface MapViewController () {
    CLLocationManager *locationManager;
    MPMusicPlayerController *player;
    NSTimer *timer;
    NSTimer *crashTimer;
    NSTimer *resetTimer;
    double mySpeed;
    double oldSpeed;
    CMMotionManager *motion;
    BOOL crash;
    CLLocationCoordinate2D location;
}

@end

@implementation MapViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    [[UIScreen mainScreen] setBrightness:1.0];
    
    motion = [[CMMotionManager alloc] init];
    [motion startAccelerometerUpdates];
    
    self.speedometer.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.mph.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.ArtistName.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.SongName.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.theMap.transform = CGAffineTransformMakeScale(-2.0, 2.0);
    
    player = [MPMusicPlayerController iPodMusicPlayer];
    //[player beginGeneratingPlaybackNotifications];
    
    mySpeed = -10.0;
    oldSpeed = 0;
    crash = NO;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
    NSLog(@"bleh");
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    timer = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(updateScreen)
                                           userInfo:nil
                                            repeats:YES];
    crashTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                             target:self
                                           selector:@selector(detectCrash)
                                           userInfo:nil
                                            repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [timer invalidate];
    timer = nil;
    [crashTimer invalidate];
    crashTimer = nil;
    NSLog(@"Timer invalidated");
}

- (void)detectCrash {
    //if (crash) {
        if (fabs(motion.accelerometerData.acceleration.x) > 4 || fabs(motion.accelerometerData.acceleration.y) > 4 || fabs(motion.accelerometerData.acceleration.z) > 4) {
            NSLog(@"Crash has occurred. ");
            NSLog(@"Front G-Forces: %f, ", motion.accelerometerData.acceleration.x);
            NSLog(@"Side G-Forces: %f, ", motion.accelerometerData.acceleration.y);
            NSLog(@"Z-Axis G-Forces: %f, ", motion.accelerometerData.acceleration.z);
            NSLog(@"Latitude: %f, ", location.latitude);
            NSLog(@"Longitude: %f", location.longitude);
            NSString *message = [NSString stringWithFormat:@"Crash has occurred! Front Gs: %f, Side Gs: %f, Z-Axis Gs: %f, Lat: %f, Long: %f", motion.accelerometerData.acceleration.x, motion.accelerometerData.acceleration.y, motion.accelerometerData.acceleration.z, location.latitude, location.longitude];
            [self sendText:message];
            self.speedometer.textColor = [UIColor redColor];
            self.mph.textColor = [UIColor redColor];
        }
    //}
}

- (void)sendText:(NSString *)message {
    // Common constants
    NSString *kTwilioSID = @"AC5c1742afa7ddb9fd4dcfb309e2f5d75f";
    NSString *kTwilioSecret = @"0cc402d42d7cc0a30d0771e813c994c0";
    NSString *kFromNumber = @"+18562882845";
    NSString *kToNumber = @"+15103866772";
    //NSString *kToNumber = @"+12679797408";
    NSString *kMessage = message;
    
    // Build request
    NSString *urlString = [NSString stringWithFormat:@"https://%@:%@@api.twilio.com/2010-04-01/Accounts/%@/SMS/Messages", kTwilioSID, kTwilioSecret, kTwilioSID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    
    // Set up the body
    NSString *bodyString = [NSString stringWithFormat:@"From=%@&To=%@&Body=%@", kFromNumber, kToNumber, kMessage];
    NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSError *error;
    NSURLResponse *response;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Handle the received data
    if (error) {
        NSLog(@"Error: %@", error);
    } else {
        NSString *receivedString = [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding];
        NSLog(@"Request sent. %@", receivedString);
    }
}

- (void)resetCrash {
    crash = NO;
}

- (void)updateScreen {
    NSLog(@"Acceleration Updated");
    if (mySpeed > -5) {
        if (oldSpeed-mySpeed>20) {
            crash = YES;
            crashTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                          target:self
                                                        selector:@selector(resetCrash)
                                                        userInfo:nil
                                                         repeats:YES];
        }
        if ((mySpeed-oldSpeed)>5) {
            //Max acceleration
            self.right1.hidden = NO;
            self.right2.hidden = NO;
            self.right3.hidden = NO;
            self.right4.hidden = NO;
            self.right5.hidden = NO;
            self.left1.hidden = NO;
            self.left2.hidden = NO;
            self.left3.hidden = NO;
            self.left4.hidden = NO;
            self.left5.hidden = NO;
        } else if ((mySpeed-oldSpeed)>4) {
            // 4 out of 5 acceleration
            self.right1.hidden = YES;
            self.right2.hidden = NO;
            self.right3.hidden = NO;
            self.right4.hidden = NO;
            self.right5.hidden = NO;
            self.left1.hidden = YES;
            self.left2.hidden = NO;
            self.left3.hidden = NO;
            self.left4.hidden = NO;
            self.left5.hidden = NO;
        } else if ((mySpeed-oldSpeed)>3) {
            // 3 out of 5 acceleration
            self.right1.hidden = YES;
            self.right2.hidden = YES;
            self.right3.hidden = NO;
            self.right4.hidden = NO;
            self.right5.hidden = NO;
            self.left1.hidden = YES;
            self.left2.hidden = YES;
            self.left3.hidden = NO;
            self.left4.hidden = NO;
            self.left5.hidden = NO;
        } else if ((mySpeed-oldSpeed)>2) {
            // 2 out of 5 acceleration
            self.right1.hidden = YES;
            self.right2.hidden = YES;
            self.right3.hidden = YES;
            self.right4.hidden = NO;
            self.right5.hidden = NO;
            self.left1.hidden = YES;
            self.left2.hidden = YES;
            self.left3.hidden = YES;
            self.left4.hidden = NO;
            self.left5.hidden = NO;
        } else if ((mySpeed-oldSpeed)>1) {
            // 1 out of 5 acceleration
            self.right1.hidden = YES;
            self.right2.hidden = YES;
            self.right3.hidden = YES;
            self.right4.hidden = YES;
            self.right5.hidden = NO;
            self.left1.hidden = YES;
            self.left2.hidden = YES;
            self.left3.hidden = YES;
            self.left4.hidden = YES;
            self.left5.hidden = NO;
        } else {
            //No acceleration
            self.right1.hidden = YES;
            self.right2.hidden = YES;
            self.right3.hidden = YES;
            self.right4.hidden = YES;
            self.right5.hidden = YES;
            self.left1.hidden = YES;
            self.left2.hidden = YES;
            self.left3.hidden = YES;
            self.left4.hidden = YES;
            self.left5.hidden = YES;
        }
        oldSpeed = mySpeed;
    } else {
        self.right1.hidden = YES;
        self.right2.hidden = YES;
        self.right3.hidden = YES;
        self.right4.hidden = YES;
        self.right5.hidden = YES;
        self.left1.hidden = YES;
        self.left2.hidden = YES;
        self.left3.hidden = YES;
        self.left4.hidden = YES;
        self.left5.hidden = YES;
        //No acceleration
    }
    
    //player = [MPMusicPlayerController systemMusicPlayer];
    MPMediaItem *current = player.nowPlayingItem;
    self.ArtistName.text = current.artist;
    self.SongName.text = current.title;
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    NSLog(@"yo");
    location.latitude = newLocation.coordinate.latitude;
    location.longitude = newLocation.coordinate.longitude;
    mySpeed = newLocation.speed * 2.23694;
    if (mySpeed<0) {
        self.speedometer.text = @"0";
    } else {
        self.speedometer.text = [NSString stringWithFormat:@"%.f",mySpeed];
    }
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;
    region.span = span;
    region.center = location;
    [self.theMap setRegion:region animated:YES];
    self.theMap.showsUserLocation = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back {
    [self dismissModalViewControllerAnimated:YES];
}

@end
