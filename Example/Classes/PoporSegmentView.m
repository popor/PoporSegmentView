//
//  PoporSegmentView.m
//  PoporSegmentView
//
//  Created by popor on 2019/07/10.
//  Copyright © 2017年 popor. All rights reserved.
//

#import "PoporSegmentView.h"

#import <Masonry/Masonry.h>
#import <PoporUI/UIView+Extension.h>

#define ANIMATION_DURATION 0.15

@interface PoporSegmentView ()

@property (nonatomic        ) BOOL titleLineLock;
@property (nonatomic, weak  ) UIButton * firstBT;

@end

@implementation PoporSegmentView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithStyle:PoporSegmentViewTypeView];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithStyle:PoporSegmentViewTypeView];
}

- (id)initWithStyle:(PoporSegmentViewType)style {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _style             = style;
        
        _titleArray        = @[@"tag1", @"tag2"];
        _btTitleNColor     = [UIColor lightGrayColor];
        _btTitleSColor     = [UIColor blackColor];
        _lineColor         = [UIColor blackColor];
        _originX           = 0;
        _lineWidth         = 20;
        _lineWidthFlexible = NO;
        _lineWidthScale    = 0;
        
        _btSvGap           = 20;
    }
    return self;
}

- (void)setUI {
    [self setUpHeaderView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self layoutSubviewsCustome];
        [self updateParameter];
    });
}

- (void)setUpHeaderView {
    if (self.style == PoporSegmentViewTypeScrollView) {
        UIScrollView * sv = [UIScrollView new];
        sv.showsHorizontalScrollIndicator = NO;
        sv.contentInset = UIEdgeInsetsMake(0, self.originX, 0, self.originX);
        [self addSubview:sv];
        
        self.btSV = sv;
    }
    self.btArray = [NSMutableArray new];
    for (int i = 0; i < self.titleArray.count; i ++) {
        UIButton * btn      = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag             = i;
        btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        
        [btn setTitle:self.titleArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:self.btTitleNColor forState:UIControlStateNormal];
        [btn setTitleColor:self.btTitleSColor forState:UIControlStateSelected];
        
        // [btn setBackgroundImage:[UIImage imageFromColor:[UIColor grayColor] size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        if (self.style == PoporSegmentViewTypeScrollView) {
            [self.btSV addSubview:btn];
        }else{
            [self addSubview:btn];
        }
        [self.btArray addObject:btn];
        if (i == 0) {
            btn.selected = YES;
            self.currentBT = btn;
        }
        [btn.titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        btn.titleLabel.numberOfLines =0;
    }
    if (!self.titleLineView) {
        self.titleLineView = [[UIView alloc] init];
        self.titleLineView.backgroundColor = self.lineColor;
        
        if (self.style == PoporSegmentViewTypeScrollView) {
            [self.btSV addSubview:self.titleLineView];
        }else{
            [self addSubview:self.titleLineView];
        }
    }
}

- (void)layoutSubviewsCustome {
    // !!!: 没有做第二次判断,导致出错了
    if (self.style == PoporSegmentViewTypeView) {
        if (self.btArray.count == 1) {
            [self.currentBT mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, self.originX, 0, -self.originX));
            }];
        } else if (self.btArray.count == 2) {
            UIButton * firstBT = self.btArray[0];
            UIButton * lastBT  = self.btArray.lastObject;
            [firstBT mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(self.originX);
                make.bottom.mas_equalTo(0);
                
            }];
            [lastBT mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(firstBT.mas_right);
                make.bottom.mas_equalTo(0);
                make.right.mas_equalTo(-self.originX);
                make.width.mas_equalTo(firstBT.mas_width);
            }];
        } else if (self.titleArray.count > 2) {
            UIButton * firstBT = self.btArray[0];
            UIButton * lastBT  = self.btArray.lastObject;
            [firstBT mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(self.originX);
                make.bottom.mas_equalTo(0);
                
            }];
            
            UIButton * priorBT = firstBT;
            UIButton * tempBT;
            for (int i = 1; i<self.btArray.count - 1; i++) {
                tempBT = self.btArray[i];
                [tempBT mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(0);
                    make.left.mas_equalTo(priorBT.mas_right);
                    make.bottom.mas_equalTo(0);
                    make.width.mas_equalTo(firstBT.mas_width);
                }];
                priorBT = tempBT;
            }
            
            [lastBT mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(priorBT.mas_right);
                make.bottom.mas_equalTo(0);
                make.right.mas_equalTo(-self.originX);
                make.width.mas_equalTo(firstBT.mas_width);
            }];
        }
    }else{
        if (self.btSV) {
            [self.btSV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
        }
        
        UIButton * priorBT = self.btArray.firstObject;
        [priorBT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.mas_equalTo(0);
        }];
        
        UIButton * oneBT;
        for (int i = 1; i<self.btArray.count; i++) {
            oneBT = self.btArray[i];
            [oneBT mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(priorBT.mas_right). mas_offset(self.btSvGap);
                make.centerY.mas_equalTo(0);
            }];
            priorBT = oneBT;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.btSV.contentSize = CGSizeMake(CGRectGetMaxX(priorBT.frame), self.btSV.height);
            //NSLog(@"_ self.btSV.contentSize: %@", NSStringFromCGSize(self.btSV.contentSize));
            //NSLog(@"_ priorBT: %@", NSStringFromCGRect(priorBT.frame));
        });
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.titleLineView.height = 2;
        self.titleLineView.width  = self.lineWidth;
        self.titleLineView.bottom = self.height - 2;
        
        if (self.lineWidthFlexible) {
            [self updateLineViewToBT:self.btArray.firstObject];
        }
    });
}

