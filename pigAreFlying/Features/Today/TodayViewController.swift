//
//  TodayViewController.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/25.
//

import UIKit
import SnapKit

final class TodayViewController: BaseFeatureViewController {
    /// 页面主标题。
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.text = "Today"
        return label
    }()
    /// 页面副标题。
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "这个页面只负责今日内容，后续你可以继续往这里加日程、摘要和快捷入口。"
        return label
    }()
    /// 今日概览卡片。
    private lazy var summaryCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        return view
    }()
    /// 今日概览卡片标题。
    private lazy var summaryTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.text = "今日概览"
        return label
    }()
    /// 今日概览卡片描述。
    private lazy var summaryDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "当前还没有接入业务数据，这里先保留一个独立区域给今日任务、提醒和统计。"
        return label
    }()
    /// 今日页面的主操作按钮。
    private lazy var addButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "添加今日内容"

        let button = UIButton(type: .system)
        button.configuration = configuration
        button.addTarget(self, action: #selector(self.testAction), for: .touchUpInside)
        return button
    }()

    /// 页面加载完成后的入口。
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        setupConstraints()
    }

    /// 配置页面的视图层级。
    private func setupViewHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(summaryCardView)
        summaryCardView.addSubview(summaryTitleLabel)
        summaryCardView.addSubview(summaryDescriptionLabel)
        view.addSubview(addButton)
    }

    /// 配置页面约束。
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        summaryCardView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        summaryTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }

        summaryDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(summaryTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }

        addButton.snp.makeConstraints { make in
            make.top.equalTo(summaryCardView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    
    /// 触发跨 Tab 的专注会话路由演示。
    @objc private func testAction() {
        YGDRouterManager.shared.open("pig://focus/session?id=1&userName=aaaa", extraParams: ["from": "home"], style: .switchTabAndPopToExisting)
    }
}
