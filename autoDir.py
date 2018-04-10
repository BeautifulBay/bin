#!/usr/bin/env python
#-*- coding = utf-8 -*-

import sys
import os
from getopt import getopt, GetoptError

src = ['Kernel', 'Lk', 'Packages', 'Android', 'Modem']

def getDir(argv):
	if len(argv) == 1:
		#pathSplit = os.getcwd().split('/')
		#print pathSplit
		pathSplit = os.path.split(os.getcwd())[-1]
	else:
		try:
			options, args = getopt(argv[1:], 'a:')
		except GetoptError:
			print 'Error input1\n'
			sys.exit()
		if options == []:
			if '-a' in args:
				args.remove('-a')
			if len(args) == 1:
				pathSplit = os.path.split(args[0])[-1]
				pathSplit = pathSplit + '/' + pathSplit
			elif len(args) > 1:
				pathSplit = []
				for path in args:
					pathSplit.append(path)
		else:
			for name, value in options:
				if name == '-a':
					print value
					if value == None:
						print 'Error input2\n'
						sys.exit()
					elif len(argv) == 3:
						pathSplit = os.path.split(value)[-1]
						pathSplit = pathSplit + '/' + pathSplit
					elif len(argv) > 3:
						pathSplit = []
						for path in value:
							pathSplit.append(path)
				else:
					print 'Error input3\n'
					sys.exit()
	return pathSplit

def createDir(original):
	def createDirGroup(tempDir):
		for Dir in src:
			os.mkdir(tempDir + '_' + Dir)
			print "mkdir %s done!" % (tempDir + '_' + Dir)
	
	if isinstance(original, list):
		for tempDir in original:
			os.mkdir(tempDir)
			print "mkdir %s done!" % (tempDir)
			createDirGroup(tempDir + '/' + tempDir)
	else:
		if original.find('/') > 0:
			os.mkdir(original.split('/')[0])
			print "mkdir %s done!" % original.split('/')[0]
		createDirGroup(original)

if __name__ == '__main__':
	path = getDir(sys.argv)
	createDir(path)

