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

@interface PoporSegmentView ()

@property (nonatomic        ) BOOL titleLineLock;
@property (nonatomic, weak  ) UIButton * firstBT;
@property (nonatomic, getter=isUpdateCurrentBT_outer) BOOL updateCurrentBT_outer; // 是否外部修改过 当前选择的 BT

@property (nonatomic        ) BOOL ignoreUpdateBtSvConentOffset; // 是否 临时忽略
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
        _btTitleFont       = [UIFont systemFontOfSize:15];
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
    
    //self.backgroundColor = UIColor.redColor;
    self.btArray = [NSMutableArray<UIButton *> new];
    for (int i = 0; i < self.titleArray.count; i ++) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //btn.backgroundColor = [UIColor brownColor];
        
        if (self.btBgImageN) {
            [btn setBackgroundImage:self.btBgImageN forState:UIControlStateNormal];
            if (self.btBgImageS) {
                [btn setBackgroundImage:self.btBgImageS forState:UIControlStateSelected];
            }
        }
        
        if (self.btCornerRadius > 0) {
            btn.layer.cornerRadius  = self.btCornerRadius;
            btn.layer.masksToBounds = YES;
        }
        
        btn.tag = i;
        NSString * title = self.titleArray[i];
        
        [btn setTitle:title forState:UIControlStateNormal];
        btn.titleLabel.font = self.btTitleFont;
        
        if (self.btTitleColorGradualChange) {
            if (i == 0) {
                if (self.btTitleSColor) {
                    [btn setTitleColor:self.btTitleSColor forState:UIControlStateNormal];
                } else {
                    [btn setTitleColor:self.btTitleNColor forState:UIControlStateNormal];
                }
                
            } else {
                [btn setTitleColor:self.btTitleNColor forState:UIControlStateNormal];
            }
        } else {
            [btn setTitleColor:self.btTitleNColor forState:UIControlStateNormal];
            [btn setTitleColor:self.btTitleSColor forState:UIControlStateSelected];
        }
        
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
        
        [btn.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
        }];
        
        if (i == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self updateCurrentBTColorPage_Bt:btn];
            });
        }
    }
    if (!self.titleLineView) {
        UIView * oneV = [[UIView alloc] init];
        oneV.alpha = 0; // 先隐藏, 不然动画效果不好看
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
                    make.left.mas_equalTo(self.originX);
                    
                    if (self.btHeight > 0) {
                        make.height.mas_equalTo(self.btHeight);
                        make.centerY.mas_equalTo(0);
                    } else {
                        make.top.mas_equalTo(0);
                        make.centerY.mas_equalTo(0);
                        make.bottom.mas_equalTo(0);
                    }
                    
                }];
                [lastBT mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(firstBT.mas_right);
                    make.right.mas_equalTo(-self.originX);
                    make.width.mas_equalTo(firstBT.mas_width);
                    
                    if (self.btHeight > 0) {
                        make.height.mas_equalTo(self.btHeight);
                        make.centerY.mas_equalTo(0);
                    } else {
                        make.top.mas_equalTo(0);
                        make.centerY.mas_equalTo(0);
                        make.bottom.mas_equalTo(0);
                    }
                }];
            } else if (self.titleArray.count > 2) {
                UIButton * firstBT = self.btArray[0];
                UIButton * lastBT  = self.btArray.lastObject;
                [firstBT mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.originX);
                    
                    if (self.btHeight > 0) {
                        make.height.mas_equalTo(self.btHeight);
                        make.centerY.mas_equalTo(0);
                    } else {
                        make.top.mas_equalTo(0);
                        make.centerY.mas_equalTo(0);
                        make.bottom.mas_equalTo(0);
                    }
                    
                }];
                
                UIButton * priorBT = firstBT;
                UIButton * tempBT;
                for (int i = 1; i<self.btArray.count - 1; i++) {
                    tempBT = self.btArray[i];
                    [tempBT mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(priorBT.mas_right);
                        
                        if (self.btHeight > 0) {
                            make.height.mas_equalTo(self.btHeight);
                            make.centerY.mas_equalTo(0);
                        } else {
                            make.top.mas_equalTo(0);
                            make.centerY.mas_equalTo(0);
                            make.bottom.mas_equalTo(0);
                        }
                    }];
                    priorBT = tempBT;
                }
                
                [lastBT mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(priorBT.mas_right);
                    make.right.mas_equalTo(-self.originX);
                    make.width.mas_equalTo(firstBT.mas_width);
                    
                    if (self.btHeight > 0) {
                        make.height.mas_equalTo(self.btHeight);
                        make.centerY.mas_equalTo(0);
                    } else {
                        make.top.mas_equalTo(0);
                        make.centerY.mas_equalTo(0);
                        make.bottom.mas_equalTo(0);
                    }
                }];
            }
            break;
        }
        case PoporSegmentViewTypeViewAuto : {
            // 自适应宽度,只在屏幕范围内
            if (self.btsGap > 0) {
                {
                    UIView * spaceOneView = UIView.new;
                    UIView * spaceTwoView = UIView.new;
                    [self addSubview:spaceTwoView];
                    [self addSubview:spaceOneView];
                    
                    [spaceOneView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(0);
                        make.width.equalTo(spaceTwoView);
                        make.centerY.equalTo(self);
                    }];
                    
                    [spaceTwoView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerY.equalTo(self);
                        make.right.mas_equalTo(0);
                    }];
                    
                    UIButton * lastBT;
                    for (int i = 0; i<self.btArray.count; i++) {
                        UIButton * tempBT = self.btArray[i];
                        [tempBT mas_makeConstraints:^(MASConstraintMaker *make) {
                            if (self.btHeight > 0) {
                                make.height.mas_equalTo(self.btHeight);
                                make.centerY.mas_equalTo(0);
                            } else {
                                make.top.mas_equalTo(0);
                                make.centerY.mas_equalTo(0);
                                make.bottom.mas_equalTo(0);
                            }
                            if (lastBT) {
                                make.left.mas_equalTo(lastBT.mas_right).mas_offset(self.btsGap);
                            }
                            
                            if (i == 0) {
                                make.left.mas_equalTo(spaceOneView.mas_right);
                            }
                            if (i == self.btArray.count -1) {
                                make.right.mas_equalTo(spaceTwoView.mas_left);
                            }
                        }];
                        lastBT = tempBT;
                    }
                }
                
            } else {
                for (int i = 0; i<self.btArray.count; i++) {
                    UIButton * tempBT = self.btArray[i];
                    [tempBT mas_makeConstraints:^(MASConstraintMaker *make) {
                        
                        if (self.btHeight > 0) {
                            make.height.mas_equalTo(self.btHeight);
                            make.centerY.mas_equalTo(0);
                        } else {
                            make.top.mas_equalTo(0);
                            make.centerY.mas_equalTo(0);
                            make.bottom.mas_equalTo(0);
                        }
                    }];
                }
                
                [self masSpacingHorizontallyWith:self.btArray];
            }
            
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
                
                if (self.btHeight > 0) {
                    make.height.mas_equalTo(self.btHeight);
                    make.centerY.mas_equalTo(0);
                } else {
                    make.top.mas_equalTo(0);
                    make.centerY.mas_equalTo(0);
                    make.bottom.mas_equalTo(0);
                }
            }];
            
            UIButton * oneBT;
            for (int i = 1; i<self.btArray.count; i++) {
                oneBT = self.btArray[i];
                [oneBT mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(priorBT.mas_right);
                    
                    if (self.btHeight > 0) {
                        make.height.mas_equalTo(self.btHeight);
                        make.centerY.mas_equalTo(0);
                    } else {
                        make.top.mas_equalTo(0);
                        make.centerY.mas_equalTo(0);
                        make.bottom.mas_equalTo(0);
                    }
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
        self.titleLineView.frame = CGRectMake(self.titleLineView.frame.origin.x +self.lineMoveX, y, width, height);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.isUpdateCurrentBT_outer && !self.currentBT) {
                [self updateLineViewToBT:self.btArray.firstObject];
            }
            [UIView animateWithDuration:0.15 animations:^{
                self.titleLineView.alpha = 1;
            }];
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
            // ------ 屏蔽手动快速滑动, 忽略代码控制情况. ------
            if (moveS > 1) {
                if (scrollView.isDragging) {
                    // NSLog(@"快速滑动, 需要重新计算self.currentPage, 防止滑动效果出错.");
                    if (self.btTitleColorGradualChange) {
                        
                    } else {
                        self.currentBT.selected = NO;
                    }
                    
                    self.currentPage = svOffX/scrollView.frame.size.width;
                    self.currentBT   = self.btArray[self.currentPage];
                    
                    [self updateCurrentBTColorPage_Bt:self.currentBT];
                    
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
            
            [self updateBtUiScale:moveS currentBT:self.currentBT nextBT:nextBT];
            
            // ------ 下划线 ------ //if (moveS > 1 && scrollView.isDragging) { return; }
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
                self.titleLineView.center = CGPointMake(centerX +self.lineMoveX, self.titleLineView.center.y);
            }
            
            // ------ 检查nextBT是否在可见范围 ------
            if (!self.ignoreUpdateBtSvConentOffset) {
                CGRect rect = CGRectMake(self.btSV.contentOffset.x, self.btSV.contentOffset.y, self.btSV.visibleSize.width, self.btSV.visibleSize.height);
                if (!CGRectContainsRect(rect, nextBT.frame)) {
                    
                    self.ignoreUpdateBtSvConentOffset = YES;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.ignoreUpdateBtSvConentOffset = NO;
                    });
                    
                    // 文本长度超过满屏的暂不考虑
                    if (nextBT.frame.origin.x < self.btSV.contentOffset.x) { // 靠左
                        [self.btSV setContentOffset:CGPointMake(nextBT.frame.origin.x -self.originX, nextBT.frame.origin.y) animated:YES];
                    } else { // 靠右
                        [self.btSV setContentOffset:CGPointMake(CGRectGetMaxX(nextBT.frame) -self.btSV.frame.size.width +self.originX, nextBT.frame.origin.y) animated:YES];
                    }
                }
                
            }
           
            // ----------
        }
    }
    
}

