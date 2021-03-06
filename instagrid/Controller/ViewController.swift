//
//  ViewController.swift
//  instagrid
//
//  Created by Christophe DURAND on 02/04/2018.
//  Copyright © 2018 Christophe DURAND. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var defaultViewButton: UIButton!
    @IBOutlet weak var hiddenBottomRightViewButton: UIButton!
    @IBOutlet weak var hiddenTopRightViewButton: UIButton!
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var swipeToShareStackView: UIStackView!
    @IBOutlet weak var swipeToShareLabel: UILabel!
    @IBOutlet weak var swipeDirectionImageView: UIImageView!
    
    //MARK: - Vars
    var imagePicker = UIImagePickerController()
    var tag = 0
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationChangeSwipeLabelAndImage()
    }
    
    //MARK: - IBActions
    //IBAction of the top Rectangular Grid View button
    @IBAction func hiddenTopRightView(_ sender: Any) {
        gridView.hiddenTopRightView()
        selectedImageHiddenTopRightView()
    }
    
    //IBAction of the bottom Rectangular Grid View button
    @IBAction func hiddenBottomRightView(_ sender: Any) {
        gridView.hiddenBottomRightView()
        selectedImageHiddenBottomRightView()
    }
    
    //IBAction of the default Grid View button
    @IBAction func defaultView(_ sender: Any) {
        gridView.defaultView()
        selectedImageDefaultViewButton()
    }
    
    //IBAction of the button "Reset Grid"
    @IBAction func resetGrid(_ sender: Any) {
        gridView.resetGrid()
    }
    
    //IBAction of the 4 "plus" buttons in the grid, to choose photos from photoLibrary
    @IBAction func chooseImage(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            tag = sender.tag
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true)
        }
    }
    
    //IBAction of the swipeToShare with UIPangestureRecognizer, managing the animations of the swipe through some conditions
    @IBAction func swipeToShare(_ sender: UIPanGestureRecognizer) {
        if gridView.isAllowedToBeShared() {
            animationGridViewPortraitMode()
            animationGridViewLandscapeMode()
            showUIActivityViewController()
        }
        if gridView.isNotAllowedToBeShared() {
            createAlertGridNotFull(title: "Choose your photos", message: "Your grid must be full of photos")
        } else {
            animationGridViewPortraitMode()
            animationGridViewLandscapeMode()
            showUIActivityViewController()
        }
    }
    
    //MARK: - Class Methods
    //Method managing the selected image of the default grid view button when pressed it
    private func selectedImageDefaultViewButton() {
        if defaultViewButton.currentImage == nil {
            defaultViewButton.setImage(#imageLiteral(resourceName: "Selected"), for: UIControl.State.normal)
            hiddenBottomRightViewButton.setImage(nil, for: UIControl.State.normal)
            hiddenTopRightViewButton.setImage(nil, for: UIControl.State.normal)
        }
    }
    
    //Method managing the selected image of the bottom rectangular grid view button when pressed it
    private func selectedImageHiddenBottomRightView() {
        if hiddenBottomRightViewButton.currentImage == nil {
            hiddenBottomRightViewButton.setImage(#imageLiteral(resourceName: "Selected"), for: UIControl.State.normal)
            hiddenTopRightViewButton.setImage(nil, for: UIControl.State.normal)
            defaultViewButton.setImage(nil, for: UIControl.State.normal)
        }
    }
    
    //Method managing the selected image of the top rectangular grid view button when pressed it
    private func selectedImageHiddenTopRightView() {
        if hiddenTopRightViewButton.currentImage == nil {
            hiddenTopRightViewButton.setImage(#imageLiteral(resourceName: "Selected"), for: UIControl.State.normal)
            hiddenBottomRightViewButton.setImage(nil, for: UIControl.State.normal)
            defaultViewButton.setImage(nil, for: UIControl.State.normal)
        }
    }
    
    //Method managing the UIActivityViewController, to share with other apps
    private func showUIActivityViewController() {
        guard let image = RenderImageService.convertGridViewToImage(gridView: gridView) else { return }
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
        activity.completionWithItemsHandler = { (activityType, completed: Bool, returnedItems:[Any]?, error: Error?) in
            if completed == true {
                self.showGridViewPortraitMode()
                self.showGridViewLandscapeMode()
            } else {
                self.showGridViewPortraitMode()
                self.showGridViewLandscapeMode()
            }
        }
    }
    
    //Method managing the animation of the grid in portrait mode
    private func animationGridViewPortraitMode() {
        if UIDevice.current.orientation.isPortrait {
            let screenHeight = view.frame.height
            var goingUpAnimation: CGAffineTransform
            goingUpAnimation = CGAffineTransform(translationX: 0, y: -screenHeight)
            
            UIView.animate(withDuration: 0.4, animations: { self.gridView.transform = goingUpAnimation }, completion: nil)
            UIView.animate(withDuration: 0.4, animations: { self.swipeToShareStackView.transform = goingUpAnimation }, completion: nil)
        }
    }
    
    //Method managing the animation of the grid in landscape mode
    private func animationGridViewLandscapeMode() {
        if UIDevice.current.orientation.isLandscape {
            let screenWidth = view.frame.width
            var goingLeftAnimation: CGAffineTransform
            goingLeftAnimation = CGAffineTransform(translationX: -screenWidth, y: 0)
            
            UIView.animate(withDuration: 0.4, animations: { self.gridView.transform = goingLeftAnimation}, completion: nil)
            UIView.animate(withDuration: 0.4, animations: { self.swipeToShareStackView.transform = goingLeftAnimation }, completion: nil)
        }
    }
    
    //Method managing the animation of the grid after sharing it, in portrait mode
    private func showGridViewPortraitMode() {
        if UIDevice.current.orientation.isPortrait {
            let screenHeight = view.frame.height
            
            gridView.transform = .identity
            gridView.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
            UIView.animate(withDuration: 0.4, animations: { self.gridView.transform = .identity}, completion: nil)
            
            swipeToShareStackView.transform = .identity
            swipeToShareStackView.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
            UIView.animate(withDuration: 0.4, animations: { self.swipeToShareStackView.transform = .identity }, completion: nil)
        }
    }
    
    //Method managing the animation of the grid after sharing it, in landscape mode
    private func showGridViewLandscapeMode() {
        if UIDevice.current.orientation.isLandscape {
            let screenWidth = view.frame.width
            
            gridView.transform = .identity
            gridView.transform = CGAffineTransform(translationX: -screenWidth, y: 0)
            UIView.animate(withDuration: 0.4, animations: { self.gridView.transform = .identity}, completion: nil)
            
            swipeToShareStackView.transform = .identity
            swipeToShareStackView.transform = CGAffineTransform(translationX: -screenWidth, y: 0)
            UIView.animate(withDuration: 0.4, animations: { self.swipeToShareStackView.transform = .identity}, completion: nil)
        }
    }
    
    //Method managing an alert notification when user trying to share the grid uncompleted
    private func createAlertGridNotFull(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil) }))
        self.present(alert, animated: true, completion: nil )
    }
    
    //Method managing the swipe direction image and the text of the label according to the deviece orientation
    @objc private func changeSwipeLabelAndImage() {
        if UIDevice.current.orientation.isPortrait {
            swipeToShareLabel.text = "Swipe up to share"
            swipeDirectionImageView.image = #imageLiteral(resourceName: "UpArrow")
        }
        if UIDevice.current.orientation.isLandscape {
            swipeToShareLabel.text = "Swipe left to share"
            swipeDirectionImageView.image = #imageLiteral(resourceName: "LeftArrow")
        }
    }
    
    //Method managing the notification of the change swipe's label and image and calling it into viewDidLoad
    private func notificationChangeSwipeLabelAndImage() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeSwipeLabelAndImage), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}

//MARK: - UIImagePickerController
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Method managing the tags set on the 4 "plus" buttons, to call imagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        
        switch tag {
        case 1:
            gridView.topLeftImageView.image = pickedImage
        case 2:
            gridView.topRightImageView.image = pickedImage
        case 3:
            gridView.bottomLeftImageView.image = pickedImage
        case 4:
            gridView.bottomRightImageView.image = pickedImage
        default:
            break
        }
        dismiss(animated: true, completion: nil)
    }
    
    //Method managing imagePickerController when cancel it
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
