//
//  SettingsViewController.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/25.
//

import UIKit
import SnapKit

final class SettingsViewController: BaseFeatureViewController {
    /// 页面主标题。
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.text = "Settings"
        return label
    }()
    /// 页面副标题。
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "设置页现在单独维护自己的内容区域，后面可以直接往这里加账号、偏好和调试功能。"
        return label
    }()
    /// 设置内容卡片。
    private lazy var settingsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        return view
    }()
    /// 设置项标题。
    private lazy var settingsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.text = "页面设置"
        return label
    }()
    /// 设置项说明。
    private lazy var settingsDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "这里先保留一个独立设置卡片，后续可以继续拆成账号设置、提醒设置和通用配置。"
        return label
    }()
    /// 管理设置按钮。
    private lazy var manageButton: UIButton = {
        var configuration = UIButton.Configuration.bordered()
        configuration.title = "管理设置"

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
        view.addSubview(settingsCardView)
        settingsCardView.addSubview(settingsTitleLabel)
        settingsCardView.addSubview(settingsDescriptionLabel)
        view.addSubview(manageButton)
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

        settingsCardView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        settingsTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }

        settingsDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(settingsTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }

        manageButton.snp.makeConstraints { make in
            make.top.equalTo(settingsCardView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
}