- (void)updateBtUiScale:(CGFloat)moveS currentBT:(UIButton *)cBT nextBT:(UIButton *)nextBT {
    //NSLog(@"c.title:%@ , n.title:%@, moveS:%f", cBT.titleLabel.text, nextBT.titleLabel.text, moveS);
    
    if (self.btTitleFontScale != 0) { // title scale
        if (nextBT) {
            CGFloat scale1 = 1.0 +self.btTitleFontScale -self.btTitleFontScale*moveS;
            CGFloat scale2 = 1.0 +self.btTitleFontScale*moveS;
            cBT.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale1, scale1);
            nextBT.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale2, scale2);
        } else {
            CGFloat scale1 = 1.0 +self.btTitleFontScale*moveS;
            cBT.titleLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale1, scale1);
        }
    }
    
    {   // title color
        if (nextBT) {
            UIColor * mixColorA;
            UIColor * mixColorB;
            [self mixColorA:self.btTitleNColor colorB:self.btTitleSColor scale:moveS mixColorA:&mixColorA mixColorB:&mixColorB];
            [cBT    setTitleColor:mixColorA forState:UIControlStateNormal];
            [nextBT setTitleColor:mixColorB forState:UIControlStateNormal];
        } else {
            [cBT    setTitleColor:self.btTitleSColor forState:UIControlStateNormal];
        }
    }
    
    // bt bg color
    if (self.btBgImageColorN0 && self.btBgImageColorS0) {
        
        if (nextBT) {
            UIColor * mixColorN0;
            UIColor * mixColorS0;
            
            [self mixColorA:self.btBgImageColorN0 colorB:self.btBgImageColorS0 scale:moveS mixColorA:&mixColorS0 mixColorB:&mixColorN0];
            
            UIImage * imageS = [[self class] imageFromColor:mixColorS0 size:CGSizeMake(1, 1) corner:0 corners:UIRectCornerTopLeft borderWidth:0 borderColor:nil borderInset:UIEdgeInsetsZero scale:0];
            UIImage * imageN = [[self class] imageFromColor:mixColorN0 size:CGSizeMake(1, 1) corner:0 corners:UIRectCornerTopLeft borderWidth:0 borderColor:nil borderInset:UIEdgeInsetsZero scale:0];
            [cBT    setBackgroundImage:imageS forState:UIControlStateNormal];
            [nextBT setBackgroundImage:imageN forState:UIControlStateNormal];
        } else {
            UIImage * imageS = [[self class] imageFromColor:self.btBgImageColorS0 size:CGSizeMake(1, 1) corner:0 corners:UIRectCornerTopLeft borderWidth:0 borderColor:nil borderInset:UIEdgeInsetsZero scale:0];
            [cBT    setBackgroundImage:imageS forState:UIControlStateNormal];
        }
    }
    else if (self.btBgImageColorN1 && self.btBgImageColorN2 && self.btBgImageColorS1 && self.btBgImageColorS2) {
        
        if (nextBT) {
            UIColor * mixColorN1;
            UIColor * mixColorN2;
            UIColor * mixColorS1;
            UIColor * mixColorS2;
            
            [self mixColorA:self.btBgImageColorN1 colorB:self.btBgImageColorS1 scale:moveS mixColorA:&mixColorS1 mixColorB:&mixColorN1];
            [self mixColorA:self.btBgImageColorN2 colorB:self.btBgImageColorS2 scale:moveS mixColorA:&mixColorS2 mixColorB:&mixColorN2];
            
            UIImage * imageS = [[self class] gradientImageWithBounds:CGRectMake(0, 0, 10, 1) andColors:@[mixColorS1, mixColorS2] gradientHorizon:YES];
            UIImage * imageN = [[self class] gradientImageWithBounds:CGRectMake(0, 0, 10, 1) andColors:@[mixColorN1, mixColorN2] gradientHorizon:YES];
            
            [cBT    setBackgroundImage:imageS forState:UIControlStateNormal];
            [nextBT setBackgroundImage:imageN forState:UIControlStateNormal];
        } else {
            UIImage * imageS = [[self class] gradientImageWithBounds:CGRectMake(0, 0, 10, 1) andColors:@[self.btBgImageColorS1, self.btBgImageColorS2] gradientHorizon:YES];
            [cBT    setBackgroundImage:imageS forState:UIControlStateNormal];
        }
    }
    else if (self.btBgImageN && self.btBgImageS) {
        if (moveS >= 1) {
            if (cBT) {
                [cBT setBackgroundImage:self.btBgImageN forState:UIControlStateNormal];
            }
            if (nextBT) {
                [nextBT setBackgroundImage:self.btBgImageS forState:UIControlStateNormal];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView==self.weakLinkSV) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkPageNumber:scrollView];
            self.titleLineLock = NO;
        });
    }
}

