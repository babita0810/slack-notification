#!/bin/bash

CENTRALIZED_PROJECT_ID="centralized-log-monitoring"

setup_log_sink(){
    source_project=$1
    sink_name="log-sink1"
    # local service_account="$3"
    echo "Setting up Log Sink in Source Project: $source_project"

    if  gcloud projects describe "$source_project" &>/dev/null; then
       

        if ! gcloud logging sinks describe "$sink_name" --project="$source_project" &>/dev/null; then

            gcloud config set project "$source_project"
            
            echo "Creating log sink for "$source_project" project"
            gcloud logging sinks create "$sink_name" "logging.googleapis.com/projects/$CENTRALIZED_PROJECT_ID/locations/global/buckets/centralized-logs" 
            service_account=$(gcloud logging sinks describe "$sink_name" --project="$source_project" --format="value(writerIdentity)" | cut -d':' -f2-)
            echo "$service_account"
            gcloud projects add-iam-policy-binding "$CENTRALIZED_PROJECT_ID" --member="serviceAccount:$service_account" --role="roles/logging.configWriter" --condition="expression=resource.name.endsWith('locations/global/buckets/centralized-logs'),title=serviceAccount:$service_account"
        else    
            echo "Error: Log sink $sink_name already exists in source project $source_project."
        fi
    else
        echo "Source project $source_project does not exist."
    fi

    
}

while read -r source_project ; do 
    setup_log_sink $source_project
    echo "$source_project"
done <<EOF
zapp-ran-demo
EOF


# create_centralized_project(){
#     echo "Creating centralized project" 
#     gcloud projects create centralized-log-monitoring
#     gcloud config set project centralized-log-monitoring
# }

# create_log_bucket(){
#     echo "Creating logging bucket in centralized project"
#     gcloud logging buckets create centralized-log-bucket --location=global
# }

# setup_log_sink{
#     local source_project = $1
#     local sink_name = $2
#     gcloud config set project "$source_project"
#     gcloud logging sinks create "$sink_name" "logging.googleapis.com/projects/$CENTRALIZED_PROJECT_ID/locations/global/buckets/centralized-log-bucket" 
# }

# grant_access{

# }

