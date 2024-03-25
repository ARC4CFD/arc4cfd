import os
import numpy as np
from myFigs import set_size,set_square,set_stretch,set_almostsquare
import matplotlib as mpl
import matplotlib.pyplot as plt
#import matplotlib.ticker as mtick

width = 468

nice_fonts = {
                # Use LaTex to write all text
                 "text.usetex": True,
                 "font.family": "serif",
                # Use 10pt font in plots, to match 10pt font in document
                 "axes.labelsize": 10,
                 "font.size": 10,
                # Make the legend/label fonts a little smaller
                 "legend.fontsize": 8,
                 "xtick.labelsize": 8,
                 "ytick.labelsize": 8,
             }

mpl.rcParams.update(nice_fonts)

expFile = ["exp"]
exp = np.loadtxt(expFile[0])
bfsFile = ["bfs"]
bfs = np.loadtxt(bfsFile[0])

#for i in range (0,len(A)-1):
#    if (A[i,1]-A[i+1,1]>0.5):
#        print("Yes")


fig, axs = plt.subplots(1, 1, figsize=set_size(width))

#axs.scatter(exp[:, 1], exp[:, 0], linewidth=1)
#axs.scatter(exp[:, 3], exp[:, 2], linewidth=1)
#axs.scatter(exp[:, 5], exp[:, 4], linewidth=1)

axs.plot(bfs[:, 1], bfs[:, 0], linewidth=1, alpha=0.5, ls='dotted', color='red', label='Mesh 200k, x=4h')
axs.plot(bfs[:, 2], bfs[:, 0], linewidth=1, alpha=0.5, ls='dotted', color='green', label='Mesh 200k, x=6h')
axs.plot(bfs[:, 3], bfs[:, 0], linewidth=1, alpha=0.5, ls='dotted', color='blue', label='Mesh 200k, x=10h')

axs.plot(bfs[:, 4], bfs[:, 0], linewidth=1, alpha=0.8, ls='--', color='red', label='Mesh 400k, x=4h')
axs.plot(bfs[:, 5], bfs[:, 0], linewidth=1, alpha=0.8, ls='--', color='green', label='Mesh 400k, x=6h')
axs.plot(bfs[:, 6], bfs[:, 0], linewidth=1, alpha=0.8, ls='--', color='blue', label='Mesh 400k, x=10h')

axs.plot(bfs[:, 7], bfs[:, 0], linewidth=2, color='red', label='Mesh 800k, x=4h')
axs.plot(bfs[:, 8], bfs[:, 0], linewidth=2, color='green', label='Mesh 800k, x=6h')
axs.plot(bfs[:, 9], bfs[:, 0], linewidth=2, color='blue', label='Mesh 800k, x=10h')

axs.legend()

axs.set_xlabel('$U/U_{o}$', labelpad=0)
axs.set_ylabel('$y/h$', labelpad=0)


#axs[0].set_xlabel('$k$', labelpad=0)
#axs[0].set_ylabel('$E(k)<\\epsilon>^{-2/3}$', labelpad=0)
#axs[0].text(-0.192, 1.05, '(a)', transform = axs[0].transAxes)
#axs[0].title('My Title', loc='right')
#axs[0].axis([1, 50000, 1e-10, 1e2])
# Add legends
# Adjust font size
plt.subplots_adjust(left=0.17, bottom=0.15, right=0.9, top=None, wspace=0.2, hspace=None)
plt.savefig('gridConvergence.pdf')
