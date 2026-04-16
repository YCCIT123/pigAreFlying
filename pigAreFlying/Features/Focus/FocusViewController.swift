//
//  FocusViewController.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/25.
//

import SnapKit
import UIKit

final class FocusViewController: BaseFeatureViewController {
    /// 页面主标题。
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.text = "Focus"
        return label
    }()

    /// 页面副标题。
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "这个页面现在只承载专注页本身，后续可以独立追加计时器、白噪音和状态管理。"
        return label
    }()

    /// 专注状态卡片。
    private lazy var sessionCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        return view
    }()

    /// 倒计时标签。
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 40, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "25:00"
        return label
    }()

    /// 专注说明标签。
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "当前没有进行中的专注会话，开始按钮后面可以直接接你的专注逻辑。"
        return label
    }()

    /// 开始专注按钮。
    private lazy var startButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "开始专注"

        let button = UIButton(type: .system)
        button.configuration = configuration
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
        view.addSubview(sessionCardView)
        sessionCardView.addSubview(timerLabel)
        sessionCardView.addSubview(statusLabel)
        view.addSubview(startButton)
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

        sessionCardView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        timerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(timerLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }

        startButton.snp.makeConstraints { make in
            make.top.equalTo(sessionCardView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
}
