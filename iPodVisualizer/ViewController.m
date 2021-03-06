//
//  ViewController.m
//  iPodVisualizer
//
//  Created by Xinrong Guo on 13-3-23.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VisualizerView.h"

@interface ViewController ()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) NSArray *playItems;
@property (strong, nonatomic) NSArray *pauseItems;
@property (strong, nonatomic) UIBarButtonItem *playBBI;
@property (strong, nonatomic) UIBarButtonItem *pauseBBI;
@property (strong, nonatomic) UIBarButtonItem *ffBBI;
@property (strong, nonatomic) UIBarButtonItem *rewBBI;

// Add properties here
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) VisualizerView *visualizer;

@end

@implementation ViewController {
    BOOL _isBarHide;
    BOOL _isPlaying;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureBars];

    [self configureAudioSession];
  
    UIImage *blueGradient = [UIImage imageNamed:@"BG@2x.png"];
    UIImageView *blueGradientView = [[UIImageView alloc] initWithImage:blueGradient];
    blueGradientView.frame = self.view.frame;
    
    self.visualizer = [[VisualizerView alloc] initWithFrame:self.view.frame];
    [_visualizer setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_backgroundView addSubview:blueGradientView];
    [_backgroundView addSubview:_visualizer];

    UIImage *image1 = [UIImage imageNamed:@"HOME-overlay@2x.png"];
    UIImageView *imgView1 = [[UIImageView alloc] initWithImage:image1];
   // imgView1.alpha = .5f; // This is most advisably 1.0 (always)
    imgView1.alpha = 1.0;
    imgView1.backgroundColor = [UIColor clearColor];
    imgView1.frame = self.view.frame;
    [self.view addSubview:imgView1];
    [self.view bringSubviewToFront:imgView1];

    
    [self configureAudioPlayer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self toggleBars];
}

- (void)configureBars {
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    CGRect frame = self.view.frame;
    
    self.backgroundView = [[UIView alloc] initWithFrame:frame];
    [_backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_backgroundView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_backgroundView];
    
    
    
    UIImage *image1 = [UIImage imageNamed:@"HOME-overlay@2x.png"];
    UIImageView *imgView1 = [[UIImageView alloc] initWithImage:image1];
    imgView1.alpha = .5f; // This is most advisably 1.0 (always)
    imgView1.backgroundColor = [UIColor clearColor];
    imgView1.frame = frame;
    [self.view addSubview:imgView1];
    [self.view bringSubviewToFront:imgView1];

    
    // NavBar
    self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, -44, frame.size.width, 44)];
    [_navBar setBarStyle:UIBarStyleBlackTranslucent];
    [_navBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    UINavigationItem *navTitleItem = [[UINavigationItem alloc] initWithTitle:@"Sleep Number Mood Bed"];
    [_navBar pushNavigationItem:navTitleItem animated:NO];
    
    [self.view addSubview:_navBar];
    
    // ToolBar
  //  self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 320, frame.size.width, 44)];
    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 44)];

   // [_toolBar setBarStyle:UIBarStyleBlackTranslucent];
    [_toolBar setBarStyle:UIBarStyleBlackOpaque];
    [_toolBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_toolBar setTintColor:[UIColor grayColor]];
    
    UIBarButtonItem *pickBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(pickSong)];
    
    self.playBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPause)];
    
    self.pauseBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(playPause)];
    
    //dummy buttoms for mockup
    self.ffBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(playPause)];
    self.rewBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(playPause)];

    
    UIBarButtonItem *leftFlexBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *rightFlexBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.playItems = [NSArray arrayWithObjects:pickBBI, leftFlexBBI, _rewBBI, leftFlexBBI, _playBBI, rightFlexBBI, _ffBBI, rightFlexBBI, nil];
    self.pauseItems = [NSArray arrayWithObjects:pickBBI, leftFlexBBI, _pauseBBI, rightFlexBBI, nil];
    
    [_toolBar setItems:_playItems];
    
    [self.view addSubview:_toolBar];
    
    _isBarHide = YES;
    _isPlaying = NO;
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [_backgroundView addGestureRecognizer:tapGR];
}

- (void)toggleBars {
    CGFloat navBarDis = -44;
    CGFloat toolBarDis = 44;
    if (_isBarHide ) {
        navBarDis = -navBarDis;
        toolBarDis = -toolBarDis;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGPoint navBarCenter = _navBar.center;
        navBarCenter.y += navBarDis;
        [_navBar setCenter:navBarCenter];
        
        CGPoint toolBarCenter = _toolBar.center;
        toolBarCenter.y += toolBarDis;
        [_toolBar setCenter:toolBarCenter];
    }];
    
    _isBarHide = !_isBarHide;
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGR {
    [self toggleBars];
}


#pragma mark - Music control

- (void)playPause {
    if (_isPlaying) {
        // Pause audio here
        [_audioPlayer pause];
      
        [_toolBar setItems:_playItems];  // toggle play/pause button
    }
    else {
        // Play audio here
        [_audioPlayer play];
      
        [_toolBar setItems:_pauseItems]; // toggle play/pause button
    }
    _isPlaying = !_isPlaying;
}

- (void)playURL:(NSURL *)url {
    if (_isPlaying) {
        [self playPause]; // Pause the previous audio player
    }

    // Add audioPlayer configurations here
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_audioPlayer setNumberOfLoops:-1];
    [_audioPlayer setMeteringEnabled:YES];
    [_visualizer setAudioPlayer:_audioPlayer];
  
    [self playPause];   // Play 
}

#pragma mark - Media Picker

/*
 * This method is called when the user presses the magnifier button (because this selector was used 
 * to create the button in configureBars, defined earlier in this file). It displays a media picker 
 * screen to the user configured to show only audio files.
 */
- (void)pickSong {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    [picker setDelegate:self];
    [picker setAllowsPickingMultipleItems: NO];
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - Media Picker Delegate

/*
 * This method is called when the user chooses something from the media picker screen. It dismisses the media picker screen
 * and plays the selected song.
 */
- (void)mediaPicker:(MPMediaPickerController *) mediaPicker didPickMediaItems:(MPMediaItemCollection *) collection {
  
    // remove the media picker screen
    [self dismissViewControllerAnimated:YES completion:NULL];

    // grab the first selection (media picker is capable of returning more than one selected item,
    // but this app only deals with one song at a time)
    MPMediaItem *item = [[collection items] objectAtIndex:0];
    NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
    [_navBar.topItem setTitle:title];
  
    // get a URL reference to the selected item
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];

    // pass the URL to playURL:, defined earlier in this file
    [self playURL:url];
}

/*
 * This method is called when the user cancels out of the media picker. It just dismisses the media picker screen.
 */
- (void)mediaPickerDidCancel:(MPMediaPickerController *) mediaPicker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)configureAudioPlayer {
  NSURL *audioFileURL = [[NSBundle mainBundle] URLForResource:@"DemoSong" withExtension:@"m4a"];
  NSError *error;
  self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:&error];
  if (error) {
    NSLog(@"%@", [error localizedDescription]);
  }
  [_audioPlayer setNumberOfLoops:-1];
  [_audioPlayer setMeteringEnabled:YES];
  [_visualizer setAudioPlayer:_audioPlayer];
}

- (void)configureAudioSession {
  NSError *error;
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
  
  if (error) {
    NSLog(@"Error setting category: %@", [error description]);
  }
}

@end
