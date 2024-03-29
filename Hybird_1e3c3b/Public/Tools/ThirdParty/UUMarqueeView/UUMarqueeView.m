//
//  UUMarqueeView.m
//  UUMarqueeView
//
//  Created by youyou on 16/12/5.
//  Copyright © 2016年 iceyouyou. All rights reserved.
//

#import "UUMarqueeView.h"

@interface UUMarqueeView () <UUMarqueeViewTouchResponder>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger visibleItemCount;
@property (nonatomic, strong) NSMutableArray<UUMarqueeItemView*> *items;
@property (nonatomic, assign) int firstItemIndex;
@property (nonatomic, assign) int dataIndex;
@property (nonatomic, strong) NSTimer *scrollTimer;
@property (nonatomic, strong) UUMarqueeViewTouchReceiver *touchReceiver;

@property (nonatomic, assign) BOOL scrollStop;

@end

@implementation UUMarqueeView

static NSInteger const DEFAULT_VISIBLE_ITEM_COUNT = 2;
static NSTimeInterval const DEFAULT_TIME_INTERVAL = 4.0;
static NSTimeInterval const DEFAULT_TIME_DURATION = 1.0;
static float const DEFAULT_SCROLL_SPEED = 40.0f;
static float const DEFAULT_ITEM_SPACING = 20.0f;

