//
//  PoporSegmentView.m
//  PoporSegmentView
//
//  Created by popor on 2019/07/10.
//  Copyright © 2017年 popor. All rights reserved.
//

#import "PoporSegmentView.h"

#import <Masonry/Masonry.h>
#import <PoporMasonry/PoporMasonry.h>

#define ANIMATION_DURATION 0.15

@interface PoporSegmentView ()

@property (nonatomic        ) BOOL titleLineLock;
@property (nonatomic, weak  ) UIButton * firstBT;
@property (nonatomic, getter=isUpdateCurrentBT_outer) BOOL updateCurrentBT_outer; // 是否外部修改过 当前选择的 BT

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
        _btTitleNFont      = [UIFont systemFontOfSize:15];
        _originX           = 0;
        _lineWidth         = 20;
        _lineWidthFlexible = NO;
        _lineWidthScale    = 0;
        
        _titleLineHeight   = 2;
        _titleLineBottom   = 2;
        
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
    switch (self.style) {
        case PoporSegmentViewTypeView : {
            //平分宽度,不会自适应
            break;
        }
        case PoporSegmentViewTypeViewAuto : {
            // 自适应宽度,只在屏幕范围内
            break;
        }
        case PoporSegmentViewTypeScrollView : {
            // 自适应宽度,会滑动
            UIScrollView * sv = [UIScrollView new];
            sv.showsHorizontalScrollIndicator = NO;
            sv.contentInset = UIEdgeInsetsMake(0, self.originX, 0, self.originX);
            [self addSubview:sv];
            
            self.btSV = sv;
            break;
        }
        default:
            break;
    }
    
    self.btArray = [NSMutableArray<UIButton *> new];
    for (int i = 0; i < self.titleArray.count; i ++) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag        = i;
        if (i == 0) {
            if (self.btTitleSFont) {
                btn.titleLabel.font = self.btTitleSFont;
            } else {
                btn.titleLabel.font = self.btTitleNFont;
            }
        } else {
            btn.titleLabel.font = self.btTitleNFont;
        }
        
        [btn setTitle:self.titleArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:self.btTitleNColor forState:UIControlStateNormal];
        [btn setTitleColor:self.btTitleSColor forState:UIControlStateSelected];
        // [btn setBackgroundImage:[UIImage imageFromColor:[UIColor grayColor] size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
        //[btn setBackgroundColor:[UIColor brownColor]];
        
        if (!UIEdgeInsetsEqualToEdgeInsets(self.btContentEdgeInsets, UIEdgeInsetsZero)) {
            btn.contentEdgeInsets = self.btContentEdgeInsets;
        }
        
        [btn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        switch (self.style) {
            case PoporSegmentViewTypeView : {
                //平分宽度,不会自适应
                [self addSubview:btn];
                break;
            }
            case PoporSegmentViewTypeViewAuto : {
                // 自适应宽度,只在屏幕范围内
                [self addSubview:btn];
                break;
            }
            case PoporSegmentViewTypeScrollView : {
                // 自适应宽度,会滑动
                [self.btSV addSubview:btn];
                break;
            }
            default:
                break;
        }
        
        [self.btArray addObject:btn];
        
        [btn.titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        btn.titleLabel.numberOfLines =0;
    }
    if (!self.titleLineView) {
        UIView * oneV = [[UIView alloc] init];
        self.titleLineView = oneV;
        
        oneV.backgroundColor = self.lineColor;
        
        switch (self.style) {
            case PoporSegmentViewTypeView : {
                //平分宽度,不会自适应
                [self addSubview:oneV];
                break;
            }
            case PoporSegmentViewTypeViewAuto : {
                // 自适应宽度,只在屏幕范围内
                [self addSubview:oneV];
                break;
            }
            case PoporSegmentViewTypeScrollView : {
                // 自适应宽度,会滑动
                [self.btSV addSubview:oneV];
                break;
            }
            default:
                break;
        }
    }
}

