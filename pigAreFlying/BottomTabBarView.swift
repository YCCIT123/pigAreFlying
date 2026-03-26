//
//  BottomTabBarView.swift
//  pigAreFlying
//
//  Created by Codex on 2026/3/25.
//

import UIKit
import SnapKit

protocol BottomTabBarViewDelegate: AnyObject {
    /// 处理底部标签栏的点击事件。
    func bottomTabBarView(_ bottomTabBarView: BottomTabBarView, didSelect tab: AppTab, repeatedTap: Bool)
}

final class BottomTabBarView: UIView {
    /// 底部标签栏的点击代理。
    weak var delegate: BottomTabBarViewDelegate?

    /// 底部标签栏的背景视图。
    private let backgroundView = UIView()
    /// 底部标签栏的顶部描边。
    private let topSeparatorView = UIView()
    /// 底部标签按钮的承载容器。
    private let itemContainerView = UIView()
    /// Today 标签按钮。
    private let todayItemView = BottomTabBarItemView(tab: .today)
    /// Tasks 标签按钮。
    private let tasksItemView = BottomTabBarItemView(tab: .tasks)
    /// Focus 标签按钮。
    private let focusItemView = BottomTabBarItemView(tab: .focus)
    /// Insights 标签按钮。
    private let insightsItemView = BottomTabBarItemView(tab: .insights)
    /// Settings 标签按钮。
    private let settingsItemView = BottomTabBarItemView(tab: .settings)

    /// 当前选中的标签页。
    private(set) var selectedTab: AppTab = .today

    /// 初始化底部标签栏。
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        installItems()
        applySelection()
    }

    /// 兼容 storyboard 初始化入口。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 更新当前选中的标签页。
    func setSelectedTab(_ tab: AppTab) {
        selectedTab = tab
        applySelection()
    }

    /// 配置底部标签栏的基础视图。
    private func setupView() {
        backgroundView.backgroundColor = .systemBackground
        topSeparatorView.backgroundColor = .separator

        addSubview(backgroundView)
        addSubview(topSeparatorView)
        addSubview(itemContainerView)

        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        topSeparatorView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1.0 / UIScreen.main.scale)
        }

        itemContainerView.snp.makeConstraints { make in
            make.top.equalTo(topSeparatorView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }

    /// 添加底部标签按钮。
    private func installItems() {
        todayItemView.addTarget(self, action: #selector(handleItemTap(_:)), for: .touchUpInside)
        tasksItemView.addTarget(self, action: #selector(handleItemTap(_:)), for: .touchUpInside)
        focusItemView.addTarget(self, action: #selector(handleItemTap(_:)), for: .touchUpInside)
        insightsItemView.addTarget(self, action: #selector(handleItemTap(_:)), for: .touchUpInside)
        settingsItemView.addTarget(self, action: #selector(handleItemTap(_:)), for: .touchUpInside)

        itemContainerView.addSubview(todayItemView)
        itemContainerView.addSubview(tasksItemView)
        itemContainerView.addSubview(focusItemView)
        itemContainerView.addSubview(insightsItemView)
        itemContainerView.addSubview(settingsItemView)

        todayItemView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }

        tasksItemView.snp.makeConstraints { make in
            make.leading.equalTo(todayItemView.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(todayItemView)
        }

        focusItemView.snp.makeConstraints { make in
            make.leading.equalTo(tasksItemView.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(todayItemView)
        }

        insightsItemView.snp.makeConstraints { make in
            make.leading.equalTo(focusItemView.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(todayItemView)
        }

        settingsItemView.snp.makeConstraints { make in
            make.leading.equalTo(insightsItemView.snp.trailing)
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(todayItemView)
        }
    }

    /// 应用当前的选中状态。
    private func applySelection() {
        todayItemView.applySelection(isSelected: selectedTab == .today)
        tasksItemView.applySelection(isSelected: selectedTab == .tasks)
        focusItemView.applySelection(isSelected: selectedTab == .focus)
        insightsItemView.applySelection(isSelected: selectedTab == .insights)
        settingsItemView.applySelection(isSelected: selectedTab == .settings)
    }

    /// 处理标签按钮点击。
    @objc
    private func handleItemTap(_ sender: BottomTabBarItemView) {
        let repeatedTap = sender.tab == selectedTab
        delegate?.bottomTabBarView(self, didSelect: sender.tab, repeatedTap: repeatedTap)
    }
}

private final class BottomTabBarItemView: UIControl {
    /// 当前按钮对应的标签页。
    let tab: AppTab

    /// 标签按钮的图标视图。
    private let iconImageView = UIImageView()
    /// 标签按钮的标题视图。
    private let titleLabel = UILabel()

    /// 初始化标签按钮。
    init(tab: AppTab) {
        self.tab = tab
        super.init(frame: .zero)
        setupView()
    }

    /// 兼容 storyboard 初始化入口。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 应用按钮的选中状态。
    func applySelection(isSelected: Bool) {
        self.isSelected = isSelected

        iconImageView.image = UIImage(systemName: isSelected ? tab.selectedSymbolName : tab.symbolName)
        iconImageView.tintColor = isSelected ? .systemBlue : .secondaryLabel
        titleLabel.textColor = isSelected ? .systemBlue : .secondaryLabel

        accessibilityTraits = isSelected ? [.button, .selected] : [.button]
    }

    /// 配置标签按钮的基础视图。
    private func setupView() {
        backgroundColor = .clear
        accessibilityLabel = tab.title

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)

        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.text = tab.title

        addSubview(iconImageView)
        addSubview(titleLabel)

        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.size.equalTo(18)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(3)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.lessThanOrEqualToSuperview().inset(4)
        }
    }
}
