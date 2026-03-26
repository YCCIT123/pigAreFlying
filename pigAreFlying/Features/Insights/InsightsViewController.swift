//
//  InsinghtsViewController.swift
//  pigAreFlying
//
//  Created by yangchengcheng on 2026/3/25.
//

import UIKit

final class InsinghtsViewController: BaseFeatureViewController {
    override var featureTitleText: String {
        "Insights"
    }

    override var featureDescriptionText: String {
        "Insights is now separated from the shell and ready for charts, trends, and reporting modules. A later cleanup should rename this file and class to the correct Insights spelling across the project."
    }

    override var featureSymbolName: String {
        "chart.bar.fill"
    }

    override var featureAccentColor: UIColor {
        AppTab.insights.tintColor
    }
}
