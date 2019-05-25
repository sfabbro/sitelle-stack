FROM sfabbro/petuan-notebook:0.3

# Create a Python 2.x environment using conda including at least the ipython kernel
# and the kernda utility. Add any additional packages you want available for use
# in a Python 2 notebook to the first line here (e.g., pandas, matplotlib, etc.)
RUN conda create --quiet --yes -p $CONDA_DIR/envs/python2 python=2.7 \
	ipython ipykernel ipyevents kernda \
	cython bokeh pandas matplotlib scipy seaborn h5py \
	dill bottleneck scikit-learn jupyterlab notebook scikit-image pillow && \
    conda install -n python2 -c astropy pyregion astropy photutils ginga

RUN $CONDA_DIR/envs/python2/bin/pip --no-cache install gvar lsqfit pp --no-deps && \
    $CONDA_DIR/envs/python2/bin/pip --no-cache install git+https://github.com/thomasorb/orb.git && \
    $CONDA_DIR/envs/python2/bin/pip --no-cache install git+https://github.com/thomasorb/orcs.git && \
    $CONDA_DIR/envs/python2/bin/pip --no-cache install vos cadctap cadcdata cadccutout caom2utils && \
    $CONDA_DIR/envs/python2/bin/pip --no-cache install --pre astroquery

RUN conda remove -n python2 --quiet --yes --force qt pyqt && \
    conda clean --all -f -y

# Add shortcuts to distinguish pip for python2 and python3 envs
RUN ln -s $CONDA_DIR/envs/python2/bin/pip $CONDA_DIR/bin/pip2 && \
    ln -s $CONDA_DIR/bin/pip $CONDA_DIR/bin/pip3

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN MPLBACKEND=Agg $CONDA_DIR/envs/python2/bin/python -c "import matplotlib.pyplot"

USER root

# Create a global kernelspec in the image and modify it so that it properly activates
# the python2 conda environment.
RUN $CONDA_DIR/envs/python2/bin/python -m ipykernel install --sys-prefix && \
    $CONDA_DIR/envs/python2/bin/kernda -o -y $CONDA_DIR/envs/python2/share/jupyter/kernels/python2/kernel.json && \
    conda remove -n python2 kernda

USER $NB_USER
