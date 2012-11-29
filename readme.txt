
Ontology Services
=============================================

Overview
----------
The main functionality of ontology service is to allow the retrieval of ontology term distribution for a given a set of genes and additionally, identifies statistically overrepresented GO terms within given gene sets. Ontology term distribution and enrichment analysis are one of the main functions needed for the Plants Feb. Demo. Currently, this service provides GO annotation for 13 plant genomes (refer to documentation).

Authors
---------
Shinjae Yoo, BNL (sjyoo@bnl.gov)
Sunita Kumari, CSHL (kumari@cshl.edu)


VERSION: 0.0.1 (Released 11/28/2012)
---------------------------------------------------------------------------------------------
NEW FEATURES:
-This is our first internal release of the Gene Ontology Service.  We have near full functionality from API to CLIs.

Dependencies
----------
-KBase deployment image (last tested on kbase-image-v20)
-KBase typespec module deployed (git repo: typecomp)
-perl Text::NSP module

Deploying and testing on KBase infrastructure
----------
* boot a fresh KBase image (last tested on v20)
* login in as ubuntu and get root access with a sudo su
* enter the following commands:

#First, create the dev_container environment
cd /kb
git clone ssh://kbase@git.kbase.us/dev_container

#Second, build the type compiler
cd /kb/dev_container/modules
git clone ssh://kbase@git.kbase.us/typecomp
cd /kb/dev_container
./bootstrap /kb/runtime
source user-env.sh
make

#Third, check out ontology service
cd /kb/dev_container/modules
git clone ssh://kbase@git.kbase.us/ontology_service

# make and deploy the services
cd /kb/dev_container
make
make deploy

# to test the tree service (using the deployed client)
cd /kb/deployment
source user-env.sh
cd /kb/dev_container/modules/ontology_service
make test


Starting/Stopping the service, and other notes
---------------------------
* to start and stop the service, use the 'start_service' and 'stop_service'
  scripts in /kb/deployment/services/OntologyService
* on test machines, ontology services listen on port 7062, so this port must be open
* after starting the service, the process id of the serivice is stored in the 
  'service.pid' file in /kb/deployment/services/OntologyService


To Do (Task list, created Nov 28, 2012)
----------
1) Add chi square test
