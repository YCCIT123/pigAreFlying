//
//  TodayViewController.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/25.
//

import SnapKit
import UIKit

final class TodayViewController: BaseFeatureViewController {

    // 任务列表的布局管理
    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    /** 任务列表*/
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionLayout)
        // 使用代码创建的 Cell
        view.register(TodayCollectionViewCell.self, forCellWithReuseIdentifier: "TodayCollectionViewCell")
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
    }
}

// MARK: - UI

private extension TodayViewController {
    /** 添加视图*/
    func setUI(){
        self.view.addSubview(self.collectionView)
        self.layoutUI()
    }
    /** 设置布局*/
    func layoutUI(){
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
}

// MARK: - Delegate

extension TodayViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodayCollectionViewCell", for: indexPath) as? TodayCollectionViewCell
        return cell ?? UICollectionViewCell()
    }
}
