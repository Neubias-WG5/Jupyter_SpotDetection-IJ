FROM jupyter/minimal-notebook
# ---------------------------------------------------------------------------------------------------------------------
USER root
# Install Java
RUN apt-get update && apt-get install openjdk-8-jdk -y && apt-get clean

# ---------------------------------------------------------------------------------------------------------------------
# Install Cytomine python client
RUN cd / && git clone https://github.com/cytomine-uliege/Cytomine-python-client.git && \
    cd /Cytomine-python-client && git checkout tags/v2.3.0.poc.1 && pip install . && \
    rm -r /Cytomine-python-client

# ---------------------------------------------------------------------------------------------------------------------
# Fiji installation
# Install virtual X server
RUN apt-get update && apt-get install -y unzip xvfb libx11-dev libxtst-dev libxrender-dev

# Install Fiji.
RUN cd / && wget https://downloads.imagej.net/fiji/Life-Line/fiji-linux64-20170530.zip && \
unzip fiji-linux64-20170530.zip && \
mv Fiji.app/ fiji

# create a sym-link with the name jars/ij.jar that is pointing to the current version jars/ij-1.nm.jar
RUN cd /fiji/jars && ln -s $(ls ij-1.*.jar) ij.jar

# Add fiji to the PATH
ENV PATH $PATH:/fiji
RUN mkdir -p /fiji/data

# Clean up
RUN rm /fiji-linux64-20170530.zip

# ---------------------------------------------------------------------------------------------------------------------
# Install Neubias-W5-Utilities (annotation exporter, compute metrics, helpers,...)
RUN cd / && git clone https://github.com/Neubias-WG5/neubiaswg5-utilities.git && \
       cd /neubiaswg5-utilities/ && git checkout tags/v0.8.1 && pip install .

# install utilities binaries
RUN chmod +x /neubiaswg5-utilities/bin/*
RUN cp /neubiaswg5-utilities/bin/* /usr/bin/

# cleaning
RUN rm -r /neubiaswg5-utilities

# ---------------------------------------------------------------------------------------------------------------------
# Install Fiji plugins
RUN cd /fiji/plugins && wget -O imagescience.jar https://imagescience.org/meijering/software/download/imagescience.jar
RUN cd /fiji/plugins && wget -O FeatureJ_.jar https://imagescience.org/meijering/software/download/FeatureJ_.jar

# ---------------------------------------------------------------------------------------------------------------------
# Install Macro
ADD https://raw.githubusercontent.com/Neubias-WG5/W_SpotDetection-IJ/master/IJSpotDetection.ijm /fiji/macros/macro.ijm
ADD https://raw.githubusercontent.com/Neubias-WG5/W_SpotDetection-IJ/master/wrapper.py /app/wrapper.py

# for running the wrapper locally
ADD https://raw.githubusercontent.com/Neubias-WG5/W_SpotDetection-IJ/master/descriptor.json /app/descriptor.json

# changing access rights to the app folder
RUN chmod -R a+rx /app
RUN chmod -R a+rw /fiji

USER ${NB_USER}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}
