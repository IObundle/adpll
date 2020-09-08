import numpy as np


def pn_dbc_hz (psd,f, fmin, fmax):
    """ psd is the power-spectral-density of the phase noise in linear unis,
    f is the frequency axis of psd
    fmax-fmax is the integration bandwith
    returns the phase noise per Hz (in dBc)""" 


    aux = np.abs(f - fmin)
    idx_min = np.where(aux == np.min(aux));# print(idx_min[0][0])
    idx_min = idx_min[0][0]
    fmin_int = f[idx_min]

    aux = np.abs(f - fmax)
    idx_max = np.where(aux == np.min(aux))
    idx_max = idx_max[0][0]
    fmax_int = f[idx_max]
    
    PN_dBc_Hz = 10*np.log10( np.sum(psd[idx_min:idx_max])/(idx_max-idx_min))
    #print("PN_dBc_Hz = ", PN_dBc_Hz)
    return PN_dBc_Hz
	
	
def pn_dbc_bw (psd,f,*, fmin = None, fmax=None):
    """ psd is the power-spectral-density of the phase noise in linear unis,
    f is the frequency axis of psd
    fmax-fmax is the integration bandwith
    returns the phase noise per Hz (in dBc)""" 
    if fmin == None:
        fmin=f[0]
    if fmax == None:
        fmax=f[-1]
		

    aux = np.abs(f - fmin)
    idx_min = np.where(aux == np.min(aux)); #print(f[idx_min[0][0]])
    idx_min = idx_min[0][0]
    fmin_int = f[idx_min]

    aux = np.abs(f - fmax)
    idx_max = np.where(aux == np.min(aux)); #print(f[idx_max[0][0]])
    idx_max = idx_max[0][0]
    fmax_int = f[idx_max]
    
    PN_dBc_Hz = 10*np.log10( np.sum(psd[idx_min:idx_max]))
    #print("PN_dBc_Hz = ", PN_dBc_Hz)
    return PN_dBc_Hz

def rms_phase_jitter (psd,f,f0, fmin, fmax):
    """ psd is the power-spectral-density of the phase noise in linear unis,
    f is the frequency axis of psd
    fmax-fmax is the integration bandwith
    returns rms phase jitter in seconds""" 


    aux = np.abs(f - fmin)
    idx_min = np.where(aux == np.min(aux));# print(idx_min[0][0])
    idx_min = idx_min[0][0]
    fmin_int = f[idx_min]

    aux = np.abs(f - fmax)
    idx_max = np.where(aux == np.min(aux))
    idx_max = idx_max[0][0]
    fmax_int = f[idx_max]

    f = f[idx_min:idx_max+1]
    psd = psd[idx_min:idx_max+1]
    Apn = np.zeros(len(psd)-1)

    for i in range(1,len(psd)):
        if psd[i-1] > psd[i]:
            Apn[i-1] = (f[i]-f[i-1])*psd[i]+0.5*(f[i]-f[i-1])*(psd[i-1]-psd[i])
        else:
            Apn[i-1] = (f[i]-f[i-1])*psd[i-1]+0.5*(f[i]-f[i-1])*(psd[i]-psd[i-1])
            
    
    rms_phase_jitter = np.sqrt(2*np.sum(Apn)) / (2*np.pi*f0)
    print("fmin aand fmax ", f[0], f[-1])
    return rms_phase_jitter
