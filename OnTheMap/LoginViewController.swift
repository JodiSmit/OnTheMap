//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jodi Lovell on 3/21/17.
//  Copyright © 2017 None. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var session = URLSession.shared
    var keyboardOnScreen = false

    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userLoginButton: UIButton!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var newUserButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userEmail?.delegate = self
        userPassword?.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViewResizerOnKeyboardShown()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }


    //MARK: Actions taken when login button is pressed
    @IBAction func loginPressed(_ sender: UIButton) {
        startNetworkActivity()
        
        guard userEmail?.text!.isEmpty == false && userPassword?.text!.isEmpty == false else {
            showAlert(userLoginButton!, message: UdacityClient.ErrorMessages.noInputError)
            return
        }

        UdacityClient.sharedInstance.loginToUdacity((userEmail?.text!)!, password: (userPassword?.text!)!) {
            (success, ErrorMessage) -> Void in
            guard success else {
                performUIUpdatesOnMain {
                    self.showAlert(self.userLoginButton!, message: UdacityClient.ErrorMessages.loginError)
                    self.userEmail?.text = ""
                    self.userPassword?.text = ""
                    print("This is the error stuff")
                }
                return
            }

      
            performUIUpdatesOnMain {
                self.stopNetworkActivity()
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainTabController") as! UITabBarController
                self.present(controller, animated: true, completion: nil)
            }
        }

    }
    
    
    //MARK: New user request
    @IBAction func newUser(_ sender: AnyObject) {
        let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup")
        UIApplication.shared.open(url! as URL)
    }

    
    // MARK: -  Error alert setup
    func showAlert(_ sender: UIButton, message: String) {
        let errMessage = message
        
        stopNetworkActivity()
        let alert = UIAlertController(title: nil, message: errMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            alert.dismiss(animated: true, completion: nil)

        }))
        
        self.present(alert, animated: true, completion: nil)

    }
    
    //MARK: Disables input and displays "busy" indicator while performing login.
    func startNetworkActivity() {
        activityIndicator.startAnimating()
        userEmail.isEnabled = false
        userPassword.isEnabled = false
        userLoginButton.isEnabled = false
    }
 
    //MARK: Re-enables input if necessary following login. Also hides "busy" indicator.
    func stopNetworkActivity() {
        activityIndicator.stopAnimating()
        userEmail.isEnabled = true
        userPassword.isEnabled = true
        userLoginButton.isEnabled = true
    }
   
    // MARK: UITextFieldDelegate functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    // MARK: Show/Hide Keyboard functions
    func setupViewResizerOnKeyboardShown() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShowForResizing),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHideForResizing),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    func keyboardWillShowForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height - keyboardSize.height)
        }
    }
    
    func keyboardWillHideForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: viewHeight + keyboardSize.height)
        }
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    



}

