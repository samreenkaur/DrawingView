// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import AVFoundation
import Photos
import MobileCoreServices
import SDWebImage

public protocol DrawingViewControllerDelegate: AnyObject
{
    func drawnImage(_ image: UIImage?)
}

@available(iOS 13.0, *)
public class DrawingViewController: UIViewController {
    
    
    
    //MARK: Variables
    var colorSlider: ColorSlider?
    var selectedColor: UIColor = .black
    var lastPoint = CGPoint.zero
    var previousPoint1 = CGPoint()
    var previousPoint2 = CGPoint()
    var addedPointsStack = [UIImage]()
    var undonePointsStack = [UIImage]()
    var eraserSelected = false
    var swiped = false
    
    public var brushWidth: CGFloat = 1.0
    public var opacity: CGFloat = 1.0
    public weak var delegate: DrawingViewControllerDelegate?
    public var lastURL: URL?
    public var lastDrawing: UIImage?
    public var navTitle: String?
    public var navButtonsTint: UIColor = .black
    public var buttonsPadding: CGFloat = 8.0
    public var buttonsHeight: CGFloat = 40.0
    public var buttonsTint: UIColor = .black
    public var barTintColor: UIColor? = .white
    public var selectedDrawableColor: UIColor?
    public var unselectedDrawableColor: UIColor?
    public var showBorders = true
    public var showShadows = true
    public var showExtraBlackWhite = true
    
