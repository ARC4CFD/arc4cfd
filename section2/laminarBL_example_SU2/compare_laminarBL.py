import numpy as np
import matplotlib.pyplot as plt

data6533_s=np.loadtxt("65x33/stretched/result.dat", unpack=True)
data6533_u=np.loadtxt("65x33/uniform/result.dat", unpack=True)
data6550_u=np.loadtxt("65x50/results.dat", unpack=True)
data6565_s=np.loadtxt("65x65/stretched/result.dat", unpack=True)
data6565_u=np.loadtxt("65x65/uniform/result.dat", unpack=True)
data65130_u=np.loadtxt("65x130/results.dat", unpack=True)

plt.plot(data6533_u[1],data6533_u[0],label="65x33 uniform", color="b", alpha=0.25, lw=2)
plt.plot(data6565_u[1],data6565_u[0],label="65x65 uniform", color="b", alpha=0.5, lw=2)
plt.plot(data65130_u[1],data65130_u[0],label="65x130 uniform", color="b", lw=2)


plt.plot(data6533_s[1],data6533_s[0],label="65x33 stretched", color="r", alpha=0.25, lw=2)
plt.plot(data6550_u[1],data6550_u[0],label="65x50 stretched", color="r", alpha=0.5, lw=2)
plt.plot(data6565_s[1],data6565_s[0],label="65x65 stretched", color="r", alpha=1, lw=2)
plt.xlabel(r"<U>")
plt.xlabel(r"y")
plt.legend()
plt.ylim(0,0.00185)
plt.xlim(0,1.1)
plt.savefig("ARC4CFD_compareBL.png")




data6533_s=np.loadtxt("65x33/stretched/resultT.dat", unpack=True)
data6533_u=np.loadtxt("65x33/uniform/resultT.dat", unpack=True)
data6550_u=np.loadtxt("65x50/results.dat", unpack=True)
data6565_s=np.loadtxt("65x65/stretched/resultT.dat", unpack=True)
data6565_u=np.loadtxt("65x65/uniform/resultT.dat", unpack=True)
data65130_u=np.loadtxt("65x130/resultT.dat", unpack=True)


plt.figure()
plt.plot(data6533_u[1],data6533_u[0],label="65x33 uniform", color="b", alpha=0.25, lw=2)
plt.plot(data6565_u[1],data6565_u[0],label="65x65 uniform", color="b", alpha=0.5, lw=2)
plt.plot(data65130_u[1],data65130_u[0],label="65x130 uniform", color="b", lw=2)


plt.plot(data6533_s[1],data6533_s[0],label="65x33 stretched", color="r", alpha=0.25, lw=2)
#plt.plot(data6550_u[1],data6550_u[0],label="65x50 stretched", color="r", alpha=0.5, lw=2)
plt.plot(data6565_s[1],data6565_s[0],label="65x65 stretched", color="r", alpha=1, lw=2)
plt.xlabel(r"<T>")
plt.xlabel(r"y")
plt.legend()
plt.ylim(0,0.00185)
plt.xlim(0.5,1.1)
plt.savefig("ARC4CFD_compareBL_T.png")
plt.show()
