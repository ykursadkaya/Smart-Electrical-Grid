//
//  BillViewController.swift
//  cdtp-client
//
//  Created by Yusuf Kursad Kaya on 25.12.2019.
//  Copyright © 2019 Yusuf Kursad Kaya. All rights reserved.
//

import UIKit

class BillViewController: UIViewController {
	
	@IBOutlet weak var idLabel: UILabel!
	@IBOutlet weak var totalLabel: UILabel!
	@IBOutlet weak var discountLabel: UILabel!
	@IBOutlet weak var actualLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var dayLabel: UILabel!
	@IBOutlet weak var peakLabel: UILabel!
	@IBOutlet weak var nightLabel: UILabel!
	
	var passedID: Int?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		
		self.updateValues()
		
		Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { (Timer) in
			self.updateValues()
		}
	}
	
	
	func updateValues() {
		if let id = self.passedID {
			CDTPHelper.getBill(id: id) { (bill) in
				if let bill = bill {
					self.idLabel.text = String(bill.id!)
					self.totalLabel.text = String(format: "%.2f", bill.total!) + "₺"
					self.discountLabel.text = "-" + String(format: "%.2f", bill.discount!) + "₺"
					self.actualLabel.text = String(format: "%.2f", bill.actual!) + "₺"
					self.dayLabel.text = String(format: "%.2f", bill.day!) + "₺"
					self.peakLabel.text = String(format: "%.2f", bill.peak!) + "₺"
					self.nightLabel.text = String(format: "%.2f", bill.night!) + "₺"
					if let time = bill.lastTime!.splitAtFirst(delimiter: ".") {
						self.timeLabel.text = time.replacingOccurrences(of: "-", with: "/")
					}
				}
			}
		}
		
	}
	
	
	@IBAction func deletePressed(_ sender: Any) {
		if let id = self.passedID {
			
			let alertController: UIAlertController = UIAlertController(title: "Are you sure?", message: "Delete apartment!", preferredStyle: UIAlertController.Style.alert)
			alertController.addAction(UIAlertAction(title: "Delete",
													style: UIAlertAction.Style.destructive,
													handler: { (alertController) in
														CDTPHelper.deleteApartment(id: id) { (response) in
															if let response = response {
																self.performSegue(withIdentifier: "backToTableSegue", sender: self)
															}
														}}))
			alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
			self.present(alertController, animated: true)
		}
	}
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destination.
	// Pass the selected object to the new view controller.
	}
	*/
	
}
