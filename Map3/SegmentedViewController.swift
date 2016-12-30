
import UIKit

class SegmentedViewController: UIViewController {
    
    @IBOutlet private weak var segmentedControl:UISegmentedControl!
    @IBOutlet private weak var infoContainerView:UIView!
    @IBOutlet private weak var codeContainerView:UIView!
    
    
    
    var filenames:[String]!
    var folderName:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Navigation
    
    
    //MARK: - Actions
    
    @IBAction func valueChanged(sender: UISegmentedControl) {
        self.infoContainerView.isHidden = (sender.selectedSegmentIndex == 1)
    }
    
}
