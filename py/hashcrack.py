#coding:utf8

import hashlib

def  dictionary_attack(password_hash):
    dictionary = ['admin','123456','password123']

    password_found = False

    for dictionary_value in dictionary:
        hashed_value = (hashlib.md5(dictionary_value)).hexdigest()
        if hashed_value == password_hash:
            password_found = True
            recovered_password = dictionary_value

    if password_found == True:
        print "Found match for hashed values \n", password_hash
        print "Password recovered: ", recovered_password

    else:
        print "Password was not found."

def main():
    password_hash = raw_input("Enter hashed value: ")
    dictionary_attack(password_hash)

if __name__ == "__main__":
    main()
