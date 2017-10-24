

import UIKit

//CONSTANTS:

let kBrightness =       1.0
let kSaturation =       0.45

let kPaletteHeight =    30
let kPaletteSize =    5
let kMinEraseInterval =    0.5

// Padding for margins
let kLeftMargin =    10.0
let kTopMargin =    10.0
let kRightMargin =      10.0



//CLASS IMPLEMENTATIONS:

@objc(PaintingViewController)
class PaintingViewController: UIViewController {
    @IBOutlet var paintView: PaintingView!
    
    private var lastTime: CFTimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a segmented control so that the user can choose the brush color.
        // Create the UIImages with the UIImageRenderingModeAlwaysOriginal rendering mode. This allows us to show the actual image colors in the segmented control.
        let segmentedControl = UISegmentedControl(items: [
            
            UIImage(named: "Red")!.withRenderingMode(.alwaysOriginal),
            UIImage(named: "Yellow")!.withRenderingMode(.alwaysOriginal),
            UIImage(named: "Green")!.withRenderingMode(.alwaysOriginal),
            UIImage(named: "Blue")!.withRenderingMode(.alwaysOriginal),
            UIImage(named: "Purple")!.withRenderingMode(.alwaysOriginal),
            ])
        
        // Compute a rectangle that is positioned correctly for the segmented control you'll use as a brush color palette
        let rect = UIScreen.main.bounds
        let frame = CGRect(x: rect.origin.x + kLeftMargin.g, y: rect.size.height - kPaletteHeight.g - kTopMargin.g, width: rect.size.width - (kLeftMargin + kRightMargin).g, height: kPaletteHeight.g)
        segmentedControl.frame = frame
        // When the user chooses a color, the method changeBrushColor: is called.
        segmentedControl.addTarget(self, action: #selector(PaintingViewController.changeBrushColor(_:)), for: .valueChanged)
        // Make sure the color of the color complements the black background
        segmentedControl.tintColor = UIColor.darkGray
        // Set the third color (index values start at 0)
        segmentedControl.selectedSegmentIndex = 2
        
        // Add the control to the window
        self.paintView.addSubview(segmentedControl)
        // Now that the control is added, you can release it
        
        // Define a starting color
        let color = UIColor(hue: 2.0.g / kPaletteSize.g,
            saturation: kSaturation.g,
            brightness: kBrightness.g,
            alpha: 1.0).cgColor
        if let components = color.components {
        
        // Defer to the OpenGL view to set the brush color
            self.paintView.setBrushColor(red: components[0], green: components[1], blue: components[2])
        } else {
            print("CGColor.components unavailable")
        }
        
        // Load the sounds
        
        
        // Erase the view when recieving a notification named "shake" from the NSNotificationCenter object
        // The "shake" nofification is posted by the PaintingWindow object when user shakes the device
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    // Release resources when they are no longer needed,
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Change the brush color
    @objc func changeBrushColor(_ senderSegment: UISegmentedControl) {
        
        
        // Define a new brush color
        let color = UIColor(hue: senderSegment.selectedSegmentIndex.g / kPaletteSize.g,
            saturation: kSaturation.g,
            brightness: kBrightness.g,
            alpha: 1.0).cgColor
        if let components = color.components {
        
        // Defer to the OpenGL view to set the brush color
            self.paintView.setBrushColor(red: components[0], green: components[1], blue: components[2])
        } else {
            print("CGColor.components unavailable")
        }
    }
    
    // Called when receiving the "shake" notification; plays the erase sound and redraws the view
    @IBAction func clearPressed(_ sender: UIButton) {
        self.eraseView()
    }
    @objc func eraseView() {
        if CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval {
            
            self.paintView.erase()
            lastTime = CFAbsoluteTimeGetCurrent()
        }
    }
    
    // We do not support auto-rotation in this sample
    override var shouldAutorotate : Bool {
        return false
    }
    
    //MARK: Motion
    
   
    
}
