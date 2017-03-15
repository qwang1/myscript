#!/bin/bash

# Use this script to prepare data for upgrade testing
# Author: qwang@redhat.com
# Create date: 2017.03.15
# Modify date: 

set -o nounset
set -o errexit
set -x



prepare_case_ocp_13023()
{
  echo "**************OCP-13023 - [Upgrade] Allow specifying secret data using strings and images and be consumed as volume plugin*************"
  oc new-project qwang13023
  oc create -f https://raw.githubusercontent.com/qwang1/mytestfile/master/secret-datastring-data-image.json 
  oc create -f https://raw.githubusercontent.com/qwang1/mytestfile/master/pod-secret-datastring-data-image-volume.yaml 
  oc describe secret secret-datastring-data-image
  sleep 30
  oc get pod
  oc exec -it pod-secret-datastring-data-image-volume cat /etc/secret-volume/username
  oc exec -it pod-secret-datastring-data-image-volume cat /etc/secret-volume/group
}


prepare_case_ocp_13042()
{
  echo "*********************Could expose resouces limits and requests via ENV from Downward APIs with magic keys***************"
  oc new-project qwang13042
  oc create -f https://raw.githubusercontent.com/openshift-qe/v3-testfiles/master/downwardapi/dapi-resources-env-magic-keys-pod.yaml
  oc create -f https://raw.githubusercontent.com/openshift-qe/v3-testfiles/master/downwardapi/dapi-resources-env-magic-keys-pod-without-requests.yaml
  oc create -f https://raw.githubusercontent.com/openshift-qe/v3-testfiles/master/downwardapi/dapi-resources-env-magic-keys-pod-without-limits.yaml
  oc get pod
  oc logs dapi-resources-env-magic-keys-pod | grep MY_
  oc logs dapi-resources-env-magic-keys-pod-without-requests | grep MY_
  oc logs dapi-resources-env-magic-keys-pod-without-requests | grep MY_
  oc describe pod dapi-resources-env-magic-keys-pod
  oc describe pod dapi-resources-env-magic-keys-pod-without-requests
  oc describe pod dapi-resources-env-magic-keys-pod-without-requests
}


prepare_case_ocp_13044()
{
  echo "*****************OCP-13044 - [Upgrade] Prevent creating further PVC if existing PVC exceeds the quota of requests.storage***********"
  oc new-project qwang13044
  oc create quota my-quota --hard=requests.storage=2Gi
  oc describe quota my-quota
  oc create -f https://raw.githubusercontent.com/openshift-qe/v3-testfiles/master/persistent-volumes/nfs/claim-rox.json
  oc describe quota my-quota
}

prepare_case_ocp_13037()
{ 
  echo "*****************OCP-13037 - [Upgrade] New project which matches selector should share cluster quota******************"
  oc new-project project-a
  oc new-project project-c
  oc label namespace project-a user=dev
  oc label namespace project-c user=qe
  oc create clusterresourcequota crq --project-label-selector=user=dev --hard=pods=10 --hard=services=15 --hard secrets=50 --hard=cpu=2 --hard=memory=2Gi
  oc describe clusterresourcequota crq
}

prepare_case_ocp_13023
prepare_case_ocp_13042
prepare_case_ocp_13037
prepare_case_ocp_13044
