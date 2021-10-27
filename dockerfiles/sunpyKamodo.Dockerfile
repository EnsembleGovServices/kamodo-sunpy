FROM condaforge/miniforge3

RUN conda config --add channels conda-forge
RUN conda config --set channel_priority strict
RUN conda install python==3.7
RUN conda install sunpy

RUN pip install kamodo

RUN conda install jupytext jupyter