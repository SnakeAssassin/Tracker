import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .ypBlue
        tabBar.backgroundColor = .ypWhite
        tabBar.layer.borderWidth = 0.50
        tabBar.layer.borderColor = UIColor.ypGray.cgColor
        tabBar.layer.masksToBounds = true
        
        let trackersViewController = TrackersViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "Track"),
            selectedImage: nil)
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "Stats"),
            selectedImage: nil)
        
        self.viewControllers = [trackersNavigationController, statisticsViewController]
    }
}

