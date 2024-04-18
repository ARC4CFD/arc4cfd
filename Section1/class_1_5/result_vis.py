import matplotlib as mpl                                                                        
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import matplotlib.tri as tri
mpl.use('Agg')                 # This enables PNG backend

T_final = pd.read_csv('39204_32.csv',delimiter=',')
nj,ni=T_final.shape

Lx=np.linspace(0,0.06,ni);
Ly=np.linspace(0,0.04,nj);

plt.figure(figsize=(22,14),dpi=200)
plt.contourf(Lx,Ly,T_final,30)
cbar=plt.colorbar(ticks=[400,500,600,700])
cbar.ax.tick_params(labelsize=28)
plt.xlabel('x(m)', fontsize=30)
plt.ylabel('y(m)', fontsize=30)
plt.xticks(fontsize=28)
plt.yticks(fontsize=28)
plt.savefig('temp_cont.png')


