//
//  ViewController.swift
//  KieCycleScrollViewDemo
//
//  Created by 俞诚恺 on 16/6/16.
//  Copyright © 2016年 Kie. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController, CycleScrollViewDelgate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view1 = CycleScrollView()
        let imageArray = ["https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
                           "https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
                            "http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg"
                               ]
        
        view1.interval = 2
        view1.addImageArray(imageArray)
        view1.delgate = self
        
        view.addSubview(view1)
        
        view1.frame = CGRectMake(0, 0, 400, 200)
    }

    func didSelAction(index: Int) {
        print("-------------------------\(index)")
    }
}

