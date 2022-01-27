import UIKit

var viewWithSpinner: UIView?

extension UIViewController {
    func showSpinner(onView: UIView) {
        let spinnerView = UIView(frame: onView.bounds)
        spinnerView.backgroundColor = .black.withAlphaComponent(0.2)
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        activityIndicator.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(activityIndicator)
            onView.addSubview(spinnerView)
        }
        
        viewWithSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            viewWithSpinner?.removeFromSuperview()
            viewWithSpinner = nil
        }
    }
}
