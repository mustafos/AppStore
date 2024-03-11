//
//  SkinChoicesVC.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 12.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

protocol SkinChoicesPresenter: AnyObject {
    func create2dTapped()
    func create3dTapped()
    func create3d128Tapped()
    func importTapped()
    
    func amenable2dTap()
    func amenable3dTap()
}

class SkinChoicesVC: UIViewController {
    enum State {
        case new
        case edit
    }
    
    private let buttonHorizontalOffset: CGFloat = 35
    private let buttonHeight: CGFloat = 54
    private let itemSpacing: CGFloat = 16
    private let titleHeight: CGFloat = 44
    private let bottomOffset: CGFloat = 70
    
    weak var presenterDelegate: SkinChoicesPresenter?
    
    var state: State = .new
    
    // define lazy views
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.frame =  CGRectMake(0, 0, self.view.frame.width - buttonHorizontalOffset*2, 26)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
        label.textAlignment = .center
        label.textColor = UIColor(named: "BeigeColor")
        label.font = UIFont.montserratFont(.bold, size: 22)
        label.text = state == .new ? "NEW SKIN" : "EDIT SKIN"
        return label
    }()
    
    
    lazy var createNew2dButton: UIButton = {
        let button = customButton(text: "Create New 2D")
        button.addTarget(self, action: #selector(createNew2dButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var createNew3dButton: UIButton = {
        let button = customButton(text: "Create New 3D")
        button.addTarget(self, action: #selector(createNew3dButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var createNew3d128Button: UIButton = {
        let button = customButton(text: "Create New 3D (128*128)")
        button.addTarget(self, action: #selector(createNew3d128ButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var createImportButton: UIButton = {
        let button = customButton(text: "Import")
        button.setImage(UIImage(named: "Import Button"), for: .normal)
        button.imageEdgeInsets.left = -5
        button.titleEdgeInsets.left = 5
        button.addTarget(self, action: #selector(importButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var createCancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Cancel Button"), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var edit2dButton: UIButton = {
        let button = customButton(text: "Edit in 2D")
        button.addTarget(self, action: #selector(edit2dButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var edit3dButton: UIButton = {
        let button = customButton(text: "Edit in 3D")
        button.addTarget(self, action: #selector(edit3dButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func edit2dButtonTapped() {
        self.animateDismissView()
        presenterDelegate?.amenable2dTap()
    }

    @objc func edit3dButtonTapped() {
        self.animateDismissView()
        presenterDelegate?.amenable3dTap()
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
        let alert = UIAlertController(title: "Import", message: "Do you want to import?", preferredStyle: .alert)

        let importAction = UIAlertAction(title: "Import", style: .default) { [weak self] _ in
            // Dismiss the screen after importing
            self?.animateDismissView()
            // Notify the presenter
            self?.presenterDelegate?.importTapped()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(importAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
    
    @objc func cancelButtonTapped() {
        self.animateDismissView()
    }
    
    var currentButtonArray: [UIView] {
        switch state {
        case .new:
            return [createNew2dButton, createNew3dButton, createNew3d128Button, createImportButton]
        case .edit:
            return [edit2dButton, edit3dButton]
        }
    }
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: currentButtonArray)
        stackView.axis = .vertical
        stackView.distribution = .fill

        stackView.spacing = 12
        return stackView
    }()
    
    private var blurEffectView: UIVisualEffectView?
    let maxDimmedAlpha: CGFloat = 1
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
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
        containerView.alpha = 0
        setupView()
        setupConstraints()
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
        addBlurEffectToBackground()
    }
    
    func setupConstraints() {
        // Add subviews
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(createCancelButton)
        containerView.addSubview(contentStackView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        createCancelButton.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set static constraints
        NSLayoutConstraint.activate([
            // set container static constraint
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            createCancelButton.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 20),
            createCancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            createCancelButton.widthAnchor.constraint(equalToConstant: 44),
            createCancelButton.heightAnchor.constraint(equalToConstant: 44),
            // content stackView
            contentStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
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
    
    private func addBlurEffectToBackground() {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        blurEffectView?.alpha = 0
        view.addSubview(blurEffectView!)
        
        // Make the blur effect view cover the doneView
        view.bringSubviewToFront(containerView)
        
        UIView.animate(withDuration: 0.3) {
            self.blurEffectView?.alpha = 1
        }
    }
    
    private func customButton(text: String) -> UIButton {
        let button = UIButton()
        button.frame = CGRectMake(0, 0, self.view.frame.width - buttonHorizontalOffset*2, buttonHeight)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = UIFont.montserratFont(.bold, size: 18)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor(named: "YellowSelectiveColor")
        button.cornerRadius = buttonHeight/2
        button.borderWidth = 1
        button.borderColor = .black
        return button
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.3) {
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
        UIView.animate(withDuration: 0.3) {
                self.containerView.alpha = self.maxDimmedAlpha
            }
    }
    
    func animateDismissView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
        // Update the bottom constraint
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }
    }
}
