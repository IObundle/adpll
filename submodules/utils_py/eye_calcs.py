import numpy as np
import matplotlib.pyplot as plt

def eye_diagram (data,fs, fsymb,*,fig_number = 1, delay_init = 48,
                 ampl_gain = 5000,eye_ampl_spec = 250e3*0.8 ):
    """ data is the 1-D dada input to generate eye diagram
    fs the sampling frquency of data
    fsymb is the symbol data rate in Hz
    returns ? """

    #number of initial samples to discard
    #delay_init = 48
    data = data[delay_init:]
    #number of eyes to display (must be > 1 and < 2)
    N_eye = 1.5
    # number of samples per symbol
    N_samp_sym = round(fs/fsymb)
    # number of symbols
    N_sym = int(len(data)/N_samp_sym) - 2 #forgets the first and last symbols


    N_samp_N_eye = int(N_samp_sym * N_eye)
    N_samp_extra_eye = int(N_samp_N_eye-N_samp_sym)
    if N_samp_extra_eye%2 == 1:
         N_samp_extra_eye = N_samp_extra_eye + 1
         N_samp_N_eye = N_samp_N_eye + 1

    
    
    data = data*ampl_gain
    eye_matrix=np.zeros((N_sym,N_samp_N_eye))
    
    plt.figure(fig_number)
    plt.title('EYE Diagram', fontsize=16)
    plt.xlabel("Sample Number ("+str(int(N_samp_sym))+" per symbol)", fontsize=14)
    plt.ylabel("Frequency Deviation [Hz]", fontsize=14)

    
    for i in range(0,N_sym):
        idx = (1+i)*N_samp_sym
        eye_matrix[i]= data[round(idx-N_samp_extra_eye/2):round(idx+N_samp_extra_eye/2+N_samp_sym)]
        plt.plot(eye_matrix[i],'b-')

    #plot eye amplitude spec
    plt.plot(np.full(N_samp_N_eye,eye_ampl_spec),'r-')
    plt.plot(np.full(N_samp_N_eye,-eye_ampl_spec),'r-')
    
    #print (eye_matrix)
    #plt.show()
    return eye_matrix
