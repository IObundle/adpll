################################################################################
###
###   Calculations for PN display of
###   'Event-Driven Simulation and Modeling of Phase Noise of a DCOL' TCASII 2005
###
###
#system
import time
import math
#Third party
from scipy import signal #pwelch
import matplotlib.pyplot as plt
import numpy as np
#local
import sys
sys.path.append('/mnt/c/Users/marco/Desktop/WSN-Project/ADPLL/utils/py')
import pn_calcs_adpll

start_time = time.time()

#time_rm_us = 5 ## <-----------INITIAL TRANSIENT REMOVED
time_rm_us = float(sys.argv[1])

################################################################################
## Open file of negedge clk time
with open('clkn_time.txt','r') as myFile:
        contents = myFile.read()
clkn_time = np.asarray(contents.split())
clkn_time = clkn_time.astype(int)
clkn_time = clkn_time*1e-15;
aux = np.abs(clkn_time - time_rm_us*1e-6)
idx = np.where(aux == np.min(aux));
idx = idx[0][0]
clkn_time = clkn_time[idx:] #removes initial transient

## Open file contanining tdc word
with open('tdc_word.txt','r') as myFile:
        contents = myFile.read()
tdc_word = np.asarray(contents.split())
tdc_word = np.where(tdc_word=='x', 0 , tdc_word) 
##tdc_word = tdc_word[tdc_word != 'x']
tdc_word = tdc_word.astype(int)
tdc_word = tdc_word[idx:] #removes initial transient


tdc_word_mean= np.sum(tdc_word) / len(tdc_word); 
print("TDC_word_mean = ", tdc_word_mean)

plt.subplot(413)
plt.plot(clkn_time*1e6,tdc_word)
plt.ticklabel_format(useOffset=False)
plt.title('TDC output word vs time in us', fontsize=15)
plt.xlim(clkn_time[0]*1e6, clkn_time[-1]*1e6)

## Open file contanining DCO input word of small C bank
with open('dco_s_word.txt','r') as myFile:
        contents = myFile.read()
dco_s_word = np.asarray(contents.split())
dco_s_word = np.where(dco_s_word =='x', 0 , dco_s_word) 
dco_s_word = dco_s_word.astype(int)
dco_s_word = dco_s_word[idx:] #removes initial transient

plt.subplot(414)
plt.plot(clkn_time*1e6,dco_s_word)
plt.ticklabel_format(useOffset=False)
plt.title('DCO small cap bank word vs time in us', fontsize=15)
plt.xlim(clkn_time[0]*1e6, clkn_time[-1]*1e6)


################################################################################
## Open file contanining ckv period
with open('dco_ckv_time.txt','r') as myFile:
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


print("--- %s seconds ---" % (time.time() - start_time))


plt.subplot(412)
T_dco = t_CKV[1:]-t_CKV[0:-1]
f_dco = 1/ T_dco

plt.plot(t_CKV_real*1e6,f_dco)
plt.ticklabel_format(useOffset=False)
plt.title('DCO frequency vs time in us', fontsize=15)
plt.xlim(time_rm_us, t_CKV_real[-1]*1e6)




################ Calculates TDEV and PN for CKV_t #################


N = len(T_dco); print(" N = ", N)
T_mean= np.sum(T_dco) / N; print("T_mean = ", T_mean)

f_mean= 1 / T_mean;  print("f_mean = ", f_mean) #f_mean needs to be float for the fs
#f_mean= gl.SEC / T_mean;  print("f_mean = ", f_mean) #f_mean needs to be float for the fs
fs = f_mean #sampling time

N = pow(2, int(math.log(N, 2))) # highest power of 2 less than or equal to
TDEV = np.zeros(N)
PN = np.zeros(N)

for i in range(N):
    #print(i)
    TDEV[i]= t_CKV[i] - (i*T_mean);
    # Relationship between DEV and phase noise (PN)
    PN[i]= 2*np.pi*(TDEV[i]/T_mean);


################ Phase-noise PSD using FFT ########################
    
fft = np.fft.rfft(PN,N) #real fft
N_f = fft.size; print("Number of FFT points = ", N_f)
f_bin = fs/2/N_f
f = np.linspace(0, fs/2, N_f); #print("FFT frequency bin = ", f_bin)
psd = np.abs(fft)**2 / (N_f*2*fs)


plt.subplot(421)
plt.plot(f,10*np.log10(psd))
plt.title('Phase-noise PSD using FFT with a freq bin of '+str(int(f_bin))+' Hz', fontsize=14)
plt.ylabel("PN (dBc)")
plt.xlabel("Frequency [Hz]")
plt.xscale('log')
plt.yticks(np.arange(-160, -40, 20))
plt.ylim(-160, -40)
plt.grid(True)

############### Calculation of PN per Hz of the noise-floor ############
fmin = 0.8e7
fmax = 1.2e7

PN_dBc_Hz = pn_calcs_adpll.pn_dbc_hz(psd,f,fmin,fmax)
print("FFT PN_dBc_Hz = ", PN_dBc_Hz)

################ Phase-noise PSD using Pwelch ########################

f, Pxx_den = signal.welch(PN, fs, nperseg=N/16, nfft = N)
f_bin = f[-1]/len(f)
plt.subplot(422)
plt.plot(f,10*np.log10(Pxx_den*0.5))
plt.title('Phase-noise PSD using Pwelch with a freq bin of '+str(int(f_bin))+' Hz', fontsize=14)
plt.ylabel("PN (dBc)")
plt.xlabel("Frequency [Hz]")
plt.xscale('log')
plt.yticks(np.arange(-160, -40, 20))
plt.ylim(-160, -40)
plt.grid(True)

############### Calculation of PN per Hz of the noise-floor ############
fmin = 0.8e7
fmax = 1.2e7

PN_dBc_Hz = pn_calcs_adpll.pn_dbc_hz(Pxx_den*0.5,f,fmin,fmax)
print("Pwelch PN_dBc_Hz = ", PN_dBc_Hz)



print("--- %s seconds ---" % (time.time() - start_time))
plt.show()