- (void)checkPageNumber:(UIScrollView *)scrollView {
    float svOffX     = scrollView.contentOffset.x;
    //CGFloat path     = svOffX/scrollView.frame.size.width;
    //NSLog(@"结束滑动: %.02f", path);
    self.currentPage = svOffX/scrollView.frame.size.width;
    //NSLog(@"结束滑动: %.02f -- %i", path, self.currentPage);
    
    // NSLog(@"self.currentPage: %li", self.currentPage);
    
    // 滑动结束异常处理
    if (self.currentPage >=0 && self.currentPage<self.btArray.count) {
        UIButton * bt = self.btArray[self.currentPage];
        //NSLog(@"结束滑动 : %@ -- %i", bt.titleLabel.text, self.currentPage);
        [self titleBtnClick:bt];
    } else {
        
    }
}

// 代码控制
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self.weakLinkSV) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)titleBtnClick:(UIButton *)bt {
    if (self.titleBtClickBlock) {
        self.titleBtClickBlock(bt);
    }
    
    // 容易出错, 也没绝对的必要非要检查, 主要问题在于快速滑动的时候, 有点问题.
    //    if (self.currentBT == bt) {
    //        //NSLog(@"重复 跳出: %@", bt.titleLabel.text);
    //        return;
    //    }
    
    // 加锁
    self.titleLineLock = YES;
    [self updateLineViewToBT:bt];
    
    CGFloat moveToX = self.weakLinkSV.frame.size.width * bt.tag;
    if (self.weakLinkSV.contentOffset.x != moveToX) {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:12 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.weakLinkSV.contentOffset = CGPointMake(moveToX, 0);
        } completion:^(BOOL finished) {
            self.titleLineLock = NO;
        }];
    } else {
         self.titleLineLock = NO;
    }
}