    private let mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let tempImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let pencilButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Icons.pencilSelected, for: .normal)
        button.addTarget(self, action: #selector(pencilButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let colorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Icons.colorUnSelected, for: .normal)
        button.addTarget(self, action: #selector(colorButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let markerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Icons.markerUnSelected, for: .normal)
        button.addTarget(self, action: #selector(markerButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let eraserButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Icons.eraserUnSelected, for: .normal)
        button.addTarget(self, action: #selector(eraserButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [pencilButton, colorButton, markerButton, eraserButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .bottom
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Create right panel view programmatically
    private lazy var rightStackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let currentColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.backgroundColor = .black // Set to appropriate color or image
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 20 // Half of the height to make it round
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(currentColorButtonTapped), for: .touchUpInside)
        button.clipsToBounds = true
        
        return button
    }()
    
    private let blackColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 20 // Half of the height to make it round
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(blackColorButtonTapped), for: .touchUpInside)
        button.clipsToBounds = true
        
        return button
    }()
    
    private let whiteColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 20 // Half of the height to make it round
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(whiteColorButtonTapped), for: .touchUpInside)
        button.clipsToBounds = true
        
        return button
    }()
    
    private let colorSliderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 20 // Half of the height to make it round
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        
        return view
    }()
    
    
    private let undoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.uturn.left"), for: .normal) // Arrow back icon
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(undoButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private let redoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.uturn.right"), for: .normal) // Arrow forward icon
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(redoButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.app"), for: .normal) // Arrow forward icon
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var leftStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cameraButton, undoButton, redoButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        
        // Set its properties
        activityIndicator.center = self.view.center  // Center the activity indicator
        activityIndicator.color = .gray  // Set color (optional)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    
    
    //MARK: LifeCycle Functions
    //    public static func instantiateFromStoryboard() -> DrawingViewController? {
    //        // Obtain the bundle where this class is located
    //        // Access the correct bundle if in a framework
    //        for bundle in Bundle.allBundles {
    //            print("Bundle: \(bundle.bundlePath)")
    //        }
    //                guard let bundleURL = Bundle(for: DrawingViewController.self).url(forResource: "DrawingView", withExtension: "bundle"),
    //                      let bundle = Bundle(url: bundleURL) else {
    //                    print("Failed to load bundle")
    //                    return nil
    //                }
    //
    //                // Initialize the storyboard using the correct bundle
    //                let storyboard = UIStoryboard(name: "Storyboard", bundle: bundle)
    //
    //
    //        return storyboard.instantiateViewController(withIdentifier: "DrawingViewController") as? DrawingViewController
    //    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        
        if let lastURL = lastURL
        {
            undonePointsStack = []
            self.startLoading()
            mainImageView.sd_setImage(with:lastURL, placeholderImage: nil,
                                      options: [],
                                      completed: { (image, error,cacheType, url) in
                if let image = image
                {
                    let stackimage = image
                    stackimage.accessibilityIdentifier = "\(1.0)"
                    self.addedPointsStack.append(stackimage)
                    self.resetDrawing()
                }
                self.stopLoading()
            })
        }
        else if let lastDrawing = lastDrawing
        {
            undonePointsStack = []
            let stackimage = lastDrawing
            stackimage.accessibilityIdentifier = "\(1.0)"
            self.addedPointsStack.append(stackimage)
            self.resetDrawing()
        }
        
        // Register for orientation change notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    @objc func handleOrientationChange() {
        // Recreate colorSlider when orientation changes
        currentColorButton.tag = 0
        blackColorButton.isHidden = true
        whiteColorButton.isHidden = true
        colorSliderView.isHidden = true
        
        setupColorSlider()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavBar()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        swiped = false
        lastPoint = touch.location(in: view)
        previousPoint1 = touch.previousLocation(in: view)
        
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        // 6
        swiped = true
        
        previousPoint2 = previousPoint1
        previousPoint1 = touch.previousLocation(in: view)
        let currentPoint = touch.location(in: view)
        
        drawLine(from: lastPoint, to: currentPoint)
        
        // 7
        lastPoint = currentPoint
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawDot(at: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
        tempImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var stackimage = tempImageView.image ?? UIImage()
        stackimage.accessibilityIdentifier = "\(opacity)"
        addedPointsStack.append(stackimage)
        undonePointsStack.removeAll()
        tempImageView.image = nil
    }
    
    //MARK: Public Functions
    @objc func crossButtonTapped(_ sender: UIButton)
    {
        //        self.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tickButtonTapped(_ sender: UIButton)
    {
        if let delegate = delegate
        {
            delegate.drawnImage(mainImageView.image)
            //            self.dismiss(animated: true)
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton)
    {
        if #available(iOS 14.0, *) {
            self.showActionSheet(button: sender, pickerDelegate: self, allowsEditing: true, excludeVideos: true)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func pencilButtonTapped(_ sender: UIButton)
    {
        eraserSelected = false
        self.brushWidth = 1.0
        self.opacity = 1.0
        setupPencilButtons(sender)
    }
    
    @IBAction func colorButtonTapped(_ sender: UIButton)
    {
        eraserSelected = false
        self.brushWidth = 5.0
        self.opacity = 1.0
        setupPencilButtons(sender)
    }
    
    @IBAction func markerButtonTapped(_ sender: UIButton)
    {
        eraserSelected = false
        self.brushWidth = 10.0
        self.opacity = 0.5
        setupPencilButtons(sender)
    }
    
    @IBAction func eraserButtonTapped(_ sender: UIButton)
    {
        eraserSelected = true
        self.brushWidth = 10.0
        self.opacity = 1.0
        setupPencilButtons(sender)
    }
    
    @IBAction func undoButtonTapped(_ sender: UIButton)
    {
        if let last = addedPointsStack.last
        {
            undonePointsStack.append(last)
            addedPointsStack = addedPointsStack.dropLast()
            resetDrawing()
        }
    }
    
    @IBAction func redoButtonTapped(_ sender: UIButton)
    {
        if let last = undonePointsStack.last
        {
            addedPointsStack.append(last)
            undonePointsStack = undonePointsStack.dropLast()
            resetDrawing()
        }
    }
    
    @IBAction func currentColorButtonTapped(_ sender: UIButton)
    {
        if sender.tag == 0
        {
            sender.tag = 1
            blackColorButton.isHidden = false
            whiteColorButton.isHidden = false
            colorSliderView.isHidden = false
            setupColorSlider()
            
        }
        else
        {
            sender.tag = 0
            blackColorButton.isHidden = true
            whiteColorButton.isHidden = true
            colorSliderView.isHidden = true
        }
    }
    
    
    @IBAction func blackColorButtonTapped(_ sender: UIButton)
    {
        setColor(.black)
    }
    
    @IBAction func whiteColorButtonTapped(_ sender: UIButton)
    {
        setColor(.white)
    }
    
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        // 1
        
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        tempImageView.image?.draw(in: view.bounds)
        
        
        // calculate mid point
        let mid1 = midPoint(p1: previousPoint1, p2: previousPoint2)
        let mid2 = midPoint(p1: toPoint, p2: previousPoint1)
        
        // 2
        context.move(to: mid1)
        //        context.addLine(to: mid2)
        context.addQuadCurve(to: mid2, control: previousPoint1)
        
        // 3
        context.setLineCap(.butt)
        context.setBlendMode(.normal)
        context.setLineWidth(brushWidth)
        
        if eraserSelected
        {
            context.setStrokeColor(UIColor.white.cgColor)
        }
        else
        {
            context.setStrokeColor(selectedColor.withAlphaComponent(opacity).cgColor)
        }
        
        // 4
        context.strokePath()
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    
    func drawDot(at atPoint: CGPoint) {
        // 1
        
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        tempImageView.image?.draw(in: view.bounds)
        
        // 2
        context.move(to: atPoint)
        context.addLine(to: atPoint)
        
        // 3
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(brushWidth)
        
        if eraserSelected
        {
            context.setStrokeColor(UIColor.white.cgColor)
        }
        else
        {
            context.setStrokeColor(selectedColor.withAlphaComponent(opacity).cgColor)
        }
        
        // 4
        context.strokePath()
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2.0, y: (p1.y + p2.y) / 2.0)
    }
    
    
    //MARK: Private Functions
    private func setup()
    {
        addOutlets()
        setupContraints()
        setupLayout()
        
        colorSliderView.isHidden = true
        if showExtraBlackWhite
        {
            blackColorButton.isHidden = true
            whiteColorButton.isHidden = true
        }
        currentColorButton.isHidden = false
        
        colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)
        
        setupColorSlider()
        
        setColor(selectedColor)
        setupPencilButtons(pencilButton)
    }
    
    private func setupNavBar()
    {
        self.title = navTitle
        
        if let barTintColor = barTintColor
        {
            UIApplication.shared.statusBarView?.backgroundColor = barTintColor
            
            self.navigationController?.navigationBar.backgroundColor = barTintColor
        }
        
        let crossButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(crossButtonTapped))
        let tickButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(tickButtonTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        
        crossButton.tintColor = navButtonsTint
        tickButton.tintColor = navButtonsTint
        
        space.width = 0
        // assign your custom view to left/right bar button item
        navigationItem.rightBarButtonItems = [tickButton,
                                              space,
                                              crossButton]
    }
    
    private func addOutlets()
    {
        self.view.backgroundColor = .white
        // Add the image view to the view hierarchy
        view.addSubview(mainImageView)
        view.addSubview(tempImageView)
        view.addSubview(bottomStackView)
        view.addSubview(rightStackView)
        view.addSubview(leftStackView)
        
        // Add buttons and color slider to rightStackView
        rightStackView.addSubview(colorSliderView)
        
        if showExtraBlackWhite == true
        {
            rightStackView.addSubview(blackColorButton)
            rightStackView.addSubview(whiteColorButton)
        }
        rightStackView.addSubview(currentColorButton)
        
        self.view.addSubview(activityIndicator)
    }
    
    private func setupContraints()
    {
        
        // Set up constraints for mainImageView
        NSLayoutConstraint.activate([
            mainImageView.topAnchor.constraint(equalTo: view.topAnchor),
            mainImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Set up constraints for tempImageView to match mainImageView's frame
        NSLayoutConstraint.activate([
            tempImageView.topAnchor.constraint(equalTo: mainImageView.topAnchor),
            tempImageView.leadingAnchor.constraint(equalTo: mainImageView.leadingAnchor),
            tempImageView.trailingAnchor.constraint(equalTo: mainImageView.trailingAnchor),
            tempImageView.bottomAnchor.constraint(equalTo: mainImageView.bottomAnchor)
        ])
        
        // Set up constraints for leftStackView
        NSLayoutConstraint.activate([
            leftStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: buttonsPadding),
            leftStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            leftStackView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: buttonsPadding), // Ensure it is not directly at the top
            leftStackView.trailingAnchor.constraint(equalTo: bottomStackView.leadingAnchor, constant: 0),
        ])
        
        // Set up constraints for bottomStackView
        NSLayoutConstraint.activate([
            bottomStackView.leadingAnchor.constraint(greaterThanOrEqualTo: leftStackView.trailingAnchor, constant: 0),
            bottomStackView.trailingAnchor.constraint(greaterThanOrEqualTo: rightStackView.leadingAnchor, constant: 0),
            bottomStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -buttonsPadding),
            bottomStackView.heightAnchor.constraint(equalToConstant: buttonsHeight*3),
            bottomStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
        ])
        
        NSLayoutConstraint.activate([
            pencilButton.widthAnchor.constraint(equalToConstant: buttonsHeight*3),
            pencilButton.heightAnchor.constraint(equalToConstant: buttonsHeight),
        ])
        
        // Set up constraints for rightStackView
        NSLayoutConstraint.activate([
            rightStackView.widthAnchor.constraint(equalToConstant: buttonsHeight),
            rightStackView.leadingAnchor.constraint(equalTo: bottomStackView.trailingAnchor, constant: buttonsPadding),
            rightStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -buttonsPadding),
            rightStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: buttonsPadding),
            rightStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -buttonsPadding)
        ])
        
        NSLayoutConstraint.activate([
            redoButton.widthAnchor.constraint(equalToConstant: buttonsHeight),
            redoButton.heightAnchor.constraint(equalToConstant: buttonsHeight),
            undoButton.widthAnchor.constraint(equalToConstant: buttonsHeight),
            undoButton.heightAnchor.constraint(equalToConstant: buttonsHeight),
            cameraButton.widthAnchor.constraint(equalToConstant: buttonsHeight),
            cameraButton.heightAnchor.constraint(equalToConstant: buttonsHeight),
        ])
        
        if showExtraBlackWhite
        {
            // Set up constraints for blackColorButton
            NSLayoutConstraint.activate([
                blackColorButton.leadingAnchor.constraint(equalTo: rightStackView.leadingAnchor),
                blackColorButton.trailingAnchor.constraint(equalTo: rightStackView.trailingAnchor),
                blackColorButton.topAnchor.constraint(equalTo: rightStackView.topAnchor),
                blackColorButton.heightAnchor.constraint(equalToConstant: buttonsHeight)
            ])
            
            // Set up constraints for whiteColorButton
            NSLayoutConstraint.activate([
                whiteColorButton.leadingAnchor.constraint(equalTo: rightStackView.leadingAnchor),
                whiteColorButton.trailingAnchor.constraint(equalTo: rightStackView.trailingAnchor),
                whiteColorButton.topAnchor.constraint(equalTo: blackColorButton.bottomAnchor, constant: buttonsPadding),
                whiteColorButton.heightAnchor.constraint(equalToConstant: buttonsHeight)
            ])
            // Set up constraints for colorSliderView
            NSLayoutConstraint.activate([
                colorSliderView.leadingAnchor.constraint(equalTo: rightStackView.leadingAnchor),
                colorSliderView.trailingAnchor.constraint(equalTo: rightStackView.trailingAnchor),
                colorSliderView.topAnchor.constraint(equalTo: whiteColorButton.bottomAnchor, constant: buttonsPadding),
                colorSliderView.bottomAnchor.constraint(equalTo: currentColorButton.topAnchor)
            ])
        }
        else
        {
            // Set up constraints for colorSliderView
            NSLayoutConstraint.activate([
                colorSliderView.leadingAnchor.constraint(equalTo: rightStackView.leadingAnchor),
                colorSliderView.trailingAnchor.constraint(equalTo: rightStackView.trailingAnchor),
                colorSliderView.topAnchor.constraint(equalTo: rightStackView.topAnchor),
                colorSliderView.bottomAnchor.constraint(equalTo: currentColorButton.topAnchor)
            ])
            
        }
        // Set up constraints for currentColorButton
        NSLayoutConstraint.activate([
            currentColorButton.leadingAnchor.constraint(equalTo: rightStackView.leadingAnchor),
            currentColorButton.trailingAnchor.constraint(equalTo: rightStackView.trailingAnchor),
            currentColorButton.bottomAnchor.constraint(equalTo: rightStackView.bottomAnchor),
            currentColorButton.heightAnchor.constraint(equalToConstant: buttonsHeight)
        ])
        
        // Set up the constraints
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    private func setupLayout()
    {
        cameraButton.tintColor = buttonsTint
        undoButton.tintColor = buttonsTint
        redoButton.tintColor = buttonsTint
        if showExtraBlackWhite
        {
            whiteColorButton.tintColor = buttonsTint
            blackColorButton.tintColor = buttonsTint
        }
        currentColorButton.tintColor = buttonsTint
        
        setupButtonLayer(cameraButton)
        setupButtonLayer(undoButton)
        setupButtonLayer(redoButton)
        if showExtraBlackWhite
        {
            setupButtonLayer(blackColorButton)
            setupButtonLayer(whiteColorButton)
        }
        setupButtonLayer(currentColorButton)
    }
    
    private func setupColorSlider() {
        // Remove the old color slider if it exists
        if let colorSlider = colorSlider {
            colorSlider.removeFromSuperview()
        }
        
        // Recreate the color slider with the updated frame
        colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)
        
        if let colorSlider = colorSlider {
            colorSliderView.layoutIfNeeded()
            view.layoutIfNeeded()
            
            // Update the color slider's frame with the new dimensions
            colorSlider.frame = CGRect(x: 0, y: 0, width: colorSliderView.frame.width, height: colorSliderView.frame.height)
            
            // Add it to the view
            colorSliderView.addSubview(colorSlider)
            
            // Customize appearance
            colorSlider.gradientView.layer.borderWidth = 1.0
            colorSlider.gradientView.layer.borderColor = buttonsTint.cgColor
            
            // Adjusts corner radius
            colorSlider.gradientView.automaticallyAdjustsCornerRadius = true
            
            // Add target for value change
            colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
        }
    }
    
    private func setupButtonLayer(_ sender: UIButton)
    {
        if showBorders
        {
            sender.layer.borderWidth = 1
            sender.layer.borderColor = buttonsTint.cgColor
            sender.layer.cornerRadius = buttonsHeight/2
            
        }
        else
        {
            sender.layer.borderWidth = 0
            sender.layer.cornerRadius = 0
        }
        
        if showShadows
        {
            sender.layer.masksToBounds = false
            sender.layer.shadowColor = UIColor.black.cgColor
            sender.layer.shadowOpacity = 0.2
            sender.layer.shadowOffset = .zero
            sender.layer.shadowRadius = 1
        }
        else
        {
            sender.layer.masksToBounds = false
            sender.layer.shadowColor = UIColor.clear.cgColor
            sender.layer.shadowOpacity = 0
            sender.layer.shadowOffset = .zero
            sender.layer.shadowRadius = 0
        }
        sender.layoutIfNeeded()
    }
    
    private func setupPencilButtons(_ sender: UIButton)
    {
        let buttonArr = [pencilButton, colorButton, markerButton, eraserButton]
        
        for button in buttonArr
        {
            if button == sender
            {
                button.tag = 1
                
                if button == pencilButton
                {
                    pencilButton.setImage(Icons.pencilSelected, for: .normal)
                    if let color = selectedDrawableColor
                    {
                        pencilButton.setImage(Icons.pencilSelected?.withTintColor(color ), for: .normal)
                    }
                }
                else if button == colorButton
                {
                    colorButton.setImage(Icons.colorSelected, for: .normal)
                    if let color = selectedDrawableColor
                    {
                        colorButton.setImage(Icons.colorSelected?.withTintColor(color ), for: .normal)
                    }
                }
                else if button == markerButton
                {
                    markerButton.setImage(Icons.markerSelected, for: .normal)
                    if let color = selectedDrawableColor
                    {
                        markerButton.setImage(Icons.markerSelected?.withTintColor(color ), for: .normal)
                    }
                }
                else if button == eraserButton
                {
                    eraserButton.setImage(Icons.eraserSelected, for: .normal)
                    if let color = selectedDrawableColor
                    {
                        eraserButton.setImage(Icons.eraserSelected?.withTintColor(color ), for: .normal)
                    }
                }
            }
            else
            {
                button.tag = 0
                
                if button == pencilButton
                {
                    pencilButton.setImage(Icons.pencilUnselected, for: .normal)
                    if let color = unselectedDrawableColor
                    {
                        pencilButton.setImage(Icons.pencilUnselected?.withTintColor(color ), for: .normal)
                    }
                }
                else if button == colorButton
                {
                    colorButton.setImage(Icons.colorUnSelected, for: .normal)
                    if let color = unselectedDrawableColor
                    {
                        colorButton.setImage(Icons.colorUnSelected?.withTintColor(color ), for: .normal)
                    }
                }
                else if button == markerButton
                {
                    markerButton.setImage(Icons.markerUnSelected, for: .normal)
                    if let color = unselectedDrawableColor
                    {
                        markerButton.setImage(Icons.markerUnSelected?.withTintColor(color ), for: .normal)
                    }
                }
                else if button == eraserButton
                {
                    eraserButton.setImage(Icons.eraserUnSelected, for: .normal)
                    if let color = unselectedDrawableColor
                    {
                        eraserButton.setImage(Icons.eraserUnSelected?.withTintColor(color ), for: .normal)
                    }
                }
            }
        }
    }
    
    private func resetDrawing()
    {
        mainImageView.image = nil
        for i in addedPointsStack
        {
            
            let tempImageView = UIImageView(image: i)
            let string = i.accessibilityIdentifier ?? "1.0"
            var cgFloat: CGFloat?
            
            if let doubleValue = Double(string) {
                cgFloat = CGFloat(doubleValue)
            }
            // Merge tempImageView into mainImageView
            UIGraphicsBeginImageContext(mainImageView.frame.size)
            mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
            if let cgFloat = cgFloat
            {
                tempImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: cgFloat)
            }
            mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            tempImageView.image = nil
        }
    }
    
    private func setColor(_ color: UIColor)
    {
        self.selectedColor = color
        self.currentColorButton.backgroundColor = color
    }
    
    
    @objc func changedColor(_ slider: ColorSlider) {
        let color = slider.color
        
        self.setColor(color)
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false  // Ensure it's visible
    }
    
    // Function to stop animating
    func stopLoading() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}

