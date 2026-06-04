//
//  YGDDetailPageViewController.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/5/9.
//

import SnapKit
import UIKit

/// 通用详情页配置。
struct YGDDetailPageConfig {
    /// 页面标题。
    let title: String

    /// 页面说明文字。
    let description: String

    /// 页面所属的路由主键，用于 YGDRouteStackIdentifiable。
    let routeKey: String

    /// 跳转下一级的路由地址，为 nil 时不展示导航按钮。
    let nextRoute: String?

    /// 导航按钮标题，默认"下一级"。
    let nextButtonTitle: String
}

/// 通用详情页，复用于所有二级及更深层级页面。
final class YGDDetailPageViewController: BaseFeatureViewController, YGDRouteStackIdentifiable {
    /// 页面配置。
    private let config: YGDDetailPageConfig

    /// 路由目标。
    private let target: YGDRouteTarget

    /// 当前页面对应的业务路由主键。
    var routeKey: String { config.routeKey }
    /// 当前页面的业务身份标识。
    var routeIdentity: String? { target.identity }

    /// 页面主标题标签。
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.text = config.title
        return label
    }()

    /// 页面说明标签。
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = config.description
        return label
    }()

    /// 路由信息卡片。
    private lazy var infoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        return view
    }()

    /// 路由主键展示标签。
    private lazy var routeKeyLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "routeKey: \(config.routeKey)"
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

    /// 跳转下一级页面按钮。
    private lazy var nextButton: UIButton = {
        var configuration = UIButton.Configuration.borderedProminent()
        configuration.title = config.nextButtonTitle
        let button = UIButton(type: .system)
        button.configuration = configuration
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()

    /// 创建通用详情页。
    init(target: YGDRouteTarget, config: YGDDetailPageConfig) {
        self.target = target
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }

    /// `UIViewController` 的解码初始化方法。
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 页面加载完成后的统一入口。
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViewHierarchy()
        setupConstraints()
    }

    /// 跳转下一级路由页面。
    @objc private func nextButtonTapped() {
        guard let nextRoute = config.nextRoute else { return }
        YGDRouterManager.shared.open(nextRoute)
    }

    /// 将路由参数字典格式化为可阅读文本。
    private func formattedParamsText() -> String {
        guard target.params.isEmpty == false else { return "params: (empty)" }
        return target.params
            .sorted { $0.key < $1.key }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
    }
}

private extension YGDDetailPageViewController {
    /// 配置页面视图层级。
    func setupViewHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(infoCardView)
        infoCardView.addSubview(routeKeyLabel)
        infoCardView.addSubview(paramsLabel)

        if config.nextRoute != nil {
            view.addSubview(nextButton)
        }
    }

    /// 配置页面约束。
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        infoCardView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        routeKeyLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }

        paramsLabel.snp.makeConstraints { make in
            make.top.equalTo(routeKeyLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }

        if config.nextRoute != nil {
            nextButton.snp.makeConstraints { make in
                make.top.equalTo(infoCardView.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(20)
                make.height.equalTo(50)
            }
        }
    }
}
