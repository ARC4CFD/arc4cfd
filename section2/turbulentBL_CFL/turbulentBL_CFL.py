import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import matplotlib.pyplot as plt

width = 468

nice_fonts = {
      # Use LaTex to write all text
        "text.usetex": True,
        "font.family": "serif",
      # Use 10pt font in plots, to match 10pt font in document
        "axes.labelsize": 14,
        "font.size": 14,
      # Make the legend/label fonts a little smaller
        "legend.fontsize": 13,
        "xtick.labelsize": 13,
        "ytick.labelsize": 13,
}

def set_size(width, fraction=1):
    """ Set aesthetic figure dimensions to avoid scaling in latex.
    Parameters
    ----------
    width: float
            Width in pts
    fraction: float
            Fraction of the width which you wish the figure to occupy
    Returns
    -------
    fig_dim: tuple
            Dimensions of figure in inches
    """
    # Width of figure
    fig_width_pt = width * fraction

    # Convert from pt to inches
    inches_per_pt = 1 / 72.27

    # Golden ratio to set aesthetic figure height
    golden_ratio = (5**.5 - 1) / 2

    # Figure width in inches
    fig_width_in = fig_width_pt * inches_per_pt
    # Figure height in inches
    fig_height_in = fig_width_in * golden_ratio

    fig_dim = (fig_width_in, fig_height_in)

    return fig_dim



mpl.rcParams.update(nice_fonts)
plt.figure(figsize=set_size(width))

N=600
y=np.zeros(N)
utau=0.5
nu=1.8205E-5 #%kg/(m*s)
dt=1E-5
yplus=1 
yfirstpoint=yplus*nu/utau

expansionList=[1.01, 1.025, 1.05, 1.1, 1.2]

fig, ax1 = plt.subplots()
ax2 = ax1.twinx()

for expansionRatio in expansionList:
  print(expansionRatio)
  y[0]=0
  y[1]=yfirstpoint
  for i in range(2,N):
    y[i]=(y[i-1]-y[i-2])*expansionRatio+y[i-1]

  u=utau*8.7*(y*utau/nu)**(1./7.)
  ax2.plot(u[:-1],u[:-1]*dt/(y[1:]-y[:-1]), ":", label="expansion="+str(expansionRatio))



ax1.plot(u,y, color="b", lw=3,label="Turbulent profile (1/7th law)")

ax1.set_xlabel(r"U")
ax1.set_ylabel(r"y")
ax2.set_ylabel("CFL")
ax1.set_xlim(0,20)
ax1.set_ylim(0,1.5)
fig.legend() 
#%plt.xlim(0,1)
fig.tight_layout()

plt.savefig("ARC4CFD_turbBL.png")
plt.show()
