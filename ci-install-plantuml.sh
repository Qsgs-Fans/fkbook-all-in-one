#!/bin/bash

DIR=/home/docs/checkouts/readthedocs.org/user_builds/fkbook-all-in-one/envs/latest/bin
mkdir -p ${DIR}
curl -o ${DIR}/plantuml.jar -L "http://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar"
printf '#!/bin/sh\nexec java -Djava.awt.headless=true -jar '${DIR}'/plantuml.jar "$@"' > ${DIR}/plantuml
chmod +x ${DIR}/plantuml
