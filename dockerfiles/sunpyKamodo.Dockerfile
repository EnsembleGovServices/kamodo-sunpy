FROM condaforge/miniforge3

RUN conda config --add channels conda-forge
RUN conda config --set channel_priority strict
RUN conda install python=3.7
RUN conda install sunpy

WORKDIR /

RUN git clone https://github.com/EnsembleGovServices/kamodo-core.git

RUN pip install -e kamodo-core

RUN conda install jupytext jupyter


RUN conda install -c plotly plotly-orca==1.2.1 psutil requests

RUN apt-get update
RUN apt-get -y install xvfb