- (void)layoutSubviewsCustome {
    // !!!: 没有做第二次判断,导致出错了
    if (self.btArray.count == 0) {
        return;
    }
    switch (self.style) {
        case PoporSegmentViewTypeView : {
            //平分宽度,不会自适应
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
            break;
        }
        case PoporSegmentViewTypeViewAuto : {
            // 自适应宽度,只在屏幕范围内
            for (int i = 0; i<self.btArray.count; i++) {
                UIButton * tempBT = self.btArray[i];
                [tempBT mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(0);
                    make.bottom.mas_equalTo(0);
                }];
            }
            [self masSpacingHorizontallyWith:self.btArray];
            
            break;
        }
        case PoporSegmentViewTypeScrollView : {
            // 自适应宽度,会滑动
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
                    make.left.mas_equalTo(priorBT.mas_right);
                    make.centerY.mas_equalTo(0);
                }];
                priorBT = oneBT;
            }
            
            // 这个仅仅是更新 contentSize, 不太影响其他系统UI.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.btSV.contentSize = CGSizeMake(CGRectGetMaxX(priorBT.frame), self.btSV.frame.size.height);
                //NSLog(@"_ self.btSV.contentSize: %@", NSStringFromCGSize(self.btSV.contentSize));
                //NSLog(@"_ priorBT: %@", NSStringFromCGRect(priorBT.frame));
            });
            break;
        }
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        float height             = self.titleLineHeight;
        float width              = self.lineWidth;
        float y                  = self.frame.size.height - self.titleLineBottom - height;
        self.titleLineView.frame = CGRectMake(self.titleLineView.frame.origin.x, y, width, height);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.isUpdateCurrentBT_outer && !self.currentBT) {
                [self updateLineViewToBT:self.btArray.firstObject];
            }
        });
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
        
        CGFloat svOffX     = scrollView.contentOffset.x;
        CGFloat moveScale  = svOffX/scrollView.frame.size.width;
        NSInteger nextPage = moveScale >= self.currentPage ? self.currentPage+1:self.currentPage-1;
        
        if (0 <= nextPage && nextPage < self.titleArray.count) {
            
            UIButton * nextBT = self.btArray[nextPage];
            float moveS = fabs(moveScale - self.currentPage);
            
            //NSLog(@"moveS: %.02f", moveS);
            // 屏蔽手动快速滑动, 忽略代码控制情况.
            if (moveS > 1) {
                if (scrollView.isDragging) {
                    // NSLog(@"快速滑动, 需要重新计算self.currentPage, 防止滑动效果出错.");
                    self.currentPage = svOffX/scrollView.frame.size.width;
                    [self.currentBT setSelected:NO];
                    self.currentBT = self.btArray[self.currentPage];
                    
                    [self scrollViewDidScroll:scrollView];
                    return;
                } else {
                    //self.currentPage = svOffX/scrollView.frame.size.width;
                    //[self.currentBT setSelected:NO];
                    //self.currentBT = self.btArray[self.currentPage];
                    
                    //[self scrollViewDidScroll:scrollView];
                    //return;
                }
            }
            
            //if (moveS > 1 && scrollView.isDragging) { return; }
            
            if (self.isLineWidthFlexible) {
                //NSLog(@"设置动态下划线宽度");
                float width = (1.0-moveS)*self.currentBT.frame.size.width + moveS*nextBT.frame.size.width;
                CGFloat width_new = width * self.lineWidthScale;
                self.titleLineView.frame = CGRectMake(self.titleLineView.frame.origin.x, self.titleLineView.frame.origin.y, width_new, self.titleLineView.frame.size.height);
            }
            
            {
                //NSLog(@"设置下划线中心");
                float moveMaxWidth = self.currentBT.center.x - nextBT.center.x;
                float centerX      = self.currentBT.center.x - moveMaxWidth*moveS;
                self.titleLineView.center = CGPointMake(centerX, self.titleLineView.center.y);
            }
        }
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView==self.weakLinkSV) {
        float svOffX     = scrollView.contentOffset.x;
        //CGFloat path     = svOffX/scrollView.frame.size.width;
        //NSLog(@"结束滑动: %.02f", path);
        self.currentPage = svOffX/scrollView.frame.size.width;
        //NSLog(@"结束滑动: %.02f -- %i", path, self.currentPage);
        
        // 滑动结束异常处理
        if (self.currentPage >=0 && self.currentPage<self.btArray.count) {
            UIButton * bt = self.btArray[self.currentPage];
            //NSLog(@"结束滑动 : %@ -- %i", bt.titleLabel.text, self.currentPage);
            [self titleBtnClick:bt];
        }
        self.titleLineLock = NO;
    }
}

// 代码控制
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self.weakLinkSV) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)titleBtnClick:(UIButton *)bt {
    if (self.currentBT == bt) {
        //NSLog(@"重复 跳出: %@", bt.titleLabel.text);
        return;
    }
    
    // 加锁
    self.titleLineLock      = YES;
    [self updateLineViewToBT:bt];
    
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:12 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.weakLinkSV.contentOffset = CGPointMake(self.weakLinkSV.frame.size.width * bt.tag, 0);
    } completion:^(BOOL finished) {
        self.titleLineLock = NO;
    }];
}

- (void)updateLineViewToBT:(UIButton *)bt {
    [self inner__updateLineViewToBT:bt];
    self.updateCurrentBT_outer = YES;
}

- (void)inner__updateLineViewToBT:(UIButton *)bt {
    //NSLog(@"___ self.currentBT.title: %@", self.currentBT.titleLabel.text);
    //NSLog(@"___ bt.title: %@", bt.titleLabel.text);
    
    // old
    if (self.currentBT) {
        self.currentBT.selected = NO;
        if (self.btTitleSFont) {
            self.currentBT.titleLabel.font = self.btTitleNFont;
        }
    }
    // new
    bt.selected             = YES;
    self.currentBT          = bt;
    if (self.btTitleSFont) {
        self.currentBT.titleLabel.font = self.btTitleSFont;
    }
    // 修改 page
    self.currentPage        = (int)bt.tag;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isLineWidthFlexible) {
            CGFloat width = bt.frame.size.width*self.lineWidthScale;
            self.titleLineView.frame = CGRectMake(self.titleLineView.frame.origin.x, self.titleLineView.frame.origin.y, width, self.titleLineView.frame.size.height);
            self.titleLineView.center = CGPointMake(bt.center.x, self.titleLineView.center.y);
        }else{
            self.titleLineView.center = CGPointMake(bt.center.x, self.titleLineView.center.y);
        }
        
        switch (self.style) {
            case PoporSegmentViewTypeView : {
                //平分宽度,不会自适应
                
                break;
            }
            case PoporSegmentViewTypeViewAuto : {
                // 自适应宽度,只在屏幕范围内
                
                break;
            }
            case PoporSegmentViewTypeScrollView : {
                // 自适应宽度,会滑动
                [self.btSV scrollRectToVisible:self.titleLineView.frame animated:YES];
                break;
            }
            default:
                break;
        }
        // NSLog(@"tag : %li - iv.center.x: %f", bt.tag, self.titleLineView.center.x);
    });
}

@end
