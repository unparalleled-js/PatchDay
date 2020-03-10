//
//  PillDetailVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/28/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class PillDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    private var viewModel: PillDetailViewModel!

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var selectNameButton: UIButton!
    @IBOutlet weak var namePicker: UIPickerView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var timesadaySlider: UISlider!
    @IBOutlet weak var time1Button: UIButton!
    @IBOutlet weak var time2Button: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var takeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDelegates()
        handleHardwareConstraints()
        loadSelectNameButton()
        loadTimesadaySlider()
        loadTimeButtons()
        disableSaveButton()
        reflectPillAttributes()
        loadTitle()
    }

    static func createPillDetailVC(_ source: UIViewController, _ pill: Swallowable) -> PillDetailViewController? {
        let id = ViewControllerIds.PillDetail
        if let vc = source.storyboard?.instantiateViewController(withIdentifier: id) as? PillDetailViewController {
            return vc.initWithPill(pill)
        }
        return nil
    }

    fileprivate func initWithPill(_ pill: Swallowable) -> PillDetailViewController {
        viewModel = PillDetailViewModel(pill)
        return self
    }

    // MARK: -- Pill actions
    
    @objc func selectNameTapped() {
        openPicker()
        selectNameButton.setTitle(ActionStrings.Done)
        selectNameButton.replaceTarget(self, newAction: #selector(doneWithSelectNameTapped))
    }

    @objc func doneWithSelectNameTapped() {
        closePicker()
        selectNameButton.setTitle(ActionStrings.Select)
        selectNameButton.replaceTarget(self, newAction: #selector(selectNameTapped))
        if viewModel.selections.name != nil {
            enableSaveButton()
        }
    }
    
    @IBAction func saveButtonTapped() {
        viewModel.save()
        segueToPillsVC()
    }
    
    @IBAction func notificationSwitched(_ sender: Any) {
        enableSaveButton()
    }
    
    @IBAction func timesadaySliderValueChanged(_ sender: Any) {
        let slider = sender as! UISlider
        viewModel.setSelectedTimesadayFromSliderValue(sliderValue: slider.value)
        time2Button.isEnabled = viewModel.sliderValueRepresentsPlurality(sliderValue: slider.value)
        enableSaveButton()
    }
    
    // MARK: - Time picker actions

    @objc func time1ButtonTapped(_ sender: Any) {
        timePicker.isHidden = false
        timePicker.minimumDate = nil
        transformIntoDoneButton(time1Button)
        disableNonTimeInteractions()
        timePicker.date = viewModel.selections.time1 ?? viewModel.pill.time1
        timePicker.maximumDate = time2Button.isEnabled ? viewModel.selections.time2 : nil
        time2Button.isEnabled = false
    }
    
    @objc func time2ButtonTapped(_ sender: Any) {
        timePicker.isHidden = false
        timePicker.maximumDate = nil
        time1Button.isEnabled = false
        transformIntoDoneButton(time2Button)
        disableNonTimeInteractions()
        time1Button.isEnabled = false
        timePicker.minimumDate = viewModel.startMinimumTimePickerTwoTime
        timePicker.date = viewModel.startTimePickerTwoTime
    }
    
    @objc func timePickerDone(sender: Any) {
        if let timeButton = sender as? UIButton {
            setControlsFromTimePickerDone(timeButton: timeButton)
            handleTimeNumberTypeDone(viewModel.createTimeNumberTypeFromButton(timeButton))
        }
    }
    
    // MARK: - Picker functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        DefaultNumberOfPickerComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.pillSelectionCount
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel.providedPillNameSelection[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nameTextField.text = viewModel.selectNameFromRow(row)
    }
    
    // MARK: - Text field
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectNameButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if nameTextField.text == "" {
            nameTextField.text = PillStrings.NewPill
        }
        selectNameButton.isEnabled = true
        viewModel.selections.name = nameTextField.text
        enableSaveButton()
        return true
    }
    
    // MARK: - Private loaders
    
    private func setPickerDelegates() {
        namePicker.delegate = self
        nameTextField.delegate = self
    }
    
    private func handleHardwareConstraints() {
        if AppDelegate.isPad {
            topConstraint.constant = 100
        }
    }
    
    private func loadSelectNameButton() {
         selectNameButton.setTitleColor(UIColor.lightGray, for: .disabled)
         selectNameButton.addTarget(self, action: #selector(selectNameTapped), for: .touchUpInside)
    }
    
    private func loadTimesadaySlider() {
        timesadaySlider.maximumValue = TimesadaySliderDefinition.Max
        timesadaySlider.minimumValue = TimesadaySliderDefinition.Min
    }
    
    private func loadTimeButtons() {
        time1Button.setTitleColor(UIColor.lightGray, for: .disabled)
        time2Button.setTitleColor(UIColor.lightGray, for: .disabled)
        time1Button.addTarget(self, action: #selector(time1ButtonTapped(_:)), for: .touchUpInside)
        time2Button.addTarget(self, action: #selector(time2ButtonTapped(_:)), for: .touchUpInside)
        time1Button.setTitle(ActionStrings.Done, for: .selected)
        time2Button.setTitle(ActionStrings.Done, for: .selected)
        time1Button.setTitleColor(UIColor.blue, for: .selected)
        time2Button.setTitleColor(UIColor.blue, for: .selected)
    }
    
    private func loadTitle() {
        title = viewModel.title
    }

    private func reflectPillAttributes() {
        loadName(from: viewModel.pill)
        loadTimesaday(from: viewModel.pill)
        loadTime1(from: viewModel.pill)
        loadTime2(from: viewModel.pill)
        loadNotify(from: viewModel.pill)
    }
    
    private func loadName(from pill: Swallowable) {
        nameTextField.text = pill.name
    }
    
    private func loadNotify(from pill: Swallowable) {
        notificationSwitch.isOn = pill.notify
    }
    
    private func loadTimesaday(from pill: Swallowable) {
        let sliderValue = TimesadaySliderDefinition.convertTimesadayToSliderValue(timesaday: pill.timesaday)
        timesadaySlider.setValue(sliderValue, animated: false)
        time2Button.isEnabled = pill.timesaday == 2
    }
    
    private func loadTime1(from pill: Swallowable) {
        time1Button.setTitle(viewModel.time1Text)
    }
    
    private func loadTime2(from pill: Swallowable) {
        time2Button.setTitle(viewModel.time2Text)
    }

    private func disableNonTimeInteractions() {
        timesadaySlider.isEnabled = false
        selectNameButton.isEnabled = false
        nameTextField.isEnabled = false
    }

    private func transformIntoDoneButton(_ button: UIButton) {
        button.isSelected = true
        button.replaceTarget(self, newAction: #selector(timePickerDone(sender:)))
    }

    private func handlePickerActivation(opening: Bool) {
        if opening {
            openPicker()
        } else {
            closePicker()
        }
    }

    private func openPicker() {
        startPickerActivation()
        nameTextField.isEnabled = false
        unhideNamePicker()
    }

    private func unhideNamePicker() {
        UIView.transition(
            with: namePicker as UIView,
            duration: 0.4,
            options: .transitionFlipFromTop,
            animations: { self.namePicker.isHidden = false },
            completion: { void in }
        )
    }

    private func startPickerActivation() {
        let nameIndex = viewModel.namePickerStartIndex
        self.namePicker.selectRow(nameIndex, inComponent: 0, animated: false)
    }

    private func closePicker() {
        startPickerActivation()
        nameTextField.isEnabled = true
        self.namePicker.isHidden = true
    }

    private func setControlsFromTimePickerDone(timeButton: UIButton) {
        timeButton.setTitle(PDDateFormatter.formatTime(timePicker.date))
        enableSaveButton()
        timeButton.isSelected = false
        timePicker.isHidden = true
        timesadaySlider.isEnabled = true
        selectNameButton.isEnabled = true
        nameTextField.isEnabled = true
    }

    private func handleTimeNumberTypeDone(_ type: TimeNumber) {
        switch type {
        case .Time1: handleTimeNumberOneDone()
        case .Time2: handleTimeNumberTwoDone()
        }
    }

    private func handleTimeNumberOneDone() {
        viewModel.selections.time1 = timePicker.date
        time1Button.replaceTarget(self, newAction: #selector(time1ButtonTapped(_:)))
        if sliderSaysMoreThanOne() {
            time2Button.isEnabled = true
        }
    }

    private func handleTimeNumberTwoDone() {
        viewModel.selections.time2 = timePicker.date
        time2Button.replaceTarget(self, newAction: #selector(time2ButtonTapped(_:)))
        time1Button.isEnabled = true
    }

    private func enableSaveButton() {
        saveButton.isEnabled = true
        saveButton.tintColor = UIColor.blue
    }
    
    private func disableSaveButton() {
        saveButton.isEnabled = false
        saveButton.tintColor = UIColor.lightGray
    }
    
    private func segueToPillsVC() {
        if let navCon = navigationController {
            navCon.popViewController(animated: true)
        }
    }
    
    private func sliderSaysMoreThanOne() -> Bool {
        TimesadaySliderDefinition.valueIsGreaterThanOne(timesday: timesadaySlider.value)
    }
}