- (instancetype)initWithDirection:(UUMarqueeViewDirection)direction {
    if (self = [super init]) {
        _direction = direction;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame direction:(UUMarqueeViewDirection)direction {
    if (self = [super initWithFrame:frame]) {
        _direction = direction;
        _timeIntervalPerScroll = DEFAULT_TIME_INTERVAL;
        _timeDurationPerScroll = DEFAULT_TIME_DURATION;
        _scrollSpeed = DEFAULT_SCROLL_SPEED;
        _itemSpacing = DEFAULT_ITEM_SPACING;
        _touchEnabled = NO;
        _stopWhenLessData = NO;

        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _timeIntervalPerScroll = DEFAULT_TIME_INTERVAL;
        _timeDurationPerScroll = DEFAULT_TIME_DURATION;
        _scrollSpeed = DEFAULT_SCROLL_SPEED;
        _itemSpacing = DEFAULT_ITEM_SPACING;
        _touchEnabled = NO;
        _stopWhenLessData = NO;

        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
    }
    return self;
}

- (void)setClipsToBounds:(BOOL)clipsToBounds {
    _contentView.clipsToBounds = clipsToBounds;
}

- (void)setTouchEnabled:(BOOL)touchEnabled {
    _touchEnabled = touchEnabled;
    [self resetTouchReceiver];
}

- (void)reloadData {
    if (_scrollTimer) {
        [_scrollTimer invalidate];
        self.scrollTimer = nil;
    }
    [self resetAll];
    self.scrollStop = NO;
    [self startAfterTimeInterval:YES];
}

- (void)start {
    self.scrollStop = NO;
    [self startAfterTimeInterval:NO];
}

- (void)pause {
    self.scrollStop = YES;
}

- (void)repeat {
    if (_scrollTimer) {
        [_scrollTimer invalidate];
        self.scrollTimer = nil;
    }
    if (!_scrollStop) {
        [self startAfterTimeInterval:YES];
    }
}

#pragma mark - Override(private)
- (void)layoutSubviews {
    [super layoutSubviews];

    [_contentView setFrame:self.bounds];
    [self repositionItemViews];
    if (_touchEnabled && _touchReceiver) {
        [_touchReceiver setFrame:self.bounds];
    }
}

- (void)dealloc {
    if (_scrollTimer) {
        [_scrollTimer invalidate];
        self.scrollTimer = nil;
    }
}

#pragma mark - ItemView(private)
- (void)resetAll {
    self.dataIndex = -1;
    self.firstItemIndex = 0;

    if (_items) {
        [_items makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_items removeAllObjects];
    } else {
        self.items = [NSMutableArray array];
    }

    if (_direction == UUMarqueeViewDirectionLeftward) {
        self.visibleItemCount = 1;
    } else {
        if ([_delegate respondsToSelector:@selector(numberOfVisibleItemsForMarqueeView:)]) {
            self.visibleItemCount = [_delegate numberOfVisibleItemsForMarqueeView:self];
            if (_visibleItemCount <= 0) {
                return;
            }
        } else {
            self.visibleItemCount = DEFAULT_VISIBLE_ITEM_COUNT;
        }
    }

    for (int i = 0; i < _visibleItemCount + 2; i++) {
        UUMarqueeItemView *itemView = [[UUMarqueeItemView alloc] init];
        [_contentView addSubview:itemView];
        [_items addObject:itemView];
    }

    if (_direction == UUMarqueeViewDirectionLeftward) {
        CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;
        CGFloat lastMaxX = 0.0f;
        for (int i = 0; i < _items.count; i++) {
            int index = (i + _firstItemIndex) % _items.count;

            CGFloat itemWidth = CGRectGetWidth(self.frame);
            if (i == 0) {
                [_items[index] setFrame:CGRectMake(-itemWidth, 0.0f, itemWidth, itemHeight)];
                lastMaxX = 0.0f;

                [self createItemView:_items[index]];
            } else  {
                [self moveToNextDataIndex];
                _items[index].tag = _dataIndex;
                _items[index].width = [self itemWidthAtIndex:_items[index].tag];
                itemWidth = MAX(_items[index].width + _itemSpacing, itemWidth);

                [_items[index] setFrame:CGRectMake(lastMaxX, 0.0f, itemWidth, itemHeight)];
                lastMaxX = lastMaxX + itemWidth;

                [self updateItemView:_items[index] atIndex:_items[index].tag];
            }
        }
    } else {
        if (_useDynamicHeight) {
            CGFloat itemWidth = CGRectGetWidth(self.frame);
            for (int i = 0; i < _items.count; i++) {
                int index = (i + _firstItemIndex) % _items.count;
                if (i == _items.count - 1) {
                    [self moveToNextDataIndex];
                    _items[index].tag = _dataIndex;
                    _items[index].height = [self itemHeightAtIndex:_items[index].tag];
                    _items[index].alpha = 0.0f;

                    [_items[index] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, _items[index].height)];
                    [self updateItemView:_items[index] atIndex:_items[index].tag];
                } else {
                    _items[index].tag = _dataIndex;
                    _items[index].alpha = 0.0f;

                    [_items[index] setFrame:CGRectMake(0.0f, 0.0f, itemWidth, 0.0f)];
                }
            }
        } else {
            CGFloat itemWidth = CGRectGetWidth(self.frame);
            CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;
            for (int i = 0; i < _items.count; i++) {
                int index = (i + _firstItemIndex) % _items.count;
                if (i == 0) {
                    _items[index].tag = _dataIndex;

                    [_items[index] setFrame:CGRectMake(0.0f, -itemHeight, itemWidth, itemHeight)];
                    [self createItemView:_items[index]];
                } else if (i == _items.count - 1) {
                    [self moveToNextDataIndex];
                    _items[index].tag = _dataIndex;

                    [_items[index] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, itemHeight)];
                    [self updateItemView:_items[index] atIndex:_items[index].tag];
                } else {
                    [self moveToNextDataIndex];
                    _items[index].tag = _dataIndex;

                    [_items[index] setFrame:CGRectMake(0.0f, itemHeight * (i - 1), itemWidth, itemHeight)];
                    [self updateItemView:_items[index] atIndex:_items[index].tag];
                }
            }
        }
    }

    [self resetTouchReceiver];
}

