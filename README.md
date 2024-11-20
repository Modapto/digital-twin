# MODAPTO Component "Digital Twin"

This component is based on FA³ST Service (branch `feature/submodel-template-processor`) and extends it with a custom submodel template (SMT) processor for handling SMTs of type Simulation, i.e., containing FMUs.

This repository creates a docker image containing both components in a single container including a default configuration file enabled the SMT processor.
The container can be used and configured the same as the regular FA³ST Service container at https://hub.docker.com/r/fraunhoferiosb/faaast-service.
For details, see the FA³ST Service documentation https://faaast-service.readthedocs.io/en/latest/.
