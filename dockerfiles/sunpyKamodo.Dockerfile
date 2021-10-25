FROM continuumio/anaconda3:latest

RUN conda config --add channels conda-forge
RUN conda config --set channel_priority strict
RUN conda install sunpy

