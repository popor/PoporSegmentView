//
//  PoporSegmentView.h
//  PoporSegmentView
//
//  Created by popor on 2019/07/10.
//  Copyright © 2017年 popor. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PoporSegmentViewType) {
    PoporSegmentViewTypeView = 1, //平分宽度,不会自适应k
    PoporSegmentViewTypeViewAuto, // 自适应宽度,只在屏幕范围内
    PoporSegmentViewTypeScrollView, // 自适应宽度,会滑动
};

// 不针对可以滑动的情况.
@interface PoporSegmentView : UIView <UIScrollViewDelegate>

@property (nonatomic, readonly) PoporSegmentViewType style;

// !!!: 需要设置的地方
@property (nonatomic, copy  ) NSArray        * titleArray;
// 与之联动的外部UISrollView.
@property (nonatomic, weak  ) UIScrollView   * weakLinkSV; // 不可以为空

@property (nonatomic        ) float          originX;// bt距离边界的最小间隔
@property (nonatomic, strong) UIFont         * btTitleFont;
@property (nonatomic, strong) UIColor        * btTitleNColor;
@property (nonatomic, strong) UIColor        * btTitleSColor;
@property (nonatomic, strong) UIColor        * lineColor;

// 由于采用的绝对布局,所以不是和bt的相对参数
@property (nonatomic        ) int            titleLineBottom; // lineBottom之间的间距: 默认2
@property (nonatomic        ) int            titleLineHeight; // 2
@property (nonatomic        ) int            lineWidth;

// 假如line width 根据文字内容变化的话
@property (nonatomic, getter=isLineWidthFlexible) BOOL lineWidthFlexible;

// 假如lineWidthFlexible=yes,那么lineWidth相对于bt.titleLable.width的比例.
@property (nonatomic        ) float          lineWidthScale;

// scrollview 模式下,bt的间隔,默认为20.
@property (nonatomic        ) float          btSvGap;

// !!!: UI部分,自持部分
// 假如style == PoporSegmentViewTypeScrollView的话,那么bt位于btSV上面.
@property (nonatomic, strong) UIScrollView   * btSV;
@property (nonatomic, strong) NSMutableArray * btArray;
@property (nonatomic, weak  ) UIButton       * currentBT;
@property (nonatomic, strong) UIView         * titleLineView;
@property (nonatomic        ) int            currentPage;

- (id)initWithStyle:(PoporSegmentViewType)style NS_DESIGNATED_INITIALIZER;

- (void)setUI;

// !!!: 需要接受sv事件,或者直接设置sv的delegete为PoporSegmentView, 否则无法相互联动.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;

/**
 允许外部控制lineView滑动到某个bt下面.
 */
- (void)updateLineViewToBT:(UIButton *)bt;

@end

NS_ASSUME_NONNULL_END
