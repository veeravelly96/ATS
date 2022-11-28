//
//  ScanLockViewController.swift
//  AttendanceSystem
//
//  Created by Student on 02/09/2022.
//

import UIKit
import AVFoundation
import FirebaseDatabase

class ScanQRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var frameImgView: UIImageView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet var crossBtn: UIButton!
    
    @IBOutlet weak var lineViewTopCons: NSLayoutConstraint!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var lineTimer: Timer?
    var lineY = 5
    var movingDown = true
    
    var isStoped = false
    var isUsingQR = true
    var counter = 0
    
    private let ref = Database.database().reference()
    private let dbPath = "attendance"
    
    var mySection:Section = .A
    var mySubjectId = ""
    
    var allAttendance = [AttendanceModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        frameView.isHidden = true
        
        fetchAttendanceData()
    }
    
    @objc func MoveLine() -> Void {
        
        if movingDown {
            
            lineY += 5
        }else {
            
            lineY -= 5
        }
        
        if lineY == 240 {
            
            movingDown = false
            
        }else if lineY == 5 {
            
            movingDown = true
        }
        
        lineViewTopCons.constant = CGFloat(lineY)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isStoped = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        frameView.isHidden = false
        lineTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(MoveLine), userInfo: nil, repeats: true)
        InitializeCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        lineTimer?.invalidate()
    }
    
    @IBAction func crossBtnTapped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: false)
    }
    
    //MARK: QR Code
    func InitializeCamera() -> Void {
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
            
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        let scanRect = CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height/2 - 125, width: 300, height: 300)
        let rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: scanRect)
        metadataOutput.rectOfInterest = rectOfInterest
        
        
        cameraView.layer.addSublayer(previewLayer)
        cameraView.bringSubviewToFront(frameView)
        cameraView.bringSubviewToFront(crossBtn)
        cameraView.bringSubviewToFront(titleLbl)
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if !isStoped {
            
            isStoped = true
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                found(code: stringValue)
            }
            
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        print(code)
        
        lineTimer?.invalidate()
        
        //MARK: Attendance here
        
        do{
            if let json = code.data(using: String.Encoding.utf8){
                if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String: Any] {
                    
                    let facultyId = jsonData["faculty"] as? String ?? ""
                    let subjectId = jsonData["subject"] as? String ?? ""
                    let dateString = jsonData["date"] as? String ?? ""
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = .current
                    dateFormatter.dateFormat = "E, d MMM yyyy h:mm:ss a"
                    let date = dateFormatter.date(from:dateString) ?? Date()
                    let delta = date.distance(to: Date())
                    
                    var attendanceStatus:AttendanceStatus = .Present
                    
                    if delta > 180.0 && delta < 300.0 {
                        attendanceStatus = .Late
                    } else if delta > 300.0 {
                        attendanceStatus = .Absent
                    }
                    
                    var attendance = AttendanceModel.init(id: "", studentId: AppStateManager.shared.getStudentId(), studentName: AppStateManager.shared.loggedInUser?.student?.name ?? "", facultyId: facultyId, subjectId: subjectId, semester: (AppStateManager.shared.loggedInUser?.student?.semester ?? .Fall), section: mySection, date: Date().description, status: attendanceStatus)
                    
                    if !isValidQRCode(jsonData: jsonData) {
                        DispatchQueue.main.async {
                            self.previewLayer.removeFromSuperlayer()
                            
                            Utility.showAlert(title: "Oops!", message: "Invalid QR-Code!", okTapped: {
                                self.navigationController?.popViewController(animated: true)
                            })
                        }
                    }
                    else if isAttendaceMarked(attendance: attendance) {
                        DispatchQueue.main.async {
                            self.previewLayer.removeFromSuperlayer()
                            
                            Utility.showAlert(title: "Oops!", message: "Attendance already marked!", okTapped: {
                                self.navigationController?.popViewController(animated: true)
                            })
                        }
                    }
                    else {
                        markAttendance(attendance: &attendance)
                    }
                }
            }
        }catch {
            print(error.localizedDescription)
            
        }
    }
    
    func markAttendance( attendance:inout AttendanceModel) {
        
       let _ = allAttendance.map({
            
            let dateString = $0.date ?? ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            let date = dateFormatter.date(from:dateString) ?? Date()
            
            dateFormatter.dateFormat = "d MMM yyyy"
            let attendanceDate = dateFormatter.string(from: date)
            let myDate = dateFormatter.string(from: Date())
            
            if ($0.subjectId == attendance.subjectId && $0.section == attendance.section && $0.semester == attendance.semester && $0.facultyId == attendance.facultyId && attendanceDate == myDate) {
                do {
                    var message = "Attendance marked successfully"
                    var title = "On Time!"
                    if attendance.status == .Absent {
                        title = "Absent!"
                        message = "Attendance marked as Absent"
                    }
                    if attendance.status == .Late {
                        title = "Late!"
                        message = "Attendance marked as Late"
                    }
                    let data = try JSONEncoder().encode(attendance)
                    
                    let json = try JSONSerialization.jsonObject(with: data)
                    
                    ref.child("\(dbPath)/\($0.id ?? "")")
                        .setValue(json)
                    
                    DispatchQueue.main.async {
                        self.previewLayer.removeFromSuperlayer()
                        
                        Utility.showAlert(title: title, message: message, okTapped: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                    
                } catch let error {
                    print(error.localizedDescription)
                }
            } else {
                // FIXME: Zeeshan will fix this
            }
        })
        
    }
    
    func fetchAttendanceData() {
        
        ref.child(dbPath).getData(completion: {[weak self] error, snapshots in
            if error == nil {
                guard let self = self, let children = snapshots?.children.allObjects as? [DataSnapshot] else {
                    return
                }
                
                self.allAttendance = children.compactMap { snapshot in
                    return AttendanceModel(snapshot: snapshot)
                }
                
                self.allAttendance = self.allAttendance.filter({
                    return $0.studentId == AppStateManager.shared.getStudentId()
                })
            }
        })
    }
    
    func isAttendaceMarked(attendance:AttendanceModel)-> Bool {
        
            let todayAttendance = allAttendance.filter({
            
            let dateString = $0.date ?? ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            let date = dateFormatter.date(from:dateString) ?? Date()
            
            dateFormatter.dateFormat = "d MMM yyyy"
            let attendanceDate = dateFormatter.string(from: date)
            let myDate = dateFormatter.string(from: Date())
            
            return ($0.subjectId == attendance.subjectId && $0.section == attendance.section && $0.semester == attendance.semester && $0.facultyId == attendance.facultyId && attendanceDate == myDate && $0.status != .Absent)
        })
        
        return todayAttendance.count > 0
    }
    
    func isValidQRCode(jsonData: [String:Any])-> Bool {
        
        let year = jsonData["year"] as? String ?? ""
        let semester = jsonData["semester"] as? String ?? ""
        let section = jsonData["section"] as? String ?? ""
        let dateString = jsonData["date"] as? String ?? ""
        let subjectId = jsonData["subject"] as? String ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "E, d MMM yyyy h:mm:ss a"
        let qrDate = dateFormatter.date(from:dateString) ?? Date()
        
        dateFormatter.dateFormat = "d MMM yyyy"
        let attendanceDate = dateFormatter.string(from: qrDate)
        let todayDate = dateFormatter.string(from: Date())
        
        if year == AppStateManager.shared.loggedInUser?.student?.year, semester == AppStateManager.shared.loggedInUser?.student?.semester?.rawValue.description, attendanceDate == todayDate, section == mySection.rawValue.description, subjectId == mySubjectId, section == mySection.rawValue.description {
            return true
        }
        
        return false
    }
    
}
