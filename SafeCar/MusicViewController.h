//
//  ViewController.h
//  SafeCar
//
//  Created by Matthew Chan on 9/5/15.
//  Copyright (c) 2015 Matthew Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MusicViewController : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *speedometer;
@property (weak, nonatomic) IBOutlet UILabel *mph;
@property (weak, nonatomic) IBOutlet UILabel *right1;
@property (weak, nonatomic) IBOutlet UILabel *right2;
@property (weak, nonatomic) IBOutlet UILabel *right3;
@property (weak, nonatomic) IBOutlet UILabel *right4;
@property (weak, nonatomic) IBOutlet UILabel *right5;
@property (weak, nonatomic) IBOutlet UILabel *left1;
@property (weak, nonatomic) IBOutlet UILabel *left2;
@property (weak, nonatomic) IBOutlet UILabel *left3;
@property (weak, nonatomic) IBOutlet UILabel *left4;
@property (weak, nonatomic) IBOutlet UILabel *left5;
@property (weak, nonatomic) IBOutlet UILabel *ArtistName;
@property (weak, nonatomic) IBOutlet UILabel *SongName;

-(IBAction)back;

@end

