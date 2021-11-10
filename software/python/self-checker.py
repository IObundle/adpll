#!/usr/bin/python3

#system
import time
import math
#third party
import numpy as np
#local
import sys
#sys.path.append('/mnt/c/Users/marco/Desktop/WSN-Project/ADPLL/utils/py')

start_time = time.time()

##initial time to be removed (settling time)
#time_rm_us = 5
time_rm_us = 0.0

##Desired channel freq in MHz
freq_channel = 2473.500

##file names suffix
suffix = ""

def usage (message) :
    print ("usage: %s" % message)
    print ("       ./self-checker -t <initial time to remove in us> -f <channel frequency> -s <input files suffix>")
    sys.exit(1)

i = 1
while(i < len(sys.argv)) :
        if (sys.argv[i] == "-t") :
                time_rm_us = float(sys.argv[i+1])
                i += 1
        elif (sys.argv[i] == "-f") :
                expr = sys.argv[i+1]
                if (expr.find('+') != -1):
                        ops = expr.split('+')
                        freq_channel = float(ops[0]) + float(ops[1])
                elif (expr.find('-') != -1):
                        ops = expr.split('-')
                        freq_channel = float(ops[0]) - float(ops[1])
                else:
                        freq_channel = float(expr)
                i += 1
        elif (sys.argv[i] == "-s") :
                suffix = "_" + sys.argv[i+1]
                i += 1
        else : usage("unexpected argument '%s'" % sys.argv[i])
        i += 1

################################################################################
## Open file of negedge clk time

with open('clkn_time' + suffix + '.txt','r+') as myFile:
        contents = myFile.read()
#print(contents)
clkn_time = np.asarray(contents.split())
clkn_time = clkn_time.astype(int)
clkn_time = clkn_time*1e-15;
aux = np.abs(clkn_time - time_rm_us*1e-6)
idx = np.where(aux == np.min(aux));
idx = idx[0][0]
clkn_time = clkn_time[idx:] #removes initial transient

## Open file contanining tdc word
with open('tdc_word' + suffix + '.txt','r+') as myFile:
        contents = myFile.read()
tdc_word = np.asarray(contents.split())
tdc_word = np.where(tdc_word=='x', 0 , tdc_word) 
tdc_word = tdc_word.astype(int)
tdc_word = tdc_word[idx:] #removes initial transient


tdc_word_mean = np.sum(tdc_word) / len(tdc_word);
if (tdc_word_mean > (freq_channel - 0.05)) and (tdc_word_mean < (freq_channel + 0.05)):
        print("TDC word = ",tdc_word_mean, "--> PASS ")
else:
        print("TDC word = ",tdc_word_mean, "--> FAIL ")



################################################################################
## Open file contanining ckv period
with open('dco_ckv_time' + suffix + '.txt','r+') as myFile:
        contents = myFile.read()
t_CKV = np.asarray(contents.split())
t_CKV = t_CKV.astype(int)
t_CKV = t_CKV*1e-15;
aux = np.abs(t_CKV - time_rm_us*1e-6)
idx = np.where(aux == np.min(aux));
idx = idx[0][0]
t_CKV = t_CKV[idx:] #removes initial transient
t_CKV_real = t_CKV[1:]
t_CKV = t_CKV-t_CKV[0] #removes initial transient (for PN calcs)

T_dco = t_CKV[1:]-t_CKV[0:-1]
f_dco = 1/ T_dco / 1e6
f_dco_mean = np.sum(f_dco) / len(f_dco);

if (f_dco_mean > (freq_channel - 0.05)) and (f_dco_mean  < (freq_channel + 0.05)):
        print("DCO freq = ",f_dco_mean, "MHz  --> PASS ")
else:
        print("DCO freq = ",f_dco_mean, "MHz  --> FAIL ")
