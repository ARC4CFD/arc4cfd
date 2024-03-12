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
plt.xlabel(r"U")
plt.ylabel(r"y")
plt.legend()
plt.ylim(0,0.00185)
plt.xlim(0,1.1)
plt.tight_layout()
plt.savefig("ARC4CFD_compareBL.png")




data6533_s=np.loadtxt("65x33/stretched/resultT.dat", unpack=True)
data6533_u=np.loadtxt("65x33/uniform/resultT.dat", unpack=True)
data6550_u=np.loadtxt("65x50/results.dat", unpack=True)
data6565_s=np.loadtxt("65x65/stretched/resultT.dat", unpack=True)
data6565_u=np.loadtxt("65x65/uniform/resultT.dat", unpack=True)
data65130_u=np.loadtxt("65x130/resultT.dat", unpack=True)


plt.figure(figsize=set_size(width))
plt.plot(data6533_u[1],data6533_u[0],label="65x33 uniform", color="b", alpha=0.25, lw=2)
plt.plot(data6565_u[1],data6565_u[0],label="65x65 uniform", color="b", alpha=0.5, lw=2)
plt.plot(data65130_u[1],data65130_u[0],label="65x130 uniform", color="b", lw=2)


plt.plot(data6533_s[1],data6533_s[0],label="65x33 stretched", color="r", alpha=0.25, lw=2)
#plt.plot(data6550_u[1],data6550_u[0],label="65x50 stretched", color="r", alpha=0.5, lw=2)
plt.plot(data6565_s[1],data6565_s[0],label="65x65 stretched", color="r", alpha=1, lw=2)
plt.xlabel(r"T")
plt.ylabel(r"y")
plt.legend()
plt.ylim(0,0.00185)
plt.xlim(0.5,1.1)
plt.tight_layout()
plt.savefig("ARC4CFD_compareBL_T.png")
plt.show()
