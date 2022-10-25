//
//  CourseTableViewCell.swift
//  AttendanceSystem
//
//  Created by Student on 02/09/2022.
//

import UIKit

class CourseTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var courseLbl: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var semesterLbl: UILabel!
    @IBOutlet weak var sectionLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
