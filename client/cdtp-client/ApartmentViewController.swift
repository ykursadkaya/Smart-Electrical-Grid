//
//  ApartmentViewController.swift
//  cdtp-client
//
//  Created by Yusuf Kursad Kaya on 25.12.2019.
//  Copyright © 2019 Yusuf Kursad Kaya. All rights reserved.
//

import UIKit

class ApartmentViewController: UIViewController {
	@IBOutlet weak var instantLabel: UILabel!
	@IBOutlet weak var sourceLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var gridLabel: UILabel!
	@IBOutlet weak var renewableLabel: UILabel!
	@IBOutlet weak var idLabel: UILabel!
	@IBOutlet weak var dayLabel: UILabel!
	@IBOutlet weak var peakLabel: UILabel!
	@IBOutlet weak var nightLabel: UILabel!
	@IBOutlet weak var loadTimeLabel: UILabel!
	
	var passedApartment: Apartment?
	var passedID: Int?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		updateValues()
		
		Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { (Timer) in
			self.getValues()
			self.updateValues()
		}
	}
	
	func updateValues() {
		if let apartment = self.passedApartment {
			self.instantLabel.text = String(apartment.instant!)
			self.sourceLabel.text = apartment.source!
			if let time = apartment.lastTime!.splitAtFirst(delimiter: ".") {
				self.timeLabel.text = time.replacingOccurrences(of: "-", with: "/")
			}
			self.gridLabel.text = String(format: "%.2f", (apartment.dayTotal! + apartment.peakTotal! + apartment.nightTotal! - apartment.renewableTotal!))
			self.renewableLabel.text = String(format: "%.2f", apartment.renewableTotal!)
			self.idLabel.text = String(apartment.id!)
			self.dayLabel.text = String(format: "%.2f", apartment.dayTotal!)
			self.peakLabel.text = String(format: "%.2f", apartment.peakTotal!)
			self.nightLabel.text = String(format: "%.2f", apartment.nightTotal!)
			self.loadTimeLabel.text = apartment.loadTime!
		}
	}
	
	
	func getValues() {
		if let passedID = self.passedID {
			CDTPHelper.getApartment(id: passedID) { (apartment) in
				if let apartment = apartment {
					self.passedApartment = apartment
				}
			}
		}
	}
	
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destination.
		// Pass the selected object to the new view controller.
		
		if (segue.identifier == "billSegue") {
			var vc = segue.destination as! BillViewController
			if let id = self.passedID {
				vc.passedID = id
			}
		}
	}
	
}
