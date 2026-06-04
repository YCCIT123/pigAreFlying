//
//  TodayViewController.swift
//  YGDTodayModule
//
//  Created by yangchengcheng on 2026/6/4.
//

import SnapKit
import UIKit
import YGDUIKitKit
import YGDRouterKit

/// Today 首页控制器。
final class TodayViewController: BaseFeatureViewController, YGDRouteStackIdentifiable {
    /// 当前页面对应的业务路由主键。
    var routeKey: String {
        "today/home"
    }

    /// 当前页面的业务身份标识。
    var routeIdentity: String? {
        nil
    }

    /// 任务列表的布局管理。
    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()

    /// 任务列表。
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionLayout)
        view.register(TodayCollectionViewCell.self, forCellWithReuseIdentifier: "TodayCollectionViewCell")
        view.delegate = self
        view.dataSource = self
        return view
    }()

    /// 页面加载完成后的统一入口。
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
}

private extension TodayViewController {
    /// 添加页面视图。
    func setUI() {
        view.addSubview(collectionView)
        layoutUI()
    }

    /// 设置页面布局。
    func layoutUI() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
}

extension TodayViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    /// 返回任务列表分区数量。
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    /// 返回指定分区的任务数量。
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    /// 创建指定位置的任务 Cell。
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodayCollectionViewCell", for: indexPath) as? TodayCollectionViewCell
        return cell ?? UICollectionViewCell()
    }
}

