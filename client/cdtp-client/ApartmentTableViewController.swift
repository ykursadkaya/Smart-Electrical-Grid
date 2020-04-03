//
//  ApartmentTableViewController.swift
//  cdtp-client
//
//  Created by Yusuf Kursad Kaya on 25.12.2019.
//  Copyright © 2019 Yusuf Kursad Kaya. All rights reserved.
//

import UIKit

class ApartmentTableViewController: UITableViewController {
	
	var apartments = [Apartment]()
	var apartmentToPass: Apartment?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem
		self.updateList()
		
		Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { (Timer) in
			self.updateList()
			self.tableView.reloadData()
		}
		
	}
	
	func updateList() {
		CDTPHelper.getAllApartments { (apartmentList) in
			if let apartmentList = apartmentList {
				self.apartments = apartmentList
				self.tableView.reloadData()
			}
		}
	}
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return self.apartments.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "apartmentCell", for: indexPath)
		
		cell.textLabel?.text = String(apartments[indexPath.row].id!)
		let rowInstant = apartments[indexPath.row].instant!
		cell.detailTextLabel?.text = "Instant consumption: \(rowInstant) watt"
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedApartment = self.apartments[indexPath.row]
		apartmentToPass = selectedApartment
		performSegue(withIdentifier: "apartmentDetailSegue", sender: self)
	}
	
	/*
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
	// Return false if you do not want the specified item to be editable.
	return true
	}
	*/
	
	/*
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
	if editingStyle == .delete {
	// Delete the row from the data source
	tableView.deleteRows(at: [indexPath], with: .fade)
	} else if editingStyle == .insert {
	// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	}    
	}
	*/
	
	/*
	// Override to support rearranging the table view.
	override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
	
	}
	*/
	
	/*
	// Override to support conditional rearranging of the table view.
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
	// Return false if you do not want the item to be re-orderable.
	return true
	}
	*/
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destination.
		// Pass the selected object to the new view controller.
		
		if (segue.identifier == "apartmentDetailSegue") {
			var vc = segue.destination as! ApartmentViewController
			if let apartmentToPass = self.apartmentToPass {
				vc.passedApartment = apartmentToPass
				vc.passedID = apartmentToPass.id
			}
		}
	}
	
	
	@IBAction func unwindToViewController(segue: UIStoryboardSegue) {

		//code

	}
	
}
