//
//  TodayCollectionViewCell.swift
//  YGDTodayModule
//
//  Created by yangchengcheng on 2026/6/4.
//

import SnapKit
import UIKit

/// Today 任务卡片 Cell。
final class TodayCollectionViewCell: UICollectionViewCell {
    /// 任务标题。
    private lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "标题"
        lab.font = .systemFont(ofSize: 18)
        return lab
    }()

    /// 任务计时。
    private lazy var timeLabel: UILabel = {
        let lab = UILabel()
        lab.text = "任务计时"
        lab.font = .systemFont(ofSize: 16)
        return lab
    }()

    /// 任务状态。
    private lazy var stateLabel: UILabel = {
        let lab = UILabel()
        lab.text = "任务状态"
        lab.font = .systemFont(ofSize: 16)
        return lab
    }()

    /// 任务背景。
    private lazy var bgImage: UIImageView = {
        let img = UIImageView()
        return img
    }()

    /// 初始化任务卡片 Cell。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    /// cell 复用前调用。
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    /// 兼容 storyboard 初始化入口。
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TodayCollectionViewCell {
    /// 设置 UI。
    func setUI() {
        contentView.addSubview(bgImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(stateLabel)
        setLayout()
    }

    /// 设置布局。
    func setLayout() {
        bgImage.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        stateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(10)
            make.right.equalTo(stateLabel.snp.left).offset(-10)
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalTo(titleLabel).offset(0)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
}

