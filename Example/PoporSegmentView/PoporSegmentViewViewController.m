//
//  PoporSegmentViewViewController.m
//  PoporSegmentView
//
//  Created by popor on 07/10/2019.
//  Copyright (c) 2019 popor. All rights reserved.
//

#import "PoporSegmentViewViewController.h"
#import "PoporSegmentView.h"

#import <Masonry/Masonry.h>

@interface PoporSegmentViewViewController ()

@property (nonatomic, strong) NSArray * titleArray;
@property (nonatomic, strong) PoporSegmentView * poporSV;
@property (nonatomic, strong) UIScrollView * infoSV;


@end

@implementation PoporSegmentViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addinfoHSVs];
    [self addSVs];
    
    self.poporSV.weakLinkSV          = self.infoSV;
    self.poporSV.weakLinkSV.delegate = self.poporSV;
}

- (void)addinfoHSVs {
    self.titleArray = @[@"T0", @"Test1", @"T2", @"Test333", @"T4", @"Test55555", @"T6"];
    //self.titleArray = @[@"T0", @"Test1", @"T2", @"Test333", @"T4"];
    //self.titleArray = @[@"T0", @"Test1", @"T2"];
    //self.titleArray = @[@"T0", @"Test1"];
    //self.titleArray = @[@"T0"];
    if (!self.poporSV) {
        PoporSegmentView * hsv = [[PoporSegmentView alloc] initWithStyle:PoporSegmentViewTypeViewAuto];
        hsv.layer.masksToBounds = YES;
        
        hsv.titleArray    = self.titleArray;
        hsv.originX       = 10;
        hsv.btTitleNColor = [UIColor lightGrayColor];
        hsv.btTitleSColor = [UIColor blackColor];
        hsv.lineColor     = [UIColor blackColor];
        hsv.btTitleFont   = [UIFont systemFontOfSize:15];
        
        hsv.lineWidthFlexible = YES;
        hsv.lineWidthScale    = 1.1;
        
        hsv.backgroundColor = [UIColor whiteColor];
        
        [hsv setUI];
        [self.view addSubview:hsv];
        
        [hsv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(80);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            
            make.height.mas_equalTo(44);
        }];
        
        self.poporSV = hsv;
    }
}

- (void)addSVs {
    
    if (!self.infoSV) {
        UIScrollView * sv = [UIScrollView new];
        sv.backgroundColor = [UIColor lightGrayColor];
        sv.pagingEnabled = YES;
        
        [self.view addSubview:sv];
        self.infoSV = sv;
    }
    
    [self.infoSV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.poporSV.mas_bottom);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        
        make.right.mas_equalTo(0);
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.infoSV.contentSize = CGSizeMake(self.infoSV.frame.size.width*self.titleArray.count, self.infoSV.frame.size.height);
    });
}


@end
