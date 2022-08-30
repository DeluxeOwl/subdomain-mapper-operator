#!/usr/bin/env bash

ARRAY_COUNT=`jq -r '. | length-1' $BINDING_CONTEXT_PATH`



if [[ $1 == "--config" ]] ; then
  cat <<EOF
configVersion: v1
kubernetes:
  - name: "Monitor and react to services"
    apiVersion: v1
    kind: Service
    executeHookOnEvent: ["Added", "Modified", "Deleted"] # this is the default
    jqFilter: ".metadata.annotations"
EOF
else
  # ignore Synchronization for simplicity
  type=$(jq -r '.[0].type' $BINDING_CONTEXT_PATH)
  if [[ $type == "Synchronization" ]] ; then
    # runs on hook start, should check all services
    echo Got Synchronization event
    exit 0
  fi

  for IND in `seq 0 $ARRAY_COUNT`
  do
    ingressName=`jq -r ".[$IND].object.metadata.annotations[\"automatic-subdomain/ingress\"]" $BINDING_CONTEXT_PATH`

    # ignore if it doesn't have the annotation
    if [[ "${ingressName}" == "null" ]]; then
      exit 0
    fi
    
    bindingName=`jq -r ".[$IND].binding" $BINDING_CONTEXT_PATH`
    resourceEvent=`jq -r ".[$IND].watchEvent" $BINDING_CONTEXT_PATH`
    serviceName=`jq -r ".[$IND].object.metadata.name" $BINDING_CONTEXT_PATH`

    case "${resourceEvent}" in
      "Modified")
        echo "Ingress name annotation modified on ${serviceName}: [automatic-subdomain/ingress: ${ingressName}]"
        kubectl patch ingress $ingressName --type "json" -p "[{'op':'add','path':'/spec/rules/-','value':{'host':'${serviceName}.andreisurugiu.com','http':{'paths':[{'backend':{'service':{'name':'${serviceName}','port':{'number':80}}},'path':'/','pathType':'Prefix'}]}}}]"
      ;;

      "Added")
        echo "Service ${serviceName} was created: [automatic-subdomain/ingress: ${ingressName}]"
        kubectl patch ingress $ingressName --type "json" -p "[{'op':'add','path':'/spec/rules/-','value':{'host':'${serviceName}.andreisurugiu.com','http':{'paths':[{'backend':{'service':{'name':'${serviceName}','port':{'number':80}}},'path':'/','pathType':'Prefix'}]}}}]"
      ;;

      "Deleted")
        echo "Service ${serviceName} was deleted: [automatic-subdomain/ingress: ${ingressName}]"
        index=$(kubectl get ing $ingressName -o json | jq -r ".spec.rules | map(.host == \"${serviceName}.andreisurugiu.com\") | index(true)")
        kubectl patch ingress $ingressName --type=json -p="[{'op':'remove', 'path': '/spec/rules/$index'}]"
      ;;

      *)
        echo "Unknown operation on service ${serviceName}"
      ;;
    esac

  done
fi
