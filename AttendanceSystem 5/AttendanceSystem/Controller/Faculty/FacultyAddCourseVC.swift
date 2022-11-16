//
//  FacultySeasonVC.swift
//  AttendanceSystem
//
//  Created by Student on 09/09/2022.
//

import UIKit
import FirebaseDatabase

enum SeasonSource {
    case codeGeneration
    case attendanceReport
}

class FacultyAddCourseVC: UIViewController {
    
    var subjectSelectionCompletionHandler: (([SubjectModel]) -> ())?

    @IBOutlet var semesterView: UIView!
    @IBOutlet weak var semesterTF: UITextField!
    
    @IBOutlet var sectionView: UIView!
    @IBOutlet weak var sectionTF: UITextField!
    
    @IBOutlet var subjectView: UIView!
    @IBOutlet weak var subjectTF: UITextField!
    
    @IBOutlet var timeSlotView: UIView!
    @IBOutlet weak var timeSlotTF: UITextField!

    @IBOutlet var addBtn: UIButton!
    
    var subjects = [SubjectModel]()

    var facultyId = ""

    let semesterPickerData = [String](arrayLiteral: "Fall", "Spring")
    var selctedSemester:Semester = .Fall
    
    let sectionPickerData = [String](arrayLiteral: "A", "B", "C")
    var selctedSection:Section = .A
    
    var selctedSubjectId = ""
    
    private let ref = Database.database().reference()
    private let dbPath = "faculty"
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        semesterTF.setTextField()
        sectionTF.setTextField()
        subjectTF.setTextField()
        timeSlotTF.setTextField()
        
        self.navigationItem.title = "Faculty"
        
        semesterView.RoundCorners(radius: 8)
        sectionView.RoundCorners(radius: 8)
        subjectView.RoundCorners(radius: 8)
        timeSlotView.RoundCorners(radius: 8)
        addBtn.RoundCorners(radius: 8)
        
        semesterTF.delegate = self
        sectionTF.delegate = self
        subjectTF.delegate = self
        timeSlotTF.delegate = self
        
        semesterTF.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(semesterTFDoneButtonClicked))
        sectionTF.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(sectionTFDoneButtonClicked))
        timeSlotTF.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(timeSlotTFDoneButtonClicked))
    }
    
    @objc func semesterTFDoneButtonClicked(_ sender: Any) {
        let selectedRow = (semesterTF.inputView as? UIPickerView)?.selectedRow(inComponent: 0)
        semesterTF.text = semesterPickerData[selectedRow ?? 0]
        selctedSemester = Semester.init(rawValue: selectedRow ?? 0) ?? .Fall
    }
    
    @objc func sectionTFDoneButtonClicked(_ sender: Any) {
        let selectedRow = (sectionTF.inputView as? UIPickerView)?.selectedRow(inComponent: 0)
        sectionTF.text = "Section " + sectionPickerData[selectedRow ?? 0]
        selctedSection = Section.init(rawValue: sectionPickerData[selectedRow ?? 0]) ?? .A
    }
    
    @objc func timeSlotTFDoneButtonClicked(_ sender: Any) {
        if let selectedDate = (timeSlotTF.inputView as? UIDatePicker)?.date  {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            timeSlotTF.text = dateFormatter.string(from: selectedDate)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        validateData()
    }
    
    func validateData() {
        
        var shouldProceed = true
        var message = ""
        
        if (semesterTF.text?.isEmpty)! {
            shouldProceed = false
            message = "Please select semester"
        }else if (sectionTF.text?.isEmpty)! {
            shouldProceed = false
            message = "Please select section"
        }else if (subjectTF.text?.isEmpty)! {
            shouldProceed = false
            message = "Please select subject"
        }else if (timeSlotTF.text?.isEmpty)! {
            shouldProceed = false
            message = "Please select time slot"
        }
        else if subjects.contains(where: { ($0.id == self.selctedSubjectId && $0.section == selctedSection && $0.semester == self.selctedSemester)}) {
            shouldProceed = false
            message = "Course already exist"
        }
        
        if shouldProceed {
            aadCourse()
        }
        else {
            Utility.showAlert(title: "Error", message: message)
        }
    }
    
    func aadCourse() {
        let course =  SubjectModel.init(id: selctedSubjectId, name: subjectTF.text!, semester: selctedSemester, timeSlot: timeSlotTF.text!, section: selctedSection)
        
        subjects.append(course)
        
        do {
            let data = try JSONEncoder().encode(subjects)
            
            let json = try JSONSerialization.jsonObject(with: data)
            
            ref.child("\(dbPath)/\(facultyId)/subjects")
                .setValue(json)
            
            Utility.showAlert(title: "Alert", message: "Course added successfully", okTapped: {
                self.navigationController?.popViewController(animated: true)
                self.subjectSelectionCompletionHandler?(self.subjects)
            })
            
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
        
}

extension FacultyAddCourseVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == semesterTF {
            let thePicker = UIPickerView()
            thePicker.tag = 0
            thePicker.delegate = self
            semesterTF.inputView = thePicker
            if !(textField.text?.isEmpty ?? true) {
                if let selectedIndex = semesterPickerData.firstIndex(where: { $0 == textField.text })  {
                    thePicker.selectRow(selectedIndex, inComponent: 0, animated: true)
                    pickerView(thePicker, didSelectRow: selectedIndex, inComponent: 0)
                }
            }
        }
        else if textField == sectionTF {
            let thePicker = UIPickerView()
            thePicker.delegate = self
            thePicker.tag = 1
            sectionTF.inputView = thePicker
            if !(textField.text?.isEmpty ?? true) {
                if let selectedIndex = sectionPickerData.firstIndex(where: { $0 == textField.text?.replacingOccurrences(of: "Section ", with: "") })  {
                    thePicker.selectRow(selectedIndex, inComponent: 0, animated: true)
                    pickerView(thePicker, didSelectRow: selectedIndex, inComponent: 0)
                }
            }
        }
        else if textField == subjectTF {
            textField.resignFirstResponder()
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "StudentCoursesVC") as! StudentCoursesVC
            VC.source = .addCourse
            VC.subjectSelectionCompletionHandler = { [weak self] selectedSubject in
                guard let self = self else { return }
                self.subjectTF.text = selectedSubject.name ?? ""
                self.selctedSubjectId = selectedSubject.id ?? ""
            }
            self.navigationController!.pushViewController(VC, animated: true)
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        else if textField == timeSlotTF {
            let datePickerView = UIDatePicker()
            datePickerView.datePickerMode = .time
            if #available(iOS 13.4, *) {
                datePickerView.preferredDatePickerStyle = .wheels
            } else {
                // Fallback on earlier versions
            }
            timeSlotTF.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        }
        
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "hh:mm a"
        timeSlotTF.text = dateFormatter.string(from: sender.date)
    }
}

extension FacultyAddCourseVC: UIPickerViewDelegate, UIPickerViewDataSource  {
    // MARK: UIPickerView Delegation
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 0 {
            return semesterPickerData.count
        }
        else {
            return sectionPickerData.count
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 0 {
            return semesterPickerData[row]
        }
        
        else {
            return "Section " + sectionPickerData[row]
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            semesterTF.text = semesterPickerData[row]
            selctedSemester = Semester.init(rawValue: row) ?? .Fall
        }
        else if pickerView.tag == 1 {
            sectionTF.text = "Section " + sectionPickerData[row]
            selctedSection = Section.init(rawValue: sectionPickerData[row]) ?? .A
        }
    }
}
