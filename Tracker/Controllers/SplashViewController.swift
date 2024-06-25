import UIKit

class SplashViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switchToTrackerController()
    }
}

extension SplashViewController {
    private func switchToTrackerController() {
        guard let window = UIApplication.shared.windows.first else {
            print("[SplashViewController/switchToTrackerController()]: Window Invalid Configuration")
            return
        }

                
        let tabBarController = MainViewController()
        window.rootViewController = tabBarController
//        let tabBarController = TabBarController()
//        window.rootViewController = tabBarController
    }
}



