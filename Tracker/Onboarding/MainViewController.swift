import UIKit

// Используйте OnboardingViewController в вашем основном ViewController
class MainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let onboardingViewController = OnboardingViewController()
        addChild(onboardingViewController)
        view.addSubview(onboardingViewController.view)
        onboardingViewController.didMove(toParent: self)

        onboardingViewController.view.frame = view.bounds
    }
}

class OnboardingViewController: UIPageViewController {

    lazy var pages: [UIViewController] = {
        return [
            self.viewController(imageNamed: "onboard1", textLabel: "Отслеживайте только то, что хотите"),
            self.viewController(imageNamed: "onboard2", textLabel: "Даже если это не литры воды и йога")
        ]
    }()
    
    private let pageControl = UIPageControl()

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        setupPageControl()
    }
    
    @objc func onboardingButtonClicked() {
        // Действие при нажатии на кнопку
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134)
        ])
    }
    
    private func viewController(imageNamed imageName: String, textLabel text: String) -> UIViewController {
        let viewController = UIViewController()
        
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.numberOfLines = 2
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        textLabel.textColor = .black
        textLabel.translatesAutoresizingMaskIntoConstraints = false
    
        let button = UIButton()
        button.accessibilityIdentifier = "onboardingButton"
        button.backgroundColor = .black
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(onboardingButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        
        viewController.view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        
        viewController.view.addSubview(button)
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -20)
        ])
        
        viewController.view.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            textLabel.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -160),
            textLabel.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -16)
        ])
        
        return viewController
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil }
        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else { return nil }
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    // Переключаем индикатор текущей страницы через делегат
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}


