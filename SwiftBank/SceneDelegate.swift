import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let unwrappedScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: unwrappedScene)
        window?.rootViewController = BankViewController(viewModel: BankViewModel())
        window?.makeKeyAndVisible()
    }
}