@available(iOS 13.0, *)
extension DrawingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var imageName = ""
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            imageName = "\(url.lastPathComponent)"
        }
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            //            preInteriewViewModel?.uploadAvatar(name: imageName, image: pickedImage)
            
            self.tempImageView.image = pickedImage
        }
        else if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //            preInteriewViewModel?.uploadAvatar(name: imageName, image: pickedImage)
            self.tempImageView.image = pickedImage
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
        tempImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var stackimage = tempImageView.image ?? UIImage()
        stackimage.accessibilityIdentifier = "\(1.0)"
        addedPointsStack.append(stackimage)
        undonePointsStack.removeAll()
        tempImageView.image = nil
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
@available(iOS 14.0, *)
extension DrawingViewController
{
    //MARK: Add image
    func camera(pickerDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate), sourceType: UIImagePickerController.SourceType, allowsEditing: Bool, excludeVideos: Bool, excludeImages: Bool)
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = pickerDelegate
            picker.sourceType = sourceType
            picker.allowsEditing = allowsEditing
            
            if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
                //                picker.mediaTypes = mediaTypes
                
                if excludeVideos == excludeImages && excludeImages == false {
                    if mediaTypes.contains(where: { $0.lowercased() == UTType.video.identifier.lowercased() })
                    {
                        picker.mediaTypes = [UTType.video.identifier, UTType.image.identifier]
                        picker.cameraCaptureMode = .video
                    }
                    else if mediaTypes.contains(where: { $0.lowercased() == UTType.movie.identifier.lowercased() })
                    {
                        picker.mediaTypes = [UTType.movie.identifier, UTType.image.identifier]
                        picker.cameraCaptureMode = .video
                    }
                }
                else if excludeImages == false, excludeVideos && mediaTypes.contains(where: { $0.lowercased() == UTType.image.identifier.lowercased() })
                {
                    picker.mediaTypes = [UTType.image.identifier]
                    picker.cameraCaptureMode = .photo
                }
                else if excludeVideos == false, excludeImages
                {
                    
                    if mediaTypes.contains(where: { $0.lowercased() == UTType.video.identifier.lowercased() })
                    {
                        picker.mediaTypes = [UTType.video.identifier]
                        picker.cameraCaptureMode = .video
                    }
                    else if mediaTypes.contains(where: { $0.lowercased() == UTType.movie.identifier.lowercased() })
                    {
                        picker.mediaTypes = [UTType.movie.identifier]
                        picker.cameraCaptureMode = .video
                    }
                }
            }
            
            self.checkForCameraPermissions{ (status) in
                if status
                {
                    DispatchQueue.main.async {
                        self.present(picker, animated: true, completion: nil)
                    }
                }
            }
        }
        else
        {
            self.showAlertWithAction(title: "Alert", message: "Sorry! This device does not have camera.", options: ["OK"]) { _ in
                
            }
        }
    }
    
    func photoLibrary(pickerDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate), sourceType: UIImagePickerController.SourceType, allowsEditing: Bool, excludeVideos: Bool, excludeImages: Bool)
    {
        
        let picker = UIImagePickerController()
        picker.delegate = pickerDelegate
        picker.sourceType = sourceType
        picker.allowsEditing = allowsEditing
        
        if excludeVideos == excludeImages && excludeImages == false
        {
            picker.mediaTypes = [UTType.movie.identifier, UTType.image.identifier]
        }
        else if excludeImages == false, excludeVideos
        {
            picker.mediaTypes = [UTType.image.identifier]
        }
        else if excludeVideos == false, excludeImages
        {
            picker.mediaTypes = [UTType.movie.identifier]
        }
        
        self.checkPhotoLibraryPermission { (status) in
            if status
            {
                DispatchQueue.main.async {
                    self.present(picker, animated: true, completion: nil)
                }
            }
        }
    }
    
    //MARK:- Upload document
    func attachDocument(docDelegate: UIDocumentPickerDelegate) {
        let types = [kUTTypeImage,kUTTypePresentation,kUTTypeFolder,kUTTypeZipArchive,kUTTypeVideo, kUTTypeAudiovisualContent, kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet, "com.microsoft.word.doc", "com.microsoft.word.docx", "org.openxmlformats.wordprocessingml.document"] as [Any]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as! [String], in: .import)
        
        documentPicker.allowsMultipleSelection = false
        documentPicker.delegate = docDelegate
        documentPicker.modalPresentationStyle = .formSheet
        
        present(documentPicker, animated: true)
    }
    
    //MARK: Camera Gallery Picker
    func showActionSheet(button: UIButton , pickerDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate), allowsEditing: Bool = false, excludeVideos: Bool = false, excludeImages: Bool = false, includeDocuments: Bool = false, docDelegate: UIDocumentPickerDelegate? = nil)
    {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera(pickerDelegate: pickerDelegate, sourceType: .camera, allowsEditing: allowsEditing, excludeVideos: excludeVideos, excludeImages: excludeImages)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary(pickerDelegate: pickerDelegate, sourceType: .photoLibrary, allowsEditing: allowsEditing, excludeVideos: excludeVideos, excludeImages: excludeImages)
        }))
        
        if includeDocuments == true, let docDelegate = docDelegate
        {
            actionSheet.addAction(UIAlertAction(title: "Document", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                self.attachDocument(docDelegate: docDelegate)
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        // show action sheet
        //        actionSheet.popoverPresentationController.barButtonItem = button;
        actionSheet.popoverPresentationController?.sourceView = button;
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func checkPhotoLibraryPermission(_ withActions: Bool = true, completion: @escaping (Bool) -> Void)
    {
        switch PHPhotoLibrary.authorizationStatus()
        {
        case .authorized:
            //handle authorized status
            completion(true)
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    completion(true)
                case .denied, .restricted, .notDetermined:
                    // won't happen but still
                    completion(false)
                default:
                    fatalError()
                }
            }
        case .denied :
            //handle denied status
            if withActions
            {
                self.showAlertWithAction(title: "Allow access to photo library", message: "Open settings to make changes.", options: ["Cancel","Settings"]) { (action) in
                    if action == 1
                    {
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
#if DEBUG
                                print("Settings opened: \(success)") // Prints true
#endif
                                
                            })
                        }
                    }
                    completion(false)
                }
            }
            else
            {
                completion(false)
            }
            
            
        case .restricted:
            if withActions
            {
                self.showAlertWithAction(title: "Restricted", message: "You've been restricted from using the photos on this device. Without photo library access this feature won't work..", options: ["Ok"]) { (action) in
                    
                    completion(false)
                }
            }
            else
            {
                completion(false)
            }
            
            
        default:
            break
            
        }
    }
    
    func checkForCameraPermissions(_ withActions: Bool = true, completion: @escaping (Bool) -> Void)
    {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                if granted {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        case .denied:
            if withActions
            {
                self.showAlertWithAction(title: "Allow access to camera", message: "Open settings to make changes.", options: ["Cancel","Settings"]) { (action) in
                    if action == 1
                    {
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
#if DEBUG
                                print("Settings opened: \(success)") // Prints true
#endif
                                
                            })
                        }
                    }
                    completion(false)
                }
            }
            else
            {
                completion(false)
            }
            
        case .restricted:
            if withActions
            {
                self.showAlertWithAction(title: "Restricted", message: "You've been restricted from using the photos on this device. Without photo library access this feature won't work..", options: ["Ok"]) { (action) in
                    
                    completion(false)
                }
            }
            else
            {
                completion(false)
            }
            
        @unknown default:
            fatalError()
        }
        
    }
    
    func showAlertWithAction(title: String?, message: String, options: [String]?, completion: @escaping (Int) -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let options = options
        {
            
            for (index, option) in options.enumerated() {
                var title = option.uppercased()
                
                let button = UIAlertAction.init(title: title, style: .default, handler: { (action) in
                    completion(index)
                })
                alert.addAction(button)
            }
        }
        else{
            alert.addAction(UIAlertAction(title: options?.first ?? "OK", style: UIAlertAction.Style.default, handler: nil))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
