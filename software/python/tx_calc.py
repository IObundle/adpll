################################################################################
###
###   Calculations for TX EYE diagram and TX settling time behavior
###   Done by: Marco Silva-Pereira (marco.silva.pereira@tecnico.utl.pt)
###   Feb 2020
###
#system
import time
import math
#Third party
from scipy import signal #pwelch
import matplotlib.pyplot as plt
import numpy as np
#local
#import sys
#sys.path.append('/mnt/c/Users/marco/Desktop/WSN-Project/ADPLL/utils/py')
import os,sys,inspect
current_dir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
#parent_dir = os.path.dirname(current_dir)
print(current_dir)
sys.path.insert(0, current_dir + str('/utils_py')) 
import pn_calcs_adpll
import eye_calcs as eye
import mplcursors

start_time = time.time()

#time_rm_us = 20 ## <-----------INITIAL TRANSIENT REMOVED
time_rm_us = float(sys.argv[1])
################################################################################
## Open file of negedge clk time
with open('clkn_time_soc0.txt','r') as myFile:
        contents = myFile.read()
clkn_time = np.asarray(contents.split())
clkn_time = clkn_time.astype(int)
clkn_time = clkn_time*1e-15;
aux = np.abs(clkn_time - time_rm_us*1e-6)
idx = np.where(aux == np.min(aux));
idx = idx[0][0]
clkn_time = clkn_time[idx:] #removes initial transient


## Open file contanining DCO input word of small C bank
with open('dco_s_word_soc0.txt','r') as myFile:
        contents = myFile.read()
dco_s_word = np.asarray(contents.split())
dco_s_word = np.where(dco_s_word =='x', 0 , dco_s_word) 
dco_s_word = dco_s_word.astype(int)
dco_s_word = dco_s_word[idx:] #removes initial transient

dco_s_word_mean= np.sum(dco_s_word) / len(dco_s_word); 
print("dco_s_word_mean = ", dco_s_word_mean)

#Reference clock frequency
F_REF = 32E6
#frequency symbol:
F_SYM = 1e6

############# Shows EYE diagram #############
eye.eye_diagram(dco_s_word-dco_s_word_mean,F_REF,F_SYM,fig_number = 1,ampl_gain = 7500)

############# Shows dco input word transient ############
plt.figure(2)
plt.subplot(412)
plt.plot(clkn_time*1e6,dco_s_word)
plt.ticklabel_format(useOffset=False)
plt.title('DCO small cap bank word vs time in us', fontsize=15)
plt.xlim(clkn_time[0]*1e6, clkn_time[-1]*1e6)


############# Open file contanining ckv period ##############
with open('dco_ckv_time_soc0.txt','r') as myFile:
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

############# Generates square-wave signal from t_CKV ###############

t_CKV2 = np.zeros(len(t_CKV)*2)
CKV2 = np.zeros(len(t_CKV)*2)
for i in range(len(t_CKV2)-1):
    if i%2 == 0:
        t_CKV2[i] = t_CKV[int(i/2)]
        CKV2[i] = -10
    else:
        t_CKV2[i] = t_CKV[int(i/2)] + ( t_CKV[int((i+1)/2)]- t_CKV[int(i/2)] )/2
        CKV2[i] = 10
        
t_CKV2 = t_CKV2[0:-1]
CKV2 = CKV2[0:-1]

############# Shows the dco frequency  ############
plt.subplot(413)
T_dco = t_CKV[1:]-t_CKV[0:-1]
f_dco = 1/ T_dco

plt.plot(t_CKV_real*1e6,f_dco)
plt.ticklabel_format(useOffset=False)
plt.title('DCO frequency vs time in us', fontsize=15)
plt.xlim(time_rm_us, t_CKV_real[-1]*1e6)
    
################## Spectrum calculation using Lomb-Scarglet Method #############
# Spectrum calculation using Lomb Scarglet Method
#Fchannel = 2480e6
Fchannel = float(sys.argv[2])*1e6
spectrum_f = np.linspace(Fchannel-4e6, Fchannel+4e6,80000)
#pgram = signal.lombscargle(t_CKV2,CKV2,wf,normalize=True)
from astropy.timeseries import LombScargle
pgram = LombScargle(t_CKV2, CKV2,normalization='psd').power(spectrum_f)
#Assuming that the oscillator is the only energy source
total_power_bw = np.sum(pgram)
pgram = pgram/total_power_bw

plt.subplot(421)
plt.plot(spectrum_f,10*np.log10(pgram))
plt.title('Spectrum signal (freq bin = '+str(int(spectrum_f[1]-spectrum_f[0]))
          +'Hz', fontsize=14)
plt.ylabel("Normalized PSD (dBc)")
plt.xlabel("Frequency [Hz]")
plt.grid(True)

channel_f = Fchannel + 2e6
channel_fmin = channel_f - 1/2*1e6
channel_fmax = channel_f + 1/2*1e6
channel_power_dBc = pn_calcs_adpll.pn_dbc_bw(pgram,spectrum_f,fmin=channel_fmin,
                                             fmax=channel_fmax)
print(channel_f/1e6,"MHz Channel Power =", channel_power_dBc,"dBc")

channel2_f = Fchannel - 2e6
channel2_fmin = channel2_f - 1/2*1e6
channel2_fmax = channel2_f + 1/2*1e6
channel2_power_dBc = pn_calcs_adpll.pn_dbc_bw(pgram,spectrum_f,fmin=channel2_fmin,
                                            fmax=channel2_fmax)
print(channel2_f/1e6,"MHz Channel Power =", channel2_power_dBc,"dBc")


print("--- %s seconds ---" % (time.time() - start_time))
mplcursors.cursor()
plt.show()
