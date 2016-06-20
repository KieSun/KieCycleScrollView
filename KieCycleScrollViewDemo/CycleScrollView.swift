//
//  CycleScrollView.swift
//  KieCycleScrollViewDemo
//
//  Created by 俞诚恺 on 16/6/16.
//  Copyright © 2016年 Kie. All rights reserved.
//

import UIKit
import Foundation
import Kingfisher
import SnapKit

/**
 滑动方向枚举
 - KieScrollDirectionVertical:   垂直
 - KieScrollDirectionHorizontal: 水平
 */
enum  KieScrollDirection{
    // 首字母小写因为 Swift3 官方 API 将枚举 case 都改成这样了，学习官方
    case vertical
    case horizontal
}

// 点击 cell 协议
protocol CycleScrollViewDelgate {
    func didSelAction(index: Int) -> ()
}

class CycleScrollView: UIView {
    
    // ***************************** public property **********************************
    var delgate: CycleScrollViewDelgate?
    
    /// 图片数组
    var imageArray = [String]()
    
    /// 添加图片数据
    func addImageArray(imageArray: Array<String>) {
        self.imageArray = imageArray
        self.pageController.numberOfPages = imageArray.count
        collectionView.reloadData()
    }
    
    /// 定时器事件，为0时定时器不运行
    internal var interval: NSTimeInterval = 0 {
        didSet {
            removerTimer()
            if interval > 0 {
                addTimer()
            }
        }
    }
    
    /// 是否能滚动，默认为 true
    internal var scrollEnable: Bool = true {
        didSet {
            collectionView.scrollEnabled = scrollEnable
        }
    }
    
    /// 上一次偏移量
    private var oldOffset = CGFloat()
    
    /// 控制器滑动方向，默认水平
    var scrollDirection: KieScrollDirection = .horizontal {
        didSet {
            if scrollDirection != oldValue {
                if scrollDirection == .horizontal {
                    flowLayout.scrollDirection = .Horizontal
                } else {
                    flowLayout.scrollDirection = .Vertical
                }
                collectionView.reloadData()
            }
        }
    }
    
    /// 移除定时器
    func removerTimer() {
        timer.invalidate()
    }
    
    // ***************************** UI **********************************
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .Horizontal
        return flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: self.bounds, collectionViewLayout: self.flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.pagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerNib(UINib.init(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CollectionViewCell.identifier)
        return collectionView
    }()
    
    private lazy var pageController: UIPageControl = {
        let pageController = UIPageControl()
        pageController.numberOfPages = self.imageArray.count
        pageController.currentPage = 0
        pageController.backgroundColor = UIColor.clearColor()
        pageController.currentPageIndicatorTintColor = UIColor.whiteColor()
        pageController.pageIndicatorTintColor = UIColor.lightGrayColor()
        return pageController
    }()
    
    /// 添加子视图
    private func setupSubview() {
        addSubview(collectionView)
        addSubview(pageController)
    }
    
    // ***************************** cycle life **********************************
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
        collectionView.snp_makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self)
        }
        pageController.snp_makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        flowLayout.itemSize = self.bounds.size
    }
    
    // ***************************** custom **********************************
    
    /// 定时器
    private  var timer: NSTimer = NSTimer()
    
    /// 添加定时器
    private func addTimer() {
        if imageArray.count == 1 || interval == 0 {
            return
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(self.interval,
                                                       target: self,
                                                       selector: #selector(changePage),
                                                       userInfo: nil,
                                                       repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    /// 定时器运行方法
    @objc private func changePage() {
        var newOffset = currentOffset + viewLength
        if newOffset == offsetContent - viewLength {
            newOffset += 1
        }
        var offset: CGPoint
        if scrollDirection == .horizontal {
            offset = CGPointMake(newOffset, 0)
        }else {
            offset = CGPointMake(0, newOffset)
        }
        collectionView.setContentOffset(offset, animated: true)
    }
    
    /// 可滑动距离
    private var offsetContent: CGFloat {
        if scrollDirection == .horizontal {
            return collectionView.contentSize.width
        } else {
            return collectionView.contentSize.height
        }
    }
    
    /// 目前的偏移量
    private var currentOffset: CGFloat {
        if scrollDirection == .horizontal {
            return collectionView.contentOffset.x
        } else {
            return collectionView.contentOffset.y
        }
    }
    
    /// 控制器长度
    private var viewLength: CGFloat {
        if scrollDirection == .horizontal {
            return CGRectGetWidth(self.frame)
        } else {
            return CGRectGetHeight(self.frame)
        }
    }
    
    /// 获得图片 url
    private func getImageUrl(indexPath: NSIndexPath) -> String? {
        
        if indexPath.row == imageArray.count {
            return imageArray.first
        }else {
            return imageArray[indexPath.row]
        }
    }
}

extension CycleScrollView: UIScrollViewDelegate {
    // 图片滑动逻辑
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if oldOffset > currentOffset {
            // 当前偏移量小于0，滚回最后张图片
            if currentOffset < 0 {
                collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: imageArray.count, inSection: 0), atScrollPosition: .None, animated: false)
            }
        }else {
            // 当前偏移量大于 控制器能滚动的距离减去控制器长度，那么滚回第一张图片
            if currentOffset > offsetContent - viewLength {
                collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .None, animated: false)
            }
        }
        // 当最后张图片滑动到第一张时，改变页码
        if currentOffset > (CGFloat)(imageArray.count - 1) * viewLength {
            pageController.currentPage = 0
        }else {
            pageController.currentPage = (Int)(currentOffset / viewLength)
        }
        oldOffset = currentOffset
    }
    
    // 即将开始拖拽逻辑
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        removerTimer()
    }
    
    // 停止拖拽逻辑
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 计算当前页码
        self.pageController.currentPage = (Int)(currentOffset / viewLength)
        addTimer()
    }
}

extension CycleScrollView: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delgate?.didSelAction(indexPath.row)
    }
}

extension CycleScrollView: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 单个图片不需滚动，多个图片只需要多创建一个 cell 就可以完成无限循环
        if imageArray.count == 1 {
            return 1
        } else {
            return imageArray.count + 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCell.identifier, forIndexPath: indexPath) as! CollectionViewCell
        var url: NSURL?
        if let str = getImageUrl(indexPath) {
            url = NSURL(string: str)!
        }
        guard (url != nil) else {
            return cell
        }
        cell.imageView.kf_setImageWithURL(url!)
        return cell
    }
}
