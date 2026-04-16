//
//  TodayCollectionViewCell.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/4/14.
//

import UIKit

final class TodayCollectionViewCell: UICollectionViewCell {
    
    // 任务标题
    private lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "标题"
        lab.font = .systemFont(ofSize: 18)
        return lab
    }()
    // 任务计时
    private lazy var timeLabel: UILabel = {
        let lab = UILabel()
        lab.text = "任务计时"
        lab.font = .systemFont(ofSize: 16)
        return lab
    }()
    // 任务状态
    private lazy var stateLabel: UILabel = {
        let lab = UILabel()
        lab.text = "任务状态"
        lab.font = .systemFont(ofSize: 16)
        return lab
    }()
    // 任务背景
    private lazy var bgImage: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI()
    }
    
    // cell复用前调用
    override func prepareForReuse() {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - UI

private extension TodayCollectionViewCell {
    
    /** 设置UI*/
    func setUI(){
        self.contentView.addSubview(self.bgImage)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.timeLabel)
        self.contentView.addSubview(self.stateLabel)
        self.setLayout()
    }
    /** 设置布局*/
    func setLayout() {
        self.bgImage.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        self.stateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(10)
            make.right.equalTo(self.stateLabel.snp.left).offset(-10)
        }
        self.timeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.left.right.equalTo(self.titleLabel).offset(0)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
}
