#!/bin/bash

PREFIX="--spring.cloud.function.proxy"
DIR="file:///tmp/function-registry"

tokenize() {
  local IFS=,
  local TOKENS=($1)
  echo ${TOKENS[@]}
}

while getopts ":i:s:f:c:o:p:" opt; do
  case $opt in
    i)
      IN=--spring.cloud.stream.bindings.input.destination=$OPTARG
      ;;
    s)
      FUNC=$OPTARG
      TYPE="$PREFIX.$FUNC.type=supplier"
      RESOURCE="$PREFIX.$FUNC.resource=$DIR/suppliers/$FUNC.fun"
      ;;
    f)
      FUNC=$OPTARG
      for i in `tokenize $OPTARG`; do
        RESOURCE="$RESOURCE $PREFIX.${i}.resource=$DIR/functions/${i}.fun"
        TYPE="$TYPE $PREFIX.${i}.type=function"
      done
      ;;
    c)
      FUNC=$OPTARG
      TYPE="$PREFIX.$FUNC.type=consumer"
      RESOURCE="$PREFIX.$FUNC.resource=$DIR/consumers/$FUNC.fun"
      ;;
    o)
      OUT=--spring.cloud.stream.bindings.output.destination=$OPTARG
      ;;
    p)
      PORT=$OPTARG
      ;;
    esac
done

java -jar ../spring-cloud-function-samples/spring-cloud-function-sample-compiler/target/function-sample-compiler-1.0.0.BUILD-SNAPSHOT.jar\
 --management.security.enabled=false\
 --server.port=$PORT\
 --function.name=$FUNC\
 $IN\
 $OUT\
 $RESOURCE\
 $TYPE
