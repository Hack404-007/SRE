========================
BurpUnlimited version 1.7.26 release 1.0
+ Created by: mxcx@fosec.vn
+ Email: mxcxvn@gmail.com
+ Based on: BurpLoader by larry_lau
+ Github: https://github.com/mxcxvn/BurpUnlimited it's opensource
========================

This project is NOT intended to replace BurpLoader. It just EXTENDS BurpLoader's license!

To run the project from the command line: 

java -javaagent:BurpUnlimited.jar -agentpath:lib/libfaketime<osverion> -jar BurpUnlimited.jar

or double click on BurpUnlimited.jar (set permision before)

## Notes: 
- There are some requirements files in lib at current folder:
+ burpsuite_pro_v1.7.26.jar is main object
+ libfaketime* Lib for hook time activation. Sourcecode is at https://github.com/faketime-java/faketime
- For windows, vcredist is required: https://www.microsoft.com/en-gb/download/details.aspx?id=48145
- The folder for_windows_if_you_dont_wanna_install_vcredist is for anyone who don't wana install vcredist, please chose the file for x64 or x86, rename to vcruntime140.dll and copy to BurpUnlimited.jar's folder
- To have no unexpected error, please leave all file in the folders which have not any space character (including java binary file in case not run with default java).
- This version is tested run stable on MACOSX 64 bit, Ubuntu 64 bit, Windows 64 and 32 bit. If you have any error in starting, please try some ways:
+ Change manually your datetime to before 01/10/2017
+ Build your own libfaketime, sourcecode is at https://github.com/faketime-java/faketime 
+ Or contact me mxcxvn@gmail.com

## Hash MD5 version release 1
BurpUnlimited.jar		5cf68ad0cc2d4ee265d0da1469decf21  
lib/
    burpsuite_pro_v1.7.26.jar	5d1cbbebc7fb59a399ae7bcacbe05f74
    libfaketime32.dll		e3842711a065b672dec322c4140b950f
    libfaketime32.jnilib		d2b62d06a972035149bfdefe1605c041
    libfaketime32.so		5c2baa272037207533d74faa4291e91d
    libfaketime64.dll		6659efeee9698609a9ffd9ea8c9d07d1
    libfaketime64.jnilib		ff3dbde6a28f1c59d829cf5665c8e628
    libfaketime64.so		5c2baa272037207533d74faa4291e91d
for_windows_if_you_dont_wanna_install_vcredist/
    vcruntime140_x32.dll		b77eeaeaf5f8493189b89852f3a7a712
    vcruntime140_x64.dll		6c2c88ff1b3da84b44d23a253a06c01b