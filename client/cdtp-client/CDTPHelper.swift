//
//  CDTPHelper.swift
//  cdtp-client
//
//  Created by Yusuf Kursad Kaya on 25.12.2019.
//  Copyright © 2019 Yusuf Kursad Kaya. All rights reserved.
//

import Foundation

class CDTPHelper {
	
	static let buildingEndpoint = URL(string: "https://cdtp-server.herokuapp.com/all")
	static let apartmentAllEndpoint = URL(string: "https://cdtp-server.herokuapp.com/user")
	static let apartmentEndpoint = "https://cdtp-server.herokuapp.com/user/"
	static let billEndpoint = "https://cdtp-server.herokuapp.com/bill/"
	
	static func delay(_ time: Double, execute: @escaping () -> Void) {
		if time > 0 {
			DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: execute)
		} else {
			DispatchQueue.main.async(execute: execute)
		}
	}
	
	static func getBuilding(completionHandler: @escaping (_ buildingData: Building?) -> ()) {
		if let url = buildingEndpoint {
			let request = NSMutableURLRequest(url: url)
			request.httpMethod = "GET"
			let session = URLSession.shared
			let mData = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
				if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
					self.delay(0) {
						do {
							let decoder = JSONDecoder()
							let building = try decoder.decode(Building.self, from: data)
							completionHandler(building)
						} catch let err {
							print("Err", err)
						}
					}
				} else {
					completionHandler(nil)
					delay(0, execute: {
						return;
					})
				}
			}
			mData.resume()
		}
	}
	
	
	static func getAllApartments(completionHandler: @escaping (_ apartmentList: [Apartment]?) -> ()) {
		if let url = apartmentAllEndpoint {
			let request = NSMutableURLRequest(url: url)
			request.httpMethod = "GET"
			let session = URLSession.shared
			let mData = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
				if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
					self.delay(0) {
						do {
							let decoder = JSONDecoder()
							let apartments = try decoder.decode([Apartment].self, from: data)
							completionHandler(apartments)
						} catch let err {
							print("Err", err)
						}
					}
				} else {
					completionHandler(nil)
					delay(0, execute: {
						return;
					})
				}
			}
			mData.resume()
		}
	}
	
	
	static func getApartment(id: Int,completionHandler: @escaping (_ apartmentData: Apartment?) -> ()) {
		if let url = URL(string: apartmentEndpoint + String(id)) {
			let request = NSMutableURLRequest(url: url)
			request.httpMethod = "GET"
			let session = URLSession.shared
			let mData = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
				if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
					self.delay(0) {
						do {
							let decoder = JSONDecoder()
							let apartment = try decoder.decode(Apartment.self, from: data)
							completionHandler(apartment)
						} catch let err {
							print("Err", err)
						}
					}
				} else {
					completionHandler(nil)
					delay(0, execute: {
						return;
					})
				}
			}
			mData.resume()
		}
	}
	
	
	static func getBill(id: Int,completionHandler: @escaping (_ billData: Bill?) -> ()) {
		if let url = URL(string: billEndpoint + String(id)) {
			let request = NSMutableURLRequest(url: url)
			request.httpMethod = "GET"
			let session = URLSession.shared
			let mData = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
				if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
					self.delay(0) {
						do {
							let decoder = JSONDecoder()
							let bill = try decoder.decode(Bill.self, from: data)
							completionHandler(bill)
						} catch let err {
							print("Err", err)
						}
					}
				} else {
					completionHandler(nil)
					delay(0, execute: {
						return;
					})
				}
			}
			mData.resume()
		}
	}
	
	static func deleteApartment(id: Int,completionHandler: @escaping (_ responseString: String?) -> ()) {
		if let url = URL(string: apartmentEndpoint + String(id)) {
			let request = NSMutableURLRequest(url: url)
			request.httpMethod = "DELETE"
			let session = URLSession.shared
			let mData = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
				if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
					self.delay(0) {
						let responseStr = String(data: data, encoding: .utf8)
						completionHandler(responseStr)
					}
				} else {
					completionHandler(nil)
					delay(0, execute: {
						return;
					})
				}
			}
			mData.resume()
		}
	}
}


extension String {
	func splitAtFirst(delimiter: String) -> String? {
		guard let lowerIndex = (self.range(of: delimiter)?.lowerBound) else { return nil }
		let firstPart: String = .init(self.prefix(upTo: lowerIndex))
		return firstPart
	}
}
