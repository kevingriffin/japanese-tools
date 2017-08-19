import appex
from urllib.parse import quote
from objc_util import *

def main():
	if not appex.is_running_extension():
		print('Running in Pythonista app, using test data...\n')
		text = '東京'
	else:
		text = appex.get_text()
	if text:
		url  = u"japanese://search/"
		text = quote(text)
		UIApplication.sharedApplication().openURL_(nsurl(url + text))
	else:
		print('No input text found.')

if __name__ == '__main__':
	main()
