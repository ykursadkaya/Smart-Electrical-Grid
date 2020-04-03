//
//  BuildingViewController.swift
//  cdtp-client
//
//  Created by Yusuf Kursad Kaya on 25.12.2019.
//  Copyright © 2019 Yusuf Kursad Kaya. All rights reserved.
//

import UIKit

class BuildingViewController: UIViewController {
	
	@IBOutlet weak var instantLabel: UILabel!
	@IBOutlet weak var gridLabel: UILabel!
	@IBOutlet weak var renewableLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var sourceLabel: UILabel!
	@IBOutlet weak var dayLabel: UILabel!
	@IBOutlet weak var peakLabel: UILabel!
	@IBOutlet weak var nightLabel: UILabel!
	@IBOutlet weak var loadTimeLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		
		self.updateValues()
		
		Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { (Timer) in
			self.updateValues()
		}
	}
	
	func updateValues() {
		CDTPHelper.getBuilding { (buildingData) in
			if let buildingData = buildingData {
				self.instantLabel.text = String(buildingData.instant!)
				self.gridLabel.text = String(format: "%.2f", buildingData.gridTotal!)
				self.renewableLabel.text = String(format: "%.2f", buildingData.renewableTotal!)
				if let time = buildingData.lastTime!.splitAtFirst(delimiter: ".") {
					self.timeLabel.text = time.replacingOccurrences(of: "-", with: "/")
				}
				self.sourceLabel.text = buildingData.source!
				self.dayLabel.text = String(format: "%.2f", buildingData.dayTotal!)
				self.peakLabel.text = String(format: "%.2f", buildingData.peakTotal!)
				self.nightLabel.text = String(format: "%.2f", buildingData.nightTotal!)
				self.loadTimeLabel.text = buildingData.loadTime!
			}
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
