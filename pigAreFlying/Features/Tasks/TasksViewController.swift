//
//  TasksViewController.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/25.
//

import SnapKit
import UIKit

final class TasksViewController: BaseFeatureViewController {
    /// 页面主标题。
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.text = "Tasks"
        return label
    }()

    /// 页面副标题。
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "这个页面单独管理任务列表和任务操作，不再依赖公共展示模板。"
        return label
    }()

    /// 任务列表占位卡片。
    private lazy var inboxCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        return view
    }()

    /// 任务列表卡片标题。
    private lazy var inboxTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.text = "任务收集箱"
        return label
    }()

    /// 任务列表卡片描述。
    private lazy var inboxDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "这里后续可以直接接任务列表、筛选条件和详情跳转。"
        return label
    }()

    /// 新建任务按钮。
    private lazy var addTaskButton: UIButton = {
        var configuration = UIButton.Configuration.borderedProminent()
        configuration.title = "新建任务"

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
        view.addSubview(inboxCardView)
        inboxCardView.addSubview(inboxTitleLabel)
        inboxCardView.addSubview(inboxDescriptionLabel)
        view.addSubview(addTaskButton)
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

        inboxCardView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        inboxTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }

        inboxDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(inboxTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }

        addTaskButton.snp.makeConstraints { make in
            make.top.equalTo(inboxCardView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
}
