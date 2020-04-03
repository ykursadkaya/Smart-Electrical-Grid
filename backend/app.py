from flask import Flask, request, g, jsonify
from datetime import datetime
import sqlite3

app = Flask(__name__)
app.url_map.strict_slashes = False


DATABASE = 'db.db3'


def get_db():
	db = getattr(g, '_database', None)
	if db is None:
		db = g._database = sqlite3.connect(DATABASE)
	return db


def init_db():
	with app.app_context():
		db = get_db()
		db.cursor().execute('CREATE TABLE IF NOT EXISTS Users (ID INTEGER PRIMARY KEY,TOTAL_DAY INTEGER,TOTAL_PEAK INTEGER,TOTAL_NIGHT INTEGER,TOTAL_RENEWABLE INTEGER,SOURCE_TYPE TEXT,LOAD_TIME TEXT,INSTANT_CONSUMPTION INTEGER, LAST_TIME TEXT);')
		db.commit()


def dict_factory(cursor, row):
	d = {}
	for idx, col in enumerate(cursor.description):
		d[col[0]] = row[idx]
	return d


def kwh(w):
	return w * 0.04


@app.teardown_appcontext
def close_connection(exception):
	db = getattr(g, '_database', None)
	if db is not None:
		db.close()

@app.route('/consumption/', methods=['POST'])
def setConsumptionAll():
	req_data = request.get_json()

	lastTime = str(datetime.now())

	db = get_db()
	db.row_factory = dict_factory
	c = db.cursor()

	source = req_data.get('kaynak')
	userList = req_data.get('liste')
	loadTime = req_data.get('zaman')
	if (source is None) or (userList is None) or (loadTime is None):
		return ('', 400)

	responseCode = 200

	for user in userList:
		userID = user.get('id')
		userInstant = user.get('watt')
		userkWh = kwh(userInstant)

		userValues = []
		c.execute('SELECT * FROM Users WHERE ID = ?', (user.get('id'),))
		dbUser = c.fetchone()
		if dbUser is None:
			responseCode = 201

			if source == 'sebeke':
				if loadTime == 'gunduz':
					userValues = [userID, userkWh, 0, 0, 0, 'grid', 'day', userInstant, lastTime]
				elif loadTime == 'puant':
					userValues = [userID, 0, userkWh, 0, 0, 'grid', 'peak', userInstant, lastTime]
				elif loadTime == 'gece':
					userValues = [userID, 0, 0, userkWh, 0, 'grid', 'night', userInstant, lastTime]
			elif source == 'yenilenebilir':
				if loadTime == 'gunduz':
					userValues = [userID, userkWh, 0, 0, userkWh, 'renewable', 'day', userInstant, lastTime]
				elif loadTime == 'puant':
					userValues = [userID, 0, userkWh, 0, userkWh, 'renewable', 'peak', userInstant, lastTime]
				elif loadTime == 'gece':
					userValues = [userID, 0, 0, userkWh, userkWh, 'renewable', 'night', userInstant, lastTime]

			c.execute('INSERT INTO Users VALUES (?,?,?,?,?,?,?,?,?)', userValues)

		else:
			if source == 'sebeke':
				if loadTime == 'gunduz':
					userValues = [userkWh + dbUser.get('TOTAL_DAY'), dbUser.get('TOTAL_PEAK'), dbUser.get('TOTAL_NIGHT'), dbUser.get('TOTAL_RENEWABLE'), 'grid', 'day', userInstant, lastTime, userID]
				elif loadTime == 'puant':
					userValues = [dbUser.get('TOTAL_DAY'), userkWh + dbUser.get('TOTAL_PEAK'), dbUser.get('TOTAL_NIGHT'), dbUser.get('TOTAL_RENEWABLE'), 'grid', 'peak', userInstant, lastTime, userID]
				elif loadTime == 'gece':
					userValues = [dbUser.get('TOTAL_DAY'), dbUser.get('TOTAL_PEAK'), userkWh + dbUser.get('TOTAL_NIGHT'), dbUser.get('TOTAL_RENEWABLE'), 'grid', 'night', userInstant, lastTime, userID]
			elif source == 'yenilenebilir':
				if loadTime == 'gunduz':
					userValues = [userkWh + dbUser.get('TOTAL_DAY'), dbUser.get('TOTAL_PEAK'), dbUser.get('TOTAL_NIGHT'), userkWh + dbUser.get('TOTAL_RENEWABLE'), 'renewable', 'day', userInstant, lastTime, userID]
				elif loadTime == 'puant':
					userValues = [dbUser.get('TOTAL_DAY'), userkWh + dbUser.get('TOTAL_PEAK'), dbUser.get('TOTAL_NIGHT'), userkWh + dbUser.get('TOTAL_RENEWABLE'), 'renewable', 'peak', userInstant, lastTime, userID]
				elif loadTime == 'gece':
					userValues = [dbUser.get('TOTAL_DAY'), dbUser.get('TOTAL_PEAK'), userkWh + dbUser.get('TOTAL_NIGHT'), userkWh + dbUser.get('TOTAL_RENEWABLE'), 'renewable', 'night', userInstant, lastTime, userID]

			c.execute('UPDATE Users SET TOTAL_DAY = ?, TOTAL_PEAK = ?, TOTAL_NIGHT = ?, TOTAL_RENEWABLE = ?, SOURCE_TYPE = ?, LOAD_TIME = ?, INSTANT_CONSUMPTION = ?, LAST_TIME = ? WHERE ID = ?', userValues)

		db.commit()

	return ('', responseCode)


