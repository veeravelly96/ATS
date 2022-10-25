//
//  StudentSeasonVC.swift
//  AttendanceSystem
//
//  Created by Student on 09/09/2022.
//

import UIKit
import FirebaseDatabase


class StudentAddCourseVC: UIViewController {
    
    var subjectSelectionCompletionHandler: (([SubjectModel]) -> ())?
    
    @IBOutlet var sectionView: UIView!
    @IBOutlet weak var sectionTF: UITextField!
    
    @IBOutlet var subjectView: UIView!
    @IBOutlet weak var subjectTF: UITextField!

    @IBOutlet var addBtn: UIButton!
    
    var subjects = [SubjectModel]()
    var studentId = ""

    let sectionPickerData = [String](arrayLiteral: "A", "B", "C")
    var selctedSection:Section = .A
    var studentSemester:Semester = .Fall
    
    var selctedSubjectId = ""
    
    private let ref = Database.database().reference()
    private let dbPath = "student"
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        sectionTF.setTextField()
        subjectTF.setTextField()
        
        self.navigationItem.title = "Student"
        
        sectionView.RoundCorners(radius: 8)
        subjectView.RoundCorners(radius: 8)
        addBtn.RoundCorners(radius: 8)
        
        sectionTF.delegate = self
        subjectTF.delegate = self
        
        sectionTF.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(sectionTFDoneButtonClicked))
    }
    
    @objc func sectionTFDoneButtonClicked(_ sender: Any) {
        let selectedRow = (sectionTF.inputView as? UIPickerView)?.selectedRow(inComponent: 0)
        sectionTF.text = "Section " + sectionPickerData[selectedRow ?? 0]
        selctedSection = Section.init(rawValue: sectionPickerData[selectedRow ?? 0]) ?? .A
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        validateData()
    }
    
    func validateData() {
        
        var shouldProceed = true
        var message = ""
        
        if (sectionTF.text?.isEmpty)! {
            shouldProceed = false
            message = "Please select section"
        }else if (subjectTF.text?.isEmpty)! {
            shouldProceed = false
            message = "Please select subject"
        }
        else if subjects.contains(where: { ($0.id == self.selctedSubjectId && $0.section == selctedSection)}) {
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
        let course =  SubjectModel.init(id: selctedSubjectId, name: subjectTF.text!, semester: studentSemester, section: selctedSection)
        
        subjects.append(course)
        
        do {
            let data = try JSONEncoder().encode(subjects)
            
            let json = try JSONSerialization.jsonObject(with: data)
            
            ref.child("\(dbPath)/\(studentId)/subjects")
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

extension StudentAddCourseVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == sectionTF {
            let thePicker = UIPickerView()
            thePicker.delegate = self
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
    
    }
    
}

extension StudentAddCourseVC: UIPickerViewDelegate, UIPickerViewDataSource  {
    // MARK: UIPickerView Delegation
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return sectionPickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return "Section " + sectionPickerData[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sectionTF.text = "Section " + sectionPickerData[row]
        selctedSection = Section.init(rawValue: sectionPickerData[row]) ?? .A
    }
}
