FROM jupyter/scipy-notebook:17aba6048f44

#Set the working directory
WORKDIR /home/test/

USER root
RUN apt-get update \
	&& apt-get install r-base -y \
    && apt-get install libcurl4-openssl-dev libxml2-dev -y \
    && R -e 'install.packages(c("forecast", "nnfor"), repos="https://cloud.r-project.org")'

# Modules
COPY requirements.txt /home/test/requirements.txt
RUN pip install -r /home/test/requirements.txt

COPY ts-profiling /home/test/ts-profiling
RUN cd /home/test/ts-profiling && \
    python ./setup.py install

# Add files
COPY notebooks /home/test/notebooks
COPY data /home/test/data
COPY solutions /home/test/solutions

# Allow user to write to directory
USER root
RUN chown -R $NB_USER /home/test \
    && chmod -R 774 /home/test \
    && rm -fR /home/test/work 
USER $NB_USER

# Expose the notebook port
EXPOSE 8888

# Start the notebook server
CMD jupyter notebook --no-browser --port 8888 --ip=0.0.0.0 --NotebookApp.token='' --NotebookApp.disable_check_xsrf=True --NotebookApp.iopub_data_rate_limit=1.0e10
