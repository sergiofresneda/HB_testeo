import Foundation
import UIKit

final class BankViewController: UIViewController {
    let viewModel: BankViewModel

    init(viewModel: BankViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
