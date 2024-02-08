//
//  SkinVariantsViewController.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 12.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

protocol SkinVariantsPrsenter: AnyObject {
    func create2dTapped()
    func create3dTapped()
    func create3d128Tapped()
    func importTapped()
    
    func edit2dTapped()
    func edit3dTapped()
}

class SkinVariantsViewController: UIViewController {
    enum State {
        case new
        case edit
    }
    
    private let buttonHorizontalOffset: CGFloat = 35
    private let buttonHeight: CGFloat = 54
    private let itemSpacing: CGFloat = 16
    private let titleHeight: CGFloat = 26
    private let bottomOffset: CGFloat = 70
    
    weak var presenterDelegate: SkinVariantsPrsenter?
    
    var state: State = .new
    
    // define lazy views
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.frame =  CGRectMake(0, 0, self.view.frame.width - buttonHorizontalOffset*2, 26)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.blinkerFont(.semiBold, size: 22)
        label.text = state == .new ? "NEW SKIN" : "EDIT SKIN"
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    
    lazy var createNew2dButton: UIButton = {
        let button = UIButton()
        button.frame = CGRectMake(0, 0, self.view.frame.width - buttonHorizontalOffset*2, buttonHeight)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.setTitle("Create New 2D", for: .normal)
        button.titleLabel?.font = UIFont.blinkerFont(.semiBold, size: 16)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.cornerRadius = buttonHeight/2
        button.addTarget(self, action: #selector(createNew2dButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var createNew3dButton: UIButton = {
        let button = UIButton()
        button.frame = CGRectMake(0, 0, self.view.frame.width - buttonHorizontalOffset*2, buttonHeight)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.setTitle("Create New 3D", for: .normal)
        button.titleLabel?.font = UIFont.blinkerFont(.semiBold, size: 16)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.cornerRadius = buttonHeight/2
        button.addTarget(self, action: #selector(createNew3dButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var createNew3d128Button: UIButton = {
        let button = UIButton()
        button.frame = CGRectMake(0, 0, self.view.frame.width - buttonHorizontalOffset*2, buttonHeight)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.setTitle("Create New 3D (128*128)", for: .normal)
        button.titleLabel?.font = UIFont.blinkerFont(.semiBold, size: 16)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.cornerRadius = buttonHeight/2
        button.addTarget(self, action: #selector(createNew3d128ButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var createImportButton: UIButton = {
        let button = UIButton()
        button.frame = CGRectMake(0, 0, self.view.frame.width - buttonHorizontalOffset*2, buttonHeight)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.setTitle("Import", for: .normal)
        button.titleLabel?.font = UIFont.blinkerFont(.semiBold, size: 16)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.cornerRadius = buttonHeight/2
        button.addTarget(self, action: #selector(importButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var createCancelButton: UIButton = {
        let button = UIButton()
        button.frame = CGRectMake(0, 0, self.view.frame.width - buttonHorizontalOffset*2, buttonHeight)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.blinkerFont(.semiBold, size: 16)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.cornerRadius = buttonHeight/2
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var edit2dButton: UIButton = {
        let button = UIButton()
        button.frame = CGRectMake(0, 0, self.view.frame.width - buttonHorizontalOffset*2, buttonHeight)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.setTitle("Edit in 2D", for: .normal)
        button.titleLabel?.font = UIFont.blinkerFont(.semiBold, size: 16)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.cornerRadius = buttonHeight/2
        button.addTarget(self, action: #selector(edit2dButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var edit3dButton: UIButton = {
        let button = UIButton()
        button.frame = CGRectMake(0, 0, self.view.frame.width - buttonHorizontalOffset*2, buttonHeight)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.setTitle("Edit in 3D", for: .normal)
        button.titleLabel?.font = UIFont.blinkerFont(.semiBold, size: 16)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.cornerRadius = buttonHeight/2
        button.addTarget(self, action: #selector(edit3dButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func edit2dButtonTapped() {
        self.animateDismissView()
        presenterDelegate?.edit2dTapped()
    }
    
    @objc func edit3dButtonTapped() {
        self.animateDismissView()
        presenterDelegate?.edit3dTapped()
    }
    
    @objc func createNew2dButtonTapped() {
        self.animateDismissView()
        presenterDelegate?.create2dTapped()
    }
    
    @objc func createNew3dButtonTapped() {
        self.animateDismissView()
        presenterDelegate?.create3dTapped()
    }
    
    @objc func createNew3d128ButtonTapped() {
        self.animateDismissView()
        presenterDelegate?.create3d128Tapped()
    }
    
    @objc func importButtonTapped() {
        self.animateDismissView()
        presenterDelegate?.importTapped()
    }
    
    @objc func cancelButtonTapped() {
        self.animateDismissView()
    }
    
    var currentButtonArray: [UIView] {
        let spacer = UIView()
        switch state {
        case .new:
            return [titleLabel, createNew2dButton, createNew3dButton, createNew3d128Button, createImportButton, createCancelButton, spacer]
        case .edit:
            return [titleLabel, edit2dButton, edit3dButton, createCancelButton, spacer]
        }
    }
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: currentButtonArray)
        stackView.axis = .vertical
        stackView.distribution = .fill

        stackView.spacing = 16.0
        return stackView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    let maxDimmedAlpha: CGFloat = 0.6
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    // Constants
    var defaultHeight: CGFloat {
        switch state {
        case .new:
            return buttonHeight*5 + titleHeight + itemSpacing*7 + bottomOffset
        case .edit:
            return buttonHeight*3 + titleHeight + itemSpacing*4 + bottomOffset
        }
    }
    
    
    
    
    lazy var dismissibleHeight: CGFloat = defaultHeight * 0.8
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    // keep current new height, initial is default height
    lazy var currentContainerHeight: CGFloat = defaultHeight
    
    // Dynamic container constraint
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        // tap gesture on dimmed view to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
        
        setupPanGesture()
    }
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    func setupView() {
        view.backgroundColor = .clear
    }
    
    func setupConstraints() {
        // Add subviews
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.backgroundColor = UIColor(named: "greenCCRedesign")
        
        containerView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set static constraints
        NSLayoutConstraint.activate([
            // set dimmedView edges to superview
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // set container static constraint (trailing & leading)
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // content stackView
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
        ])
        
        // Set dynamic constraints
        // First, set container to default height
        // after panning, the height can expand
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        
        // By setting the height to default height, the container will be hide below the bottom anchor view
        // Later, will bring it up by set it to 0
        // set the constant to default height to bring it down again
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        // Activate constraints
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Drag to top will be minus value and vice versa
        print("Pan gesture y offset: \(translation.y)")
        
        // Get drag direction
        let isDraggingDown = translation.y > 0
        print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
        
        // New height is based on value of dragging plus current container height
        let newHeight = currentContainerHeight - translation.y
        
        // Handle based on gesture state
        switch gesture.state {
        case .changed:
            // This state will occur when user is dragging
            if newHeight < maximumContainerHeight && newHeight > defaultHeight {
                // Keep updating the height constraint
                containerViewHeightConstraint?.constant = newHeight
                // refresh layout
                view.layoutIfNeeded()
            }
            
        case .ended:
            // This happens when user stop drag,
            // so we will get the last height of container
            
            // Condition 1: If new height is below min, dismiss controller
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            else if newHeight < defaultHeight {
                // Condition 2: If new height is below default, animate back to default
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                // Condition 3: If new height is below max and going down, set to default height
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                // Condition 4: If new height is below max and going up, set to max height at top
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }
    
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    func animateDismissView() {
        // hide blur view
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            // once done, dismiss without animation
            self.dismiss(animated: false)
        }
        // hide main view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }

}
