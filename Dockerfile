FROM sfabbro/petuan-notebook:0.8

RUN pip --no-cache install pycloudy pyneb
# Create a Python 2.x environment using conda including at least the ipython kernel
# and the kernda utility. Add any additional packages you want available for use
# in a Python 2 notebook to the first line here (e.g., pandas, matplotlib, etc.)
RUN conda create --quiet --yes --channel defaults --override-channels -p $CONDA_DIR/envs/python2 python=2.7 \
	ipython ipykernel \
	cython bokeh pandas matplotlib scipy seaborn h5py llvmlite requests numba future \
	dill bottleneck scikit-learn jupyterlab notebook scikit-image pillow pymysql astropy

#RUN conda install -n python2 astropy \
RUN $CONDA_DIR/envs/python2/bin/pip --no-cache install \
	pyregion astropy photutils ginga specutils==0.2.2 \
	reproject aplpy astroquery ipyevents kernda

# CADC
RUN $CONDA_DIR/envs/python2/bin/pip --no-cache install vos cadctap cadcdata cadccutout caom2utils

# SIGNALS
RUN $CONDA_DIR/envs/python2/bin/pip --no-cache install gvar lsqfit pp --no-deps && \
    $CONDA_DIR/envs/python2/bin/pip --no-cache install pycloudy pyneb NebulaBayes astrodendro ppxf && \
    $CONDA_DIR/envs/python2/bin/pip --no-cache install git+https://github.com/thomasorb/orb.git && \
    $CONDA_DIR/envs/python2/bin/pip --no-cache install git+https://github.com/thomasorb/orcs.git

#RUN conda remove -n python2 --quiet --yes --force qt pyqt && \
RUN conda clean --all -f -y

# Add shortcuts to distinguish pip for python2 and python3 envs
RUN ln -s $CONDA_DIR/envs/python2/bin/pip $CONDA_DIR/bin/pip2

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN MPLBACKEND=Agg $CONDA_DIR/envs/python2/bin/python -c "import matplotlib.pyplot"

USER root

# Create a global kernelspec in the image and modify it so that it properly activates
# the python2 conda environment.

RUN $CONDA_DIR/envs/python2/bin/python -m ipykernel install && \
    $CONDA_DIR/envs/python2/bin/kernda -o -y /usr/local/share/jupyter/kernels/python2/kernel.json

# cleanup
RUN $CONDA_DIR/envs/python2/bin/pip uninstall -y qtpy qtconsole kernda

ADD c17.02.tar.gz .
#RUN tar xf c17.02.tar.gz && \
RUN	cd c17.02/source && \
	make -j3 && \
	install -m755 cloudy.exe /usr/local/bin && \
	cd - && rm -rf c17.02

USER $NB_USER
RUN ln -sfn /scratch /home/jovyan
ENV CLOUDY_DATA_PATH "./:/home/$NB_USER/signals/cloudy/data:+"
