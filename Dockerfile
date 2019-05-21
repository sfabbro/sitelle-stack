FROM jupyter/scipy-notebook

# Install ginga, ipywidgets and ipyevents for interactive plots                                                                        RUN conda install astropy -y
RUN conda install -c conda-forge ipywidgets -y
RUN pip install ipyevents photutils astroquery ginga
RUN jupyter nbextension enable --py --sys-prefix ipyevents

# Create a Python 2.x environment using conda including at least the ipython kernel
# and the kernda utility.
RUN conda create --quiet --yes -p $CONDA_DIR/envs/python2 python=2.7 ipython ipykernel kernda && \
    conda clean --all -f -y


#WORKDIR /
ENV PATH /opt/conda/envs/python2/bin:$PATH

RUN conda update -n python2 --all -y && \
    conda install -n python2 -y cython bokeh pandas matplotlib scipy seaborn h5py \
    	  	    dill bottleneck scikit-learn jupyterlab notebook scikit-image pillow -y && \
    conda install -n python2 -c conda-forge ipywidgets -y && \
    conda install -n python2 -y -c conda-forge pyregion && \
    conda install -n python2 -y -c astropy photutils astroquery ginga && \
    $CONDA_DIR/envs/python2/bin/pip install ipyevents ipykernel && \
    $CONDA_DIR/envs/python2/bin/pip install gvar lsqfit pp --no-deps && \
    $CONDA_DIR/envs/python2/bin/pip install git+https://github.com/thomasorb/orb.git && \
    $CONDA_DIR/envs/python2/bin/pip install git+https://github.com/thomasorb/orcs.git && \
    $CONDA_DIR/envs/python2/bin/pip install vos cadctap cadcdata cadccutout caom2utils && \
    conda clean --all -f -y

RUN rm -rf .cache/pip

# Add a "USER root" statement followed by RUN statements to install system packages using apt-get,
# change file permissions, etc.

USER root

# Create a global kernelspec in the image and modify it so that it properly activates
# the python2 conda environment.
RUN $CONDA_DIR/envs/python2/bin/python -m ipykernel install && \
$CONDA_DIR/envs/python2/bin/kernda -o -y /usr/local/share/jupyter/kernels/python2/kernel.json

# If you do switch to root, always be sure to add a "USER $NB_USER" command at the end of the
# file to ensure the image runs as a unprivileged user by default.
USER $NB_UID
