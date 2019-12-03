FROM jupyter/scipy-notebook:17aba6048f44

#Set the working directory
WORKDIR /home/jovyan/

USER root
RUN apt-get update \
	&& apt-get install r-base -y \
    && apt-get install libcurl4-openssl-dev libxml2-dev -y \
    && R -e 'install.packages(c("forecast", "nnfor"), repos="https://cloud.r-project.org")'

# Modules
COPY requirements.txt /home/requirements.txt
RUN pip install -r /home//requirements.txt

COPY ts-profiling /home/ts-profiling
RUN cd /home/ts-profiling && \
    python ./setup.py install

# Add files
COPY notebooks /home/jovyan/notebooks
COPY data /home/jovyan/data
COPY postBuild /home/jovyan/postBuild

# Allow user to write to directory
USER root
RUN chown -R $NB_USER /home/jovyan \
    && chmod -R 774 /home/jovyan \
    && rm -fR /home/jovyan/work \
    && /home/jovyan/postBuild
USER $NB_USER

# Expose the notebook port
EXPOSE 8888
