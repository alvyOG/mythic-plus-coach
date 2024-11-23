#!/bin/bash

export LABEL_STUDIO_LOCAL_FILES_SERVING_ENABLED=true
export LABEL_STUDIO_LOCAL_FILES_DOCUMENT_ROOT=/home/alex/mythic-plus-coach/label-studio/local_data
export DATA_UPLOAD_MAX_MEMORY_SIZE=500000000
export LABEL_STUDIO_DATABASE=label_studio.sqlite3
export LABEL_STUDIO_BASE_DATA_DIR=/home/alex/mythic-plus-coach/label-studio
#export LABEL_STUDIO_LABEL_CONFIG=/home/alex/mythic-plus-coach/label-studio/congis/player_config.xml

label-studio start