@app.route('/user/', methods=['GET'])
def sendUsers():
	db = get_db()
	db.row_factory = dict_factory
	c = db.cursor()

	c.execute('SELECT * FROM Users')
	dbAll = c.fetchall()

	if dbAll == []:
		return ('No user found!', 404)
	else:
		return (jsonify(dbAll), 200)


@app.route('/user/<int:id>', methods=['GET'])
def sendUser(id):
	db = get_db()
	db.row_factory = dict_factory
	c = db.cursor()

	c.execute('SELECT * FROM Users WHERE ID = ?', (id,))
	dbUser = c.fetchone()

	if dbUser is not None:
		return (jsonify(dbUser), 200)
	else:
		return ('User not found!', 404)


@app.route('/all/', methods=['GET'])
def sendAll():
	db = get_db()
	db.row_factory = dict_factory
	c = db.cursor()

	c.execute('SELECT SUM(TOTAL_DAY), SUM(TOTAL_PEAK), SUM(TOTAL_NIGHT), SUM(TOTAL_RENEWABLE), SUM(INSTANT_CONSUMPTION), LAST_TIME, SOURCE_TYPE, LOAD_TIME FROM Users')
	dbAllInfo = c.fetchone()
	if None not in dbAllInfo.values():
		dbTotalDay = dbAllInfo.get('SUM(TOTAL_DAY)')
		dbTotalPeak = dbAllInfo.get('SUM(TOTAL_PEAK)')
		dbTotalNight = dbAllInfo.get('SUM(TOTAL_NIGHT)')
		dbTotalRenewable = dbAllInfo.get('SUM(TOTAL_RENEWABLE)')
		dbTotalGrid = dbTotalDay + dbTotalPeak + dbTotalNight - dbTotalRenewable
		dbTotalInstant = dbAllInfo.get('SUM(INSTANT_CONSUMPTION)')
		dbLastTime =  dbAllInfo.get('LAST_TIME')
		dbSourceType = dbAllInfo.get('SOURCE_TYPE')
		dbLoadTime = dbAllInfo.get('LOAD_TIME')

		responseDict = {'TOTAL_DAY': dbTotalDay, 'TOTAL_PEAK': dbTotalPeak, 'TOTAL_NIGHT': dbTotalNight, 'TOTAL_GRID': dbTotalGrid, 'TOTAL_RENEWABLE': dbTotalRenewable, 'INSTANT_CONSUMPTION': dbTotalInstant, 'LAST_TIME': dbLastTime, 'SOURCE_TYPE': dbSourceType, 'LOAD_TIME': dbLoadTime}

		return (responseDict, 200)
	else:
		return ('Not found', 404)


@app.route('/all/grid', methods=['GET'])
def sendAllGrid():
	db = get_db()
	db.row_factory = dict_factory
	c = db.cursor()

	c.execute('SELECT LAST_TIME, SOURCE_TYPE, SUM(TOTAL_DAY), SUM(TOTAL_PEAK), SUM(TOTAL_NIGHT), SUM(TOTAL_RENEWABLE), LOAD_TIME FROM Users')
	dbGridInfo = c.fetchone()
	if None not in dbGridInfo.values():
		dbLastTime = dbGridInfo.get('LAST_TIME')
		dbSourceType = dbGridInfo.get('SOURCE_TYPE')
		dbLoadTime = dbGridInfo.get('LOAD_TIME')
		dbTotalDay = dbGridInfo.get('SUM(TOTAL_DAY)')
		dbTotalPeak = dbGridInfo.get('SUM(TOTAL_PEAK)')
		dbTotalNight = dbGridInfo.get('SUM(TOTAL_NIGHT)')
		dbTotalRenewable = dbGridInfo.get('SUM(TOTAL_RENEWABLE)')
		dbTotalGrid = dbTotalDay + dbTotalPeak + dbTotalNight - dbTotalRenewable

		responseDict = {'TOTAL_DAY': dbTotalDay, 'TOTAL_PEAK': dbTotalPeak, 'TOTAL_NIGHT': dbTotalDay, 'TOTAL_GRID': dbTotalGrid, 'SOURCE_TYPE': dbSourceType, 'LOAD_TIME': dbLoadTime, 'LAST_TIME': dbLastTime}

		return (responseDict, 200)
	else:
		return ('Not found', 404)