- (void)updateLineViewToBT:(UIButton *)bt {
    [self inner__updateLineViewToBT:bt];
    self.updateCurrentBT_outer = YES;
}

- (void)inner__updateLineViewToBT:(UIButton *)bt {
    //NSLog(@"___ self.currentBT.title: %@", self.currentBT.titleLabel.text);
    //NSLog(@"___ bt.title: %@", bt.titleLabel.text);
    
    [self updateCurrentBTColorPage_Bt:bt];
    [self updateTitleLineView_btSV_Bt:bt];
}

- (void)updateCurrentBTColorPage_Bt:(UIButton *)bt {
    if (!self.currentBT) {
        self.currentBT = bt;
        [self updateBtUiScale:1 currentBT:self.currentBT nextBT:nil];
    } else {
        if (self.currentBT != bt) {
            [self updateBtUiScale:1 currentBT:self.currentBT nextBT:bt];
            self.currentBT = bt;
        } else {
            [self updateBtUiScale:1 currentBT:self.currentBT nextBT:nil];
        }
    }
    // 修改 page
    self.currentPage = (int)bt.tag;
}

- (void)updateTitleLineView_btSV_Bt:(UIButton *)bt {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isLineWidthFlexible) {
            CGFloat width = bt.frame.size.width*self.lineWidthScale;
            self.titleLineView.frame  = CGRectMake(self.titleLineView.frame.origin.x, self.titleLineView.frame.origin.y, width, self.titleLineView.frame.size.height);
            self.titleLineView.center = CGPointMake(bt.center.x +self.lineMoveX, self.titleLineView.center.y);
        }else{
            self.titleLineView.center = CGPointMake(bt.center.x +self.lineMoveX, self.titleLineView.center.y);
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
                [self.btSV scrollRectToVisible:self.currentBT.frame animated:YES];
                break;
            }
            default:
                break;
        }
        // NSLog(@"tag : %li - iv.center.x: %f", bt.tag, self.titleLineView.center.x);
    });
}

