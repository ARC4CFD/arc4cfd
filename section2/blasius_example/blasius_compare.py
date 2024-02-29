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

eta,fp,y,u=np.loadtxt("blasius_data.dat", unpack=True)
print(u[1]/y[1])

plt.plot(u,y, color="b", lw=2)
plt.plot(y*u[1]/y[1],y, "k:", lw=2)
plt.xlabel(r"U")
plt.ylabel(r"y")
plt.legend()
plt.ylim(0,0.0012)
plt.xlim(0,0.015)
plt.tight_layout()
plt.savefig("ARC4CFD_blasius.png")
plt.show()

