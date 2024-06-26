import UIKit

// MARK: - MainViewController
final class MainViewController: UIViewController {
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showOnboardingOrMainScreen()
    }
    
    // MARK: Private methods
    
    private func showOnboardingOrMainScreen() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("[MainViewController/showOnboardingOrMainScreen()]: appDelegate Invalid Configuration")
            return
        }
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if hasLaunchedBefore {
            appDelegate.window?.rootViewController = TabBarController()
        } else {
            appDelegate.window?.rootViewController = OnboardingViewController()
        }
    }
}
