//
//  InsightsViewController.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/25.
//

import UIKit
import SnapKit

final class InsightsViewController: BaseFeatureViewController {
    /// 页面主标题。
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.text = "Insights"
        return label
    }()
    /// 页面副标题。
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "统计页现在独立维护自己的内容，后面接图表和报表时不需要回到基类改模板。"
        return label
    }()
    /// 统计结果卡片。
    private lazy var reportCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        return view
    }()
    /// 统计结果标题。
    private lazy var reportTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.text = "本周完成数"
        return label
    }()
    /// 统计结果数值。
    private lazy var reportValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = .label
        label.text = "0"
        return label
    }()
    /// 统计结果说明。
    private lazy var reportDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "这里先留一个单独的统计卡片，后续可以扩展趋势图、周报和完成率。"
        return label
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
        view.addSubview(reportCardView)
        reportCardView.addSubview(reportTitleLabel)
        reportCardView.addSubview(reportValueLabel)
        reportCardView.addSubview(reportDescriptionLabel)
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

        reportCardView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        reportTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }

        reportValueLabel.snp.makeConstraints { make in
            make.top.equalTo(reportTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        reportDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(reportValueLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }
    }
}
