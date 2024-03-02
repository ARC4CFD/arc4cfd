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
fig= plt.figure(figsize=set_size(width))
ax = fig.add_subplot(1,1,1)
ubuffer=np.linspace(0,14,100)
ylog=np.linspace(5,1000,2000)
#plt.plot(ubuffer,ubuffer,label="u_\tau=y^+", color="r", lw=2)
#plt.plot(5.6*np.log(ylog)+4.9,ylog,label="u_\tau=y^+", color="r", lw=2)
plt.semilogx(ubuffer,ubuffer,label=r"$u^*=y^+$")
plt.semilogx(ylog,5.6*np.log10(ylog)+4.9,label=r"$5.6 \log(y^+)+4.9$")
plt.xlim(1,900)
plt.ylabel(r"$u^*$")
plt.xlabel(r"$y^+$")
plt.legend()

plt.grid(which='both')

plt.tight_layout()
plt.savefig("ARC4CFD_lawoftheWall_semiLog.svg")

fig= plt.figure(figsize=set_size(width))
plt.plot(ubuffer,ubuffer,label=r"$u^*=y^+$")
plt.plot(ylog,5.6*np.log10(ylog)+4.9,label=r"$5.6 \log(y^+)+4.9$")
plt.xlim(1,100)
plt.ylabel(r"$u^*$")
plt.xlabel(r"$y^+$")
plt.legend()

plt.grid(which='both')

plt.tight_layout()
plt.savefig("ARC4CFD_lawoftheWall.svg")
plt.show()