- (void)repositionItemViews {
    if (_direction == UUMarqueeViewDirectionLeftward) {
        CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;
        CGFloat lastMaxX = 0.0f;
        for (int i = 0; i < _items.count; i++) {
            int index = (i + _firstItemIndex) % _items.count;

            CGFloat itemWidth = MAX(_items[index].width + _itemSpacing, CGRectGetWidth(self.frame));

            if (i == 0) {
                [_items[index] setFrame:CGRectMake(-itemWidth, 0.0f, itemWidth, itemHeight)];
                lastMaxX = 0.0f;
            } else {
                [_items[index] setFrame:CGRectMake(lastMaxX, 0.0f, itemWidth, itemHeight)];
                lastMaxX = lastMaxX + itemWidth;
            }
        }
    } else {
        if (_useDynamicHeight) {
            CGFloat itemWidth = CGRectGetWidth(self.frame);
            CGFloat lastMaxY = 0.0f;
            for (int i = 0; i < _items.count; i++) {
                int index = (i + _firstItemIndex) % _items.count;
                if (i == 0) {
                    [_items[index] setFrame:CGRectMake(0.0f, 0.0f, itemWidth, 0.0f)];
                    lastMaxY = 0.0f;
                } else if (i == _items.count - 1) {
                    [_items[index] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, _items[index].height)];
                } else {
                    [_items[index] setFrame:CGRectMake(0.0f, lastMaxY, itemWidth, _items[index].height)];
                    lastMaxY = lastMaxY + _items[index].height;
                }
            }

            CGFloat offsetY = CGRectGetHeight(self.frame) - lastMaxY;
            for (int i = 0; i < _items.count; i++) {
                int index = (i + _firstItemIndex) % _items.count;
                if (i > 0 && i < _items.count - 1) {
                    [_items[index] setFrame:CGRectMake(CGRectGetMinX(_items[index].frame),
                                                       CGRectGetMinY(_items[index].frame) + offsetY,
                                                       itemWidth,
                                                       _items[index].height)];
                }
            }
        } else {
            CGFloat itemWidth = CGRectGetWidth(self.frame);
            CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;
            for (int i = 0; i < _items.count; i++) {
                int index = (i + _firstItemIndex) % _items.count;
                if (i == 0) {
                    [_items[index] setFrame:CGRectMake(0.0f, -itemHeight, itemWidth, itemHeight)];
                } else if (i == _items.count - 1) {
                    [_items[index] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, itemHeight)];
                } else {
                    [_items[index] setFrame:CGRectMake(0.0f, itemHeight * (i - 1), itemWidth, itemHeight)];
                }
            }
        }
    }
}

- (int)itemIndexWithOffsetFromTop:(int)offsetFromTop {
    return (_firstItemIndex + offsetFromTop) % (_visibleItemCount + 2);
}

- (void)moveToNextItemIndex {
    if (_firstItemIndex >= _items.count - 1) {
        self.firstItemIndex = 0;
    } else {
        self.firstItemIndex++;
    }
}

- (CGFloat)itemWidthAtIndex:(NSInteger)index {
    CGFloat itemWidth = 0.0f;
    if (index >= 0) {
        if ([_delegate respondsToSelector:@selector(itemViewWidthAtIndex:forMarqueeView:)]) {
            itemWidth = [_delegate itemViewWidthAtIndex:index forMarqueeView:self];
        }
    }
    return itemWidth;
}

- (CGFloat)itemHeightAtIndex:(NSInteger)index {
    CGFloat itemHeight = 0.0f;
    if (index >= 0) {
        if ([_delegate respondsToSelector:@selector(itemViewHeightAtIndex:forMarqueeView:)]) {
            itemHeight = [_delegate itemViewHeightAtIndex:index forMarqueeView:self];
        }
    }
    return itemHeight;
}

- (void)createItemView:(UUMarqueeItemView*)itemView {
    if (!itemView.didFinishCreate) {
        if ([_delegate respondsToSelector:@selector(createItemView:forMarqueeView:)]) {
            [_delegate createItemView:itemView forMarqueeView:self];
            itemView.didFinishCreate = YES;
        }
    }
}

- (void)updateItemView:(UUMarqueeItemView*)itemView atIndex:(NSInteger)index {
    if (index < 0) {
        [itemView clear];
    }

    if (!itemView.didFinishCreate) {
        if ([_delegate respondsToSelector:@selector(createItemView:forMarqueeView:)]) {
            [_delegate createItemView:itemView forMarqueeView:self];
            itemView.didFinishCreate = YES;
        }
    }

    if (index >= 0) {
        if ([_delegate respondsToSelector:@selector(updateItemView:atIndex:forMarqueeView:)]) {
            [_delegate updateItemView:itemView atIndex:index forMarqueeView:self];
        }
    }
}

#pragma mark - Timer & Animation(private)
- (void)startAfterTimeInterval:(BOOL)afterTimeInterval {
    if (_scrollTimer || _items.count <= 0) {
        return;
    }

    self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:afterTimeInterval ? _timeIntervalPerScroll : 0.0
                                                        target:self
                                                      selector:@selector(scrollTimerDidFire:)
                                                      userInfo:nil
                                                       repeats:NO];
}

