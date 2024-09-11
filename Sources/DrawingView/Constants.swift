import Foundation
import UIKit


@available(iOS 13.0, *)
struct Icons
{
    static let pencilSelected = UIImage(named: "PencilSelected", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    static let colorSelected = UIImage(named: "ColorSelected", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    static let markerSelected = UIImage(named: "MarkerSelected", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    static let eraserSelected = UIImage(named: "EraserSelected", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    
    static let pencilUnselected = UIImage(named: "PencilUnselected", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    static let colorUnSelected = UIImage(named: "ColorUnSelected", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    static let markerUnSelected = UIImage(named: "MarkerUnSelected", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    static let eraserUnSelected = UIImage(named: "EraserUnSelected", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
}



extension UIApplication {
    var statusBarView: UIView? {
        if #available(iOS 13.0, *) {
            let tag = 38482458385
            if let statusBar = self.keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
                statusBarView.tag = tag
                
                self.keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        } else {
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
        }
        return nil
    }
}

extension String
{
    func trim() -> String
    {
        self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
