from serial import Serial
import requests
import json

arduino = Serial('/dev/tty.usbmodem14101', 115200, timeout=.1)
url = 'https://cdtp-server.herokuapp.com/consumption'
headers = {'Content-Type':'application/json'}
while True:
	data = arduino.readline()[:-2] #the last bit gets rid of the new-line chars
	if data:
		payload = data.decode()
		print(data.decode())
		res=requests.post(url,headers=headers,data=payload)
		print(str(res.status_code) + ' ,' + str(res.text))