- (void)scrollTimerDidFire:(NSTimer *)timer {
    if (_stopWhenLessData) {
        NSUInteger dataCount = 0;
        if ([_delegate respondsToSelector:@selector(numberOfDataForMarqueeView:)]) {
            dataCount = [_delegate numberOfDataForMarqueeView:self];
        }
        if (_direction == UUMarqueeViewDirectionLeftward) {
            if (dataCount <= 1) {
                CGFloat itemWidth = MAX(_items[1].width + _itemSpacing, CGRectGetWidth(self.frame));
                if (itemWidth <= CGRectGetWidth(self.frame)) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_timeDurationPerScroll * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (self->_scrollTimer) {
                            [self repeat];
                        }
                    });
                    return;
                }
            }
        } else {
            if (dataCount <= _visibleItemCount) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_timeDurationPerScroll * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self->_scrollTimer) {
                        [self repeat];
                    }
                });
                return;
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self->_direction == UUMarqueeViewDirectionLeftward) {
            [self moveToNextDataIndex];

            CGFloat itemHeight = CGRectGetHeight(self.frame);
            CGFloat firstItemWidth = CGRectGetWidth(self.frame);
            CGFloat currentItemWidth = CGRectGetWidth(self.frame);
            CGFloat lastItemWidth = CGRectGetWidth(self.frame);
            for (int i = 0; i < self->_items.count; i++) {
                int index = (i + self->_firstItemIndex) % self->_items.count;

                CGFloat itemWidth = MAX(self->_items[index].width + self->_itemSpacing, CGRectGetWidth(self.frame));

                if (i == 0) {
                    firstItemWidth = itemWidth;
                } else if (i == 1) {
                    currentItemWidth = itemWidth;
                } else {
                    lastItemWidth = itemWidth;
                }
            }

            // move the left item to right without animation
            self->_items[self->_firstItemIndex].tag = self->_dataIndex;
            self->_items[self->_firstItemIndex].width = [self itemWidthAtIndex:self->_items[self->_firstItemIndex].tag];
            CGFloat nextItemWidth = MAX(self->_items[self->_firstItemIndex].width + self->_itemSpacing, CGRectGetWidth(self.frame));
            [self->_items[self->_firstItemIndex] setFrame:CGRectMake(lastItemWidth, 0.0f, nextItemWidth, itemHeight)];
            if (firstItemWidth != nextItemWidth) {
                // if the width of next item view changes, then recreate it by delegate
                [self->_items[self->_firstItemIndex] clear];
            }
            [self updateItemView:self->_items[self->_firstItemIndex] atIndex:self->_items[self->_firstItemIndex].tag];

            [UIView animateWithDuration:(currentItemWidth / self->_scrollSpeed) delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                CGFloat lastMaxX = 0.0f;
                for (int i = 0; i < self->_items.count; i++) {
                    int index = (i + self->_firstItemIndex) % self->_items.count;

                    CGFloat itemWidth = MAX(self->_items[index].width + self->_itemSpacing, CGRectGetWidth(self.frame));

                    if (i == 0) {
                        continue;
                    } else if (i == 1) {
                        [self->_items[index] setFrame:CGRectMake(-itemWidth, 0.0f, itemWidth, itemHeight)];
                        lastMaxX = 0.0f;
                    } else {
                        [self->_items[index] setFrame:CGRectMake(lastMaxX, 0.0f, itemWidth, itemHeight)];
                        lastMaxX = lastMaxX + itemWidth;
                    }
                }
            } completion:^(BOOL finished) {
                if (finished && self->_scrollTimer) {
                    [self repeat];
                }
            }];
            [self moveToNextItemIndex];
        } else {
            [self moveToNextDataIndex];

            CGFloat itemWidth = CGRectGetWidth(self.frame);
            CGFloat itemHeight = CGRectGetHeight(self.frame) / self->_visibleItemCount;

            // move the top item to bottom without animation
            self->_items[self->_firstItemIndex].tag = self->_dataIndex;
            if (self->_useDynamicHeight) {
                CGFloat firstItemWidth = self->_items[self->_firstItemIndex].height;
                self->_items[self->_firstItemIndex].height = [self itemHeightAtIndex:self->_items[self->_firstItemIndex].tag];
                [self->_items[self->_firstItemIndex] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, self->_items[self->_firstItemIndex].height)];
                if (firstItemWidth != self->_items[self->_firstItemIndex].height) {
                    // if the height of next item view changes, then recreate it by delegate
                    [self->_items[self->_firstItemIndex] clear];
                }
            } else {
                [self->_items[self->_firstItemIndex] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, itemHeight)];
            }
            [self updateItemView:self->_items[self->_firstItemIndex] atIndex:self->_items[self->_firstItemIndex].tag];

            if (self->_useDynamicHeight) {
                int lastItemIndex = (int)(self->_items.count - 1 + self->_firstItemIndex) % self->_items.count;
                CGFloat lastItemHeight = self->_items[lastItemIndex].height;
                [UIView animateWithDuration:(lastItemHeight / self->_scrollSpeed) delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                    for (int i = 0; i < self->_items.count; i++) {
                        int index = (i +self-> _firstItemIndex) % self->_items.count;
                        if (i == 0) {
                            continue;
                        } else if (i == 1) {
                            [self->_items[index] setFrame:CGRectMake(CGRectGetMinX(self->_items[index].frame),
                                                               CGRectGetMinY(self->_items[index].frame) - lastItemHeight,
                                                               itemWidth,
                                                               self->_items[index].height)];
                            self->_items[index].alpha = 0.0f;
                        } else {
                            [self->_items[index] setFrame:CGRectMake(CGRectGetMinX(self->_items[index].frame),
                                                               CGRectGetMinY(self->_items[index].frame) - lastItemHeight,
                                                               itemWidth,
                                                               self->_items[index].height)];
                            self->_items[index].alpha = 1.0f;
                        }
                    }
                } completion:^(BOOL finished) {
                    if (finished && self->_scrollTimer) {
                        [self repeat];
                    }
                }];
            } else {
                [UIView animateWithDuration:self->_timeDurationPerScroll animations:^{
                    for (int i = 0; i < self->_items.count; i++) {
                        int index = (i + self->_firstItemIndex) % self->_items.count;
                        if (i == 0) {
                            continue;
                        } else if (i == 1) {
                            [self->_items[index] setFrame:CGRectMake(0.0f, -itemHeight, itemWidth, itemHeight)];
                        } else {
                            [self->_items[index] setFrame:CGRectMake(0.0f, itemHeight * (i - 2), itemWidth, itemHeight)];
                        }
                    }
                } completion:^(BOOL finished) {
                    if (finished && self->_scrollTimer) {
                        [self repeat];
                    }
                }];
            }

            [self moveToNextItemIndex];
        }
    });
}

