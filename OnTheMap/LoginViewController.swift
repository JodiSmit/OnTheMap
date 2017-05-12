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
    //MARK: Change status bar to light color.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        
        Reachability.isInternetAvailable(webSiteToPing: nil) { (isInternetAvailable) in
            guard isInternetAvailable else {
                performUIUpdatesOnMain {
                    self.stopNetworkActivity()
                    self.userPassword?.text = ""
                    self.showAlert(self.userLoginButton!, message: UdacityClient.ErrorMessages.networkError)
                }
                return
            }
            
            UdacityClient.sharedInstance.loginToUdacity((self.userEmail?.text!)!, password: (self.userPassword?.text!)!) {
                (success, ErrorMessage) -> Void in
                guard success else {
                    performUIUpdatesOnMain {
                        self.showAlert(self.userLoginButton!, message: UdacityClient.ErrorMessages.loginError)
                        self.userEmail?.text = ""
                        self.userPassword?.text = ""
                        
                    }
                    return
                }
                
                performUIUpdatesOnMain {
                    self.stopNetworkActivity()
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainTabController") as! UITabBarController
                    self.present(controller, animated: true, completion: nil)
                    self.userEmail?.text = ""
                    self.userPassword?.text = ""
                }
            }
            
        }
    }
    
    //MARK: New user request button pressed
    @IBAction func newUser(_ sender: AnyObject) {
        let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup")
        UIApplication.shared.open(url! as URL)
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
    
}