@app.route('/all/renewable', methods=['GET'])
def sendAllRenewable():
	db = get_db()
	db.row_factory = dict_factory
	c = db.cursor()

	c.execute('SELECT LAST_TIME, SOURCE_TYPE, SUM(TOTAL_RENEWABLE), LOAD_TIME FROM Users')
	dbRenewableInfo = c.fetchone()
	if None not in dbRenewableInfo.values():
		dbLastTime = dbRenewableInfo.get('LAST_TIME')
		dbSourceType = dbRenewableInfo.get('SOURCE_TYPE')
		dbLoadTime = dbRenewableInfo.get('LOAD_TIME')
		dbTotalRenewable = dbRenewableInfo.get('SUM(TOTAL_RENEWABLE)')

		responseDict = {'TOTAL_RENEWABLE': dbTotalRenewable, 'SOURCE_TYPE': dbSourceType, 'LOAD_TIME': dbLoadTime, 'LAST_TIME': dbLastTime}

		return (responseDict, 200)
	else:
		return ('Not found', 404)


@app.route('/all/instant', methods=['GET'])
def sendAllInstant():
	db = get_db()
	db.row_factory = dict_factory
	c = db.cursor()

	c.execute('SELECT LAST_TIME, SOURCE_TYPE, SUM(INSTANT_CONSUMPTION), LOAD_TIME FROM Users')
	dbInstantInfo = c.fetchone()
	if None not in dbInstantInfo.values():
		dbLastTime = dbInstantInfo.get('LAST_TIME')
		dbSourceType = dbInstantInfo.get('SOURCE_TYPE')
		dbLoadTime = dbInstantInfo.get('LOAD_TIME')
		dbInstantSum = dbInstantInfo.get('SUM(INSTANT_CONSUMPTION)')

		responseDict = {'INSTANT_CONSUMPTION': dbInstantSum, 'SOURCE_TYPE': dbSourceType, 'LOAD_TIME': dbLoadTime, 'LAST_TIME': dbLastTime}

		return (responseDict, 200)
	else:
		return ('Not found', 404)


@app.route('/bill/<int:id>', methods=['GET'])
def userBill(id):
	db = get_db()
	db.row_factory = dict_factory
	c = db.cursor()

	dayPrice = 0.4463
	peakPrice = 0.6769
	nightPrice = 0.2797

	c.execute('SELECT Count(*), SUM(TOTAL_RENEWABLE) FROM Users')
	dbRenewableInfo = c.fetchone()
	dbUserCount = dbRenewableInfo.get('Count(*)')
	dbTotalRenewable = dbRenewableInfo.get('SUM(TOTAL_RENEWABLE)')

	c.execute('SELECT TOTAL_DAY, TOTAL_PEAK, TOTAL_NIGHT, TOTAL_RENEWABLE, LAST_TIME FROM Users WHERE ID = ?', (id,))
	dbUserTotal = c.fetchone()
	if dbUserTotal is not None:
		dbUserTotalDay = dbUserTotal.get('TOTAL_DAY')
		dbUserTotalPeak = dbUserTotal.get('TOTAL_PEAK')
		dbUserTotalNight = dbUserTotal.get('TOTAL_NIGHT')
		dbUserTotalRenewable = dbUserTotal.get('TOTAL_RENEWABLE')
		dbuserLastTime = dbUserTotal.get('LAST_TIME')

		userBillAmountDay = dbUserTotalDay * dayPrice
		userBillAmountPeak = dbUserTotalPeak * peakPrice
		userBillAmountNight = dbUserTotalNight * nightPrice

		userBillAmount = (userBillAmountDay + userBillAmountPeak + userBillAmountNight) - ((dbTotalRenewable / dbUserCount) * dayPrice)
		userBillOld = userBillAmountDay + userBillAmountPeak + userBillAmountNight
		userDiscount = (dbTotalRenewable / dbUserCount) * dayPrice
		userBillRenewable = dbUserTotalRenewable * dayPrice

		responseDict = {'ID': id, 'BILL_ACTUAL': userBillAmount, 'BILL_DAY': userBillAmountDay, 'BILL_PEAK': userBillAmountPeak, 'BILL_NIGHT': userBillAmountNight, 'BILL_RENEWABLE': userBillRenewable, 'BILL_TOTAL': userBillOld, 'BILL_DISCOUNT': userDiscount, 'LAST_TIME': dbuserLastTime}

		return (responseDict, 200)
	else:
		return ('User not found', 404)


@app.route('/user/<int:id>', methods=['DELETE'])
def deleteUser(id):
	db = get_db()
	db.row_factory = dict_factory
	c = db.cursor()

	c.execute('SELECT * FROM Users WHERE ID = ?', (id,))
	if c.fetchone() is not None:
		c.execute('DELETE FROM Users WHERE ID = ?', (id,))
		db.commit()

		return ('Deleted ID={}'.format(id), 200)
	else:
		return ('User not found', 404)

@app.route('/user/', methods=['DELETE'])
def deleteUsers():
	db = get_db()
	db.row_factory = dict_factory
	c = db.cursor()

	c.execute('DELETE FROM Users')
	db.commit()

	return ('All users deleted', 200)

if __name__ == '__main__':
	init_db()
	app.run(debug=True, port=5000, host= '0.0.0.0')
