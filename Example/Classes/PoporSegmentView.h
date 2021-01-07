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

typedef NS_ENUM(NSInteger, PoporSegmentViewLineType) {
    PoporSegmentViewLineType3 = 1, //平分宽度,不会自适应k
    PoporSegmentViewLineTypeScale, // 自适应宽度,只在屏幕范围内
    PoporSegmentViewLineTypeInsert, // 自适应宽度,会滑动
};

typedef void(^BlockP_PoporSegmentViewButton) (UIButton * bt);

// 不针对可以滑动的情况.
@interface PoporSegmentView : UIView <UIScrollViewDelegate>

@property (nonatomic, readonly) PoporSegmentViewType style;

// !!!: 需要设置的地方
@property (nonatomic, copy  ) NSArray        * titleArray;
// 与之联动的外部UISrollView.
@property (nonatomic, weak  ) UIScrollView   * weakLinkSV; // 不可以为空



@property (nonatomic, copy  ) UIFont         * btTitleFont;
@property (nonatomic        ) CGFloat        btTitleFontScale; // 默认为0, 推荐在0.05 ~ 0.1 或者 -0.05 ~ -0.1

@property (nonatomic, copy  ) UIColor        * btTitleNColor;
@property (nonatomic, copy  ) UIColor        * btTitleSColor;
@property (nonatomic        ) BOOL           btTitleColorGradualChange; // 标题颜色渐变
@property (nonatomic, copy  ) UIColor        * lineColor;

@property (nonatomic        ) UIEdgeInsets   btContentEdgeInsets;
@property (nonatomic        ) CGFloat        lineMoveX;// 线条移动的范围

//.. 目前先处理渐变色 ..................................................................................
// 背景色1, 采用image方式
@property (nonatomic, copy  ) UIImage * btBgImageN;
@property (nonatomic, copy  ) UIImage * btBgImageS;

// 背景色2, 采用imageColor方式, 还未开发
@property (nonatomic, copy  ) UIColor * btBgImageColorN0;
@property (nonatomic, copy  ) UIColor * btBgImageColorS0;

// 背景色3, 采用imageColor渐变方式
@property (nonatomic, copy  ) UIColor * btBgImageColorN1;
@property (nonatomic, copy  ) UIColor * btBgImageColorN2;
@property (nonatomic, copy  ) UIColor * btBgImageColorS1;
@property (nonatomic, copy  ) UIColor * btBgImageColorS2;

//....................................................................................
@property (nonatomic        ) CGFloat   originX;// bt距离边界的最小间隔
@property (nonatomic        ) CGFloat   btsGap;// bt之间的间隔, 目前只针对PoporSegmentViewTypeViewAuto.

//....................................................................................
@property (nonatomic        ) CGFloat   btHeight;
@property (nonatomic        ) CGFloat   btCornerRadius;

// 由于采用的绝对布局,所以不是和bt的相对参数
@property (nonatomic        ) CGFloat   titleLineBottom; // lineBottom之间的间距: 默认2
@property (nonatomic        ) CGFloat   titleLineHeight; // 默认2

// titleLine 固定宽度
@property (nonatomic        ) CGFloat   lineWidth;

@property (nonatomic, copy  ) BlockP_PoporSegmentViewButton titleBtClickBlock;

// titleLine 自适应宽度
// 假如line width 根据文字内容变化的话
@property (nonatomic, getter=isLineWidthFlexible) BOOL lineWidthFlexible;

// 假如lineWidthFlexible=yes,那么lineWidth相对于bt.titleLable.width的比例.
@property (nonatomic        ) CGFloat        lineWidthScale;

//@property (nonatomic) float btSvGap; // 不再使用,通过btContentEdgeInsets和originX决定, (scrollview 模式下,bt的间隔,默认为20)

// !!!: UI部分,自持部分
// 假如style == PoporSegmentViewTypeScrollView的话,那么bt位于btSV上面.
@property (nonatomic, strong) UIScrollView   * btSV;
@property (nonatomic, strong) NSMutableArray<UIButton *> * btArray;
@property (nonatomic, weak  ) UIButton       * currentBT;
@property (nonatomic, strong) UIView         * titleLineView;
@property (nonatomic        ) NSInteger      currentPage;

- (id)initWithStyle:(PoporSegmentViewType)style NS_DESIGNATED_INITIALIZER;

- (void)setUI;

// !!!: 需要接受sv事件,或者直接设置sv的delegete为PoporSegmentView, 否则无法相互联动.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;

/**
 允许外部控制lineView滑动到某个bt下面, 假如外部修改过, 那么内部不再主动修改.
 */
- (void)updateLineViewToBT:(UIButton *)bt;

// 先设置normal的为select, 然后再将调换
//- (void)fixBtWidthNormalFont:(UIFont *)normalFont selectFont:(UIFont *)selectFont;

@end

NS_ASSUME_NONNULL_END
