//
//  Models.swift
//  cdtp-client
//
//  Created by Yusuf Kursad Kaya on 25.12.2019.
//  Copyright © 2019 Yusuf Kursad Kaya. All rights reserved.
//

import Foundation

struct Building: Codable {
	let instant: Int?
	let gridTotal: Double?
	let renewableTotal: Double?
	let source: String?
	let lastTime: String?
	let dayTotal: Double?
	let peakTotal: Double?
	let nightTotal: Double?
	let loadTime: String?
	
	private enum CodingKeys: String, CodingKey {
		case instant = "INSTANT_CONSUMPTION"
		case gridTotal = "TOTAL_GRID"
		case renewableTotal = "TOTAL_RENEWABLE"
		case source = "SOURCE_TYPE"
		case lastTime = "LAST_TIME"
		case dayTotal = "TOTAL_DAY"
		case peakTotal = "TOTAL_PEAK"
		case nightTotal = "TOTAL_NIGHT"
		case loadTime = "LOAD_TIME"
	}
}

struct Apartment: Codable {
	let id: Int?
	let instant: Int?
	let dayTotal: Double?
	let peakTotal: Double?
	let nightTotal: Double?
	let renewableTotal: Double?
	let source: String?
	let lastTime: String?
	let loadTime: String?
	
	private enum CodingKeys: String, CodingKey {
		case id = "ID"
		case instant = "INSTANT_CONSUMPTION"
		case dayTotal = "TOTAL_DAY"
		case peakTotal = "TOTAL_PEAK"
		case nightTotal = "TOTAL_NIGHT"
		case renewableTotal = "TOTAL_RENEWABLE"
		case source = "SOURCE_TYPE"
		case lastTime = "LAST_TIME"
		case loadTime = "LOAD_TIME"
	}
}

struct Bill: Codable {
	let id: Int?
	let actual: Double?
	let total: Double?
	let discount: Double?
	let day: Double?
	let peak: Double?
	let night: Double?
	let renewable: Double?
	let lastTime: String?
	
	private enum CodingKeys: String, CodingKey {
		case id = "ID"
		case actual = "BILL_ACTUAL"
		case total = "BILL_TOTAL"
		case discount = "BILL_DISCOUNT"
		case day = "BILL_DAY"
		case peak = "BILL_PEAK"
		case night = "BILL_NIGHT"
		case renewable = "BILL_RENEWABLE"
		case lastTime = "LAST_TIME"
	}
}