- (void)mixColorA:(UIColor *)colorA colorB:(UIColor *)colorB scale:(CGFloat)scale mixColorA:(UIColor **)mixColorA mixColorB:(UIColor **)mixColorB {
    CGFloat ra, ga, ba, aa;
    CGFloat rb, gb, bb, ab;
    [self color:colorA r:&ra g:&ga b:&ba a:&aa];
    [self color:colorB r:&rb g:&gb b:&bb a:&ab];
    
    CGFloat scaleA = scale;
    CGFloat scaleB = 1 -scale;
    
    *mixColorA = [UIColor colorWithRed:(ra*scaleA +rb*scaleB) green:(ga*scaleA +gb*scaleB) blue:(ba*scaleA +bb*scaleB) alpha:(aa*scaleA +ab*scaleB)];
    
    scaleA = 1 -scale;
    scaleB = scale;
    *mixColorB = [UIColor colorWithRed:(ra*scaleA +rb*scaleB) green:(ga*scaleA +gb*scaleB) blue:(ba*scaleA +bb*scaleB) alpha:(aa*scaleA +ab*scaleB)];
}

- (void)color:(UIColor *)color r:(CGFloat *)r g:(CGFloat *)g b:(CGFloat *)b a:(CGFloat *)a {
    if (!color) {
        return;
    }
    
    CGColorRef colorCG = [color CGColor];
    if (!colorCG) {
        return;
    }
    
    NSInteger componentsNum        = CGColorGetNumberOfComponents(colorCG);
    const CGFloat *componentsArray = CGColorGetComponents(colorCG);
    
    if (componentsNum == 0) {
        
    }
    else if (componentsNum == 2) {
        *r = componentsArray[0];
        *g = componentsArray[0];
        *b = componentsArray[0];
        *a = componentsArray[1];
    }
    else if (componentsNum == 4) {
        
        *r = componentsArray[0];
        *g = componentsArray[1];
        *b = componentsArray[2];
        *a = componentsArray[3];
    }
    
    // NSLog(@"r: %f, g: %f, b: %f, a: %f, ", *r, *g, *b, *a);
}


