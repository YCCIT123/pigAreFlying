//
//  FocusSessionViewController.swift
//  YGDFocusModule
//
//  Created by yangchengcheng on 2026/6/4.
//

import SnapKit
import UIKit
import YGDUIKitKit
import YGDRouterKit

/// 专注会话详情页控制器。
final class FocusSessionViewController: BaseFeatureViewController, YGDRouteStackIdentifiable {
    /// 路由目标。
    private let target: YGDRouteTarget

    /// 当前页面对应的业务路由主键。
    var routeKey: String {
        target.routeKey
    }

    /// 当前页面的业务身份标识。
    var routeIdentity: String? {
        target.identity
    }

    /// 页面主标题标签。
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.text = "Focus Session"
        return label
    }()

    /// 页面说明标签。
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "专注会话路由页面，用于验证跨模块跳转和已有页面回退。"
        return label
    }()

    /// 路由参数展示标签。
    private lazy var paramsLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = formattedParamsText()
        return label
    }()

    /// 创建专注会话详情页。
    init(target: YGDRouteTarget) {
        self.target = target
        super.init(nibName: nil, bundle: nil)
    }

    /// 兼容 storyboard 初始化入口。
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 页面加载完成后的入口。
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViewHierarchy()
        setupConstraints()
    }

    /// 将路由参数格式化为可阅读文本。
    private func formattedParamsText() -> String {
        guard target.params.isEmpty == false else { return "params: (empty)" }
        return target.params
            .sorted { $0.key < $1.key }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
    }

    /// 配置页面视图层级。
    private func setupViewHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(paramsLabel)
    }

    /// 配置页面约束。
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        paramsLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}

