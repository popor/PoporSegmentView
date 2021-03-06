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
#import <PoporMasonry/PoporMasonry.h>

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
    self.titleArray = @[@"T0", @"T1", @"T2", @"T3", @"T4", @"T5", @"T6", @"T7", @"T8", @"T9", @"T10", @"T0", @"T1", @"T2", @"T3", @"T4", @"T5", @"T6", @"T7", @"T8", @"T9", @"T10", @"T0", @"T1", @"T2", @"T3", @"T4", @"T5", @"T6", @"T7", @"T8", @"T9", @"T10" ];
    self.titleArray = @[@"T0", @"T1", @"T2", @"T3", @"T4", @"T5", @"T6", @"T7", @"T8", @"T9", @"T10", @"T0", @"T1", @"T2", @"T3"];
    //self.titleArray = @[@"T0", @"Test1", @"T2", @"Test333", @"T4"];
    //self.titleArray = @[@"T0", @"Test1", @"T2"];
    //self.titleArray = @[@"TextA", @"TextB"];
    //self.titleArray = @[@"T0"];
    if (!self.poporSV) {
        PoporSegmentView * hsv = [[PoporSegmentView alloc] initWithStyle:PoporSegmentViewTypeScrollView];
        hsv.layer.masksToBounds = YES;
        
        hsv.titleArray    = self.titleArray;
        hsv.originX       = 10;
        
        //hsv.btTitleNColor = [UIColor lightGrayColor];
        //hsv.btTitleSColor = [UIColor blackColor];
        
        hsv.btTitleNColor = [UIColor greenColor];
        hsv.btTitleSColor = [UIColor redColor];
        hsv.btTitleColorGradualChange = YES;
        //hsv.btTitleColorGradualChange = NO;
        
        
        hsv.lineColor     = [UIColor blackColor];
        
        hsv.btTitleNFont  = [UIFont systemFontOfSize:18];
        hsv.btTitleSFont  = [UIFont systemFontOfSize:18];
        
        
        //hsv.btTitleSFont  = [UIFont boldSystemFontOfSize:18];
        
        hsv.btContentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);
        //hsv.btContentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        
        hsv.lineWidthFlexible = YES;
        hsv.lineWidthScale    = 1.1;
        
        hsv.titleLineBottom = 5;
        hsv.titleLineHeight = 2;
        
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
        sv.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1];
        sv.pagingEnabled = YES;
        sv.showsHorizontalScrollIndicator = NO;
        
        [self.view addSubview:sv];
        self.infoSV = sv;
    }
    
    [self.infoSV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.poporSV.mas_bottom);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        
        make.right.mas_equalTo(0);
    }];
    
    NSMutableArray * lArray = [NSMutableArray new];
    for (int i=0; i<self.titleArray.count; i++) {
        UILabel * oneL = ({
            UILabel * l = [UILabel new];
            l.backgroundColor    = [UIColor clearColor];
            l.font               = [UIFont systemFontOfSize:20];
            l.textColor          = [UIColor blackColor];
            l.textAlignment      = NSTextAlignmentCenter;
            
            [self.infoSV addSubview:l];
            l;
        });
        oneL.text = self.titleArray[i];
        [oneL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.width.mas_equalTo(self.view.frame.size.width);
            make.height.mas_equalTo(oneL.font.pointSize+1);
        }];
        [lArray addObject:oneL];
    }
    [self.infoSV masSpacingHorizontallyWith:lArray];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.infoSV.contentSize = CGSizeMake(self.infoSV.frame.size.width*self.titleArray.count, self.infoSV.frame.size.height);
    });
}


@end
