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
import eye_calcs as eye

start_time = time.time()


fs = 32e6
symbol_rate = 1e6


time = np.arange(0,10e-6,1/fs)

noise = np.random.normal(0, 0.1, len(time))

amplitude = np.sin(2*np.pi*symbol_rate * time) + noise

#plt.plot(time,amplitude)
#plt.show()
eye_matrix = eye.eye_diagram(amplitude,fs,symbol_rate)

print(*eye_matrix)



