//
//  SettingsViewController.swift
//  EcoChef
//
//  Created by Jonathan Birge on 6/20/17.
//  Copyright © 2017 Birge Clocks. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

class SettingsViewController:
UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var modelData: ThermalModelData!
    var initialTamb: Float = 0.0
    
    @IBOutlet weak var ambientField: UITextField!
    @IBOutlet weak var ambientStepper: UIStepper!
    @IBOutlet weak var modelPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        modelPicker.selectRow(modelData.selectedIndex, inComponent: 0, animated: true)
        //modelPicker.showsSelectionIndicator = true
        ambientStepper.value = Double(initialTamb)
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        modelPicker.reloadAllComponents()
        modelData.WriteToDisk()
    }
    
    // MARK: Output handling
    
    var selectedModel: Int {
        return modelPicker.selectedRow(inComponent: 0)
    }
    
    var Tamb: Float {
        return Float(ambientStepper.value)
    }

    // MARK: UIPickerView handling
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return modelData.modelArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: modelData.modelArray[row].name)
    }
    
    // MARK: UITableView handling
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                showFAQ()
            case 1:
                showSite()
            default:
                return
            }
        }
    }
    
    func updateViews() {
        let ambientStr = String(Int(Tamb)) + "º F"
        ambientField.text = ambientStr
    }
    
    func showFAQ() {
        if let faqURL = URL(string: EcoChefState.faqURL) {
            let safariViewCont = SFSafariViewController(url:faqURL)
            present(safariViewCont, animated: true, completion: nil)
        }
    }
    
    func showSite() {
        let email = "ecochef@birgefuller.com"
        let subject = "EcoChef"
        //let bodyText = "Type your message here..."
        
        // https://developer.apple.com/documentation/messageui/mfmailcomposeviewcontroller
        if MFMailComposeViewController.canSendMail()
        {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            
            mailComposerVC.setToRecipients([email])
            mailComposerVC.setSubject(subject)
            //mailComposerVC.setMessageBody(bodyText, isHTML: false)
            
            present(mailComposerVC, animated: true, completion: nil)
        }
        else
        {
            print("Device not configured to send email...")
        }
    }

    @IBAction func clickedSave(_ sender: UIBarButtonItem) {
        modelData.selectedIndex = selectedModel
        performSegue(withIdentifier: "UnwindSettings", sender: self)
    }
    
    @IBAction func clickAmbientStepper(_ sender: UIStepper) {
        updateViews()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let modelTableView = segue.destination as? ModelTableViewController {
            modelTableView.modelData = self.modelData
        }
    }
    
}