- (void)updateParameter {
    self.firstBT = self.btArray.firstObject;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.weakLinkSV &&
        !self.titleLineLock &&
        self.btArray.count > 0) {
        
        float svOffX    = scrollView.contentOffset.x;
        float moveScale = svOffX/scrollView.width;
        int nextPage    = moveScale >= self.currentPage ? self.currentPage+1:self.currentPage-1;
        
        if (0 <= nextPage && nextPage < self.titleArray.count) {
            
            UIButton * nextBT = self.btArray[nextPage];
            float moveS = fabsf(moveScale - self.currentPage);
            if (moveS > 1) {
                // NSLog(@"快速滑动, 需要重新计算self.currentPage, 防止滑动效果出错.");
                self.currentPage = svOffX/scrollView.width;
                [self scrollViewDidScroll:scrollView];
                return;
            }
            
            if (self.isLineWidthFlexible) {
                //NSLog(@"设置动态下划线宽度");
                float width = (1.0-moveS)*self.currentBT.titleLabel.width + moveS*nextBT.titleLabel.width;
                self.titleLineView.width = width * self.lineWidthScale;
            }
            
            {
                //NSLog(@"设置下划线中心");
                float moveMaxWidth = self.currentBT.center.x - nextBT.center.x;
                float centerX = self.currentBT.center.x - moveMaxWidth*moveS;
                
                self.titleLineView.center = CGPointMake(centerX, self.titleLineView.center.y);
            }
        }
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView==self.weakLinkSV) {
        float svOffX     = scrollView.contentOffset.x;
        self.currentPage = svOffX/scrollView.width;
        
        // 滑动结束异常处理
        if (self.currentPage >=0 && self.currentPage<self.btArray.count) {
            [self titleBtnClick:self.btArray[self.currentPage]];
        }
        self.titleLineLock = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self.weakLinkSV) {
        self.titleLineLock = NO;
    }
}

- (void)titleBtnClick:(UIButton *)bt {
    if (self.currentBT == bt) {
        return;
    }
    self.currentBT.selected = NO;
    bt.selected             = YES;
    self.currentBT          = bt;
    self.currentPage        = (int)bt.tag;
    // 加锁
    self.titleLineLock      = YES;
    [self updateLineViewToBT:self.currentBT];
    
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:12 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.weakLinkSV.contentOffset = CGPointMake(self.weakLinkSV.width * bt.tag, 0);
    } completion:^(BOOL finished) {
        self.titleLineLock = NO;
    }];
}

- (void)updateLineViewToBT:(UIButton *)bt {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isLineWidthFlexible) {
            self.titleLineView.width  = bt.titleLabel.width*self.lineWidthScale;
            self.titleLineView.center = CGPointMake(bt.center.x, self.titleLineView.center.y);
        }else{
            self.titleLineView.center = CGPointMake(bt.center.x, self.titleLineView.center.y);
        }
        if (self.style == PoporSegmentViewTypeScrollView) {
            [self.btSV scrollRectToVisible:self.titleLineView.frame animated:YES];
        }
        // NSLog(@"tag : %li - iv.center.x: %f", bt.tag, self.titleLineView.center.x);
    });
}

@end