#pragma mark - Data source(private)
- (void)moveToNextDataIndex {
    NSUInteger dataCount = 0;
    if ([_delegate respondsToSelector:@selector(numberOfDataForMarqueeView:)]) {
        dataCount = [_delegate numberOfDataForMarqueeView:self];
    }

    if (dataCount <= 0) {
        self.dataIndex = -1;
    } else {
        self.dataIndex = _dataIndex + 1;
        if (_dataIndex < 0 || _dataIndex > dataCount - 1) {
            self.dataIndex = 0;
        }
    }
}

#pragma mark - Touch handler(private)
- (void)resetTouchReceiver {
    if (_touchEnabled) {
        if (!_touchReceiver) {
            self.touchReceiver = [[UUMarqueeViewTouchReceiver alloc] init];
            _touchReceiver.touchDelegate = self;
            [self addSubview:_touchReceiver];
        } else {
            [self bringSubviewToFront:_touchReceiver];
        }
    } else {
        if (_touchReceiver) {
            [_touchReceiver removeFromSuperview];
            self.touchReceiver = nil;
        }
    }
}

#pragma mark - UUMarqueeViewTouchResponder(private)
- (void)touchAtPoint:(CGPoint)point {
    for (UUMarqueeItemView *itemView in _items) {
        if ([itemView.layer.presentationLayer hitTest:point]) {
            NSUInteger dataCount = 0;
            if ([_delegate respondsToSelector:@selector(numberOfDataForMarqueeView:)]) {
                dataCount = [_delegate numberOfDataForMarqueeView:self];
            }

            if (dataCount > 0 && itemView.tag >= 0 && itemView.tag < dataCount) {
                if ([self.delegate respondsToSelector:@selector(didTouchItemViewAtIndex:forMarqueeView:)]) {
                    [self.delegate didTouchItemViewAtIndex:itemView.tag forMarqueeView:self];
                }
            }
            break;
        }
    }
}

@end

#pragma mark - UUMarqueeViewTouchReceiver(private)
@implementation UUMarqueeViewTouchReceiver

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    if (_touchDelegate) {
        [_touchDelegate touchAtPoint:touchLocation];
    }
}

@end

#pragma mark - UUMarqueeItemView(Private)
@implementation UUMarqueeItemView

- (void)clear {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _didFinishCreate = NO;
}

@end