/**
 *  获取矩形的渐变色的UIImage(此函数还不够完善)
 *
 *  @param bounds          UIImage的bounds
 *  @param colors          渐变色数组，可以设置两种颜色
 *  @param gradientHorizon 渐变的方式：0--->从上到下   1--->从左到右
 *
 *  @return 渐变色的UIImage
 */
+ (UIImage*)gradientImageWithBounds:(CGRect)bounds andColors:(NSArray*)colors gradientHorizon:(BOOL)gradientHorizon {
    CGPoint start;
    CGPoint end;
    
    if (gradientHorizon) {
        start = CGPointMake(0.0, 0.0);
        end = CGPointMake(bounds.size.width, 0.0);
    }else{
        start = CGPointMake(0.0, 0.0);
        end = CGPointMake(0.0, bounds.size.height);
    }
    
    UIImage *image = [self gradientImageWithBounds:bounds andColors:colors addStartPoint:start addEndPoint:end];
    return image;
}

+ (UIImage*)gradientImageWithBounds:(CGRect)bounds andColors:(NSArray*)colors addStartPoint:(CGPoint)startPoint addEndPoint:(CGPoint)endPoint {
    NSMutableArray *ar = [NSMutableArray array];
    
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}


// 以后图片的scale变为1.0, 尺寸有size决定, 不再自作主张.
+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size corner:(CGFloat)corner corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor * _Nullable)borderColor borderInset:(UIEdgeInsets)borderInset scale:(CGFloat)scale {
    
    if (scale <= 0) {
        scale = [UIScreen mainScreen].scale;
    }
    
    CGFloat w = size.width;
    CGFloat h = size.height;
    //CGFloat scale = [UIScreen mainScreen].scale;
    // 防止圆角半径小于0，或者大于宽/高中较小值的一半。
    if (corner < 0){
        corner = 0;
    } else if (corner > MIN(w, h)){
        corner = MIN(w, h) / 2.0;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    UIBezierPath *path;// = [UIBezierPath bezierPath];
    // 添加圆到path
    CGRect rect;
    
    // UIEdgeInsetsZero的情况
    if (UIEdgeInsetsEqualToEdgeInsets(borderInset, UIEdgeInsetsZero)) {
        rect = CGRectMake(0, 0, w, h);
    } else {
        rect = CGRectMake(borderWidth*scale/2.0 + borderInset.left, // 加上左边的set
                          borderWidth*scale/2.0 + borderInset.top,  // 加上上面的set
                          w - borderWidth*scale - borderInset.left - borderInset.right,   // 减去左边右边的set
                          h - borderWidth*scale - borderInset.top  - borderInset.bottom);// 减去上边下边的set
    }
    CGFloat radii = corner-borderWidth;
    if (radii > 0) {
        path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:CGSizeMake(radii, radii)];
    } else {
        path = [UIBezierPath bezierPathWithRect:rect];
    }
    
    
    // 设置描边宽度（为了让描边看上去更清楚）
    [path setLineWidth:borderWidth];
    //设置颜色（颜色设置也可以放在最上面，只要在绘制前都可以）
    [borderColor setStroke]; // 描边
    [color setFill];         // 填充
    [path stroke];           // 描边
    [path fill];             // 填充
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
