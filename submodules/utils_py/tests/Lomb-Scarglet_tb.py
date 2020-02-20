"""
import matplotlib.pyplot as plt
import numpy as np
A = 1.
w = 1.
phi = 0.5 * np.pi
nin = 1000
nout = 100000
frac_points = 0.9 # Fraction of points to select
r = np.random.rand(nin)
x = np.linspace(0.01, 10*np.pi, nin)
x = x[r >= frac_points]

y = A * np.sin(w*x+phi)

f = np.linspace(0.01, 10, nout)



import scipy.signal as signal
pgram = signal.lombscargle(x, y, f, )
print(sum(pgram))
plt.subplot(2, 1, 1)
plt.plot(x, y, 'b+')


plt.subplot(2, 1, 2)
plt.plot(f, pgram)
plt.show()
"""
"""
import numpy as np
rand = np.random.RandomState(42)
t = np.linspace(0,4,20000)
y = np.sin(2 * np.pi *1000* t)
f = np.linspace(500,1500,10000)
from astropy.timeseries import LombScargle
power = LombScargle(t, y,normalization='log').power(f)
print(sum(power))
import matplotlib.pyplot as plt  
plt.plot(f, (power))
plt.show()
"""
import numpy as np
from astropy.timeseries import LombScargle
import astropy.units as u
import math
def fourier_periodogram(t, y):
    N = len(t)
    frequency = np.fft.fftfreq(N, t[1] - t[0])
    y_fft = np.fft.fft(y) 
    positive = (frequency > 0)
    return frequency[positive], (1. / N) * abs(y_fft[positive]) ** 2

#t_days = np.arange(100) * u.day
#y_mags = np.random.randn(100) * u.mag
t = np.linspace(0,10,200000)
y = 2*np.sin(2 * np.pi *1000* t)+1*np.sin(2 * np.pi *2000* t)+1*np.sin(2 * np.pi *4000* t)
frequency, PSD_fourier = fourier_periodogram(t, y)
ls = LombScargle(t, y, normalization='psd')
PSD_LS = ls.power(frequency)
print(sum(PSD_LS))
print(sum(PSD_fourier))
print(len(t))
import matplotlib.pyplot as plt  
plt.plot(frequency,PSD_LS)
plt.plot(frequency,PSD_fourier)
plt.show()
