#!/bin/bash

temp_archive_name='archive.zip'


while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --src_zip_path) SRC_ZIP_PATH="$2"; shift 2 ;;
        --module_name) MODULE_NAME="$2"; shift 2 ;;
        --function_name) FUNCTION_NAME="$2"; shift 2 ;;
        --env_vars_file) ENV_VARS_FILE="$2"; shift 2 ;;
        --requirements_file) REQUIREMENTS_FILE="$2"; shift 2 ;;
        --requirements) REQUIREMENTS="$2"; shift 2 ;;
        --workspace_name) WORKSPACE_NAME="$2"; shift 2 ;;
        --output_archive) OUTPUT_ARCHIVE="$2"; shift 2 ;;
        -n|--dry-run) DRY_RUN=1; shift 1 ;;
        -h|--help)
            echo "  This file is not meant to be used directly."
            echo "  It is used to generate CF shim and deployment script from Bazel zip output."
            echo "  Usage:"
            echo ""  
            echo "   $(basename $0) \\"
            echo "           [--src_zip_path <path>] \\"
            echo "           [--module_name <name>] \\"
            echo "           [--function_name <name>] \\"
            echo "           [--env_vars_file <path>] \\"
            echo "           [--requirements_file <path>] \\"
            echo "           [--requirements <requirements>] \\"
            echo "           [--workspace_name <name>] \\"
            echo "           [--output_archive <path>] \\"
            echo "           [-h|--help]    - display help \\ "
            echo "           [-n|--dry-run] - do not excute commands \\ "
            exit 0
            ;;
        *)
            echo "Unknown params."
            echo "Pass --help for more info."
            exit 3
            ;;
    esac
done
output_path=$(echo $OUTPUT_ARCHIVE | cut -d '.' -f1)

output_real_path=$output_path/runfiles/$WORKSPACE_NAME

mkdir -p $output_real_path
unzip -o $SRC_ZIP_PATH "runfiles/$WORKSPACE_NAME/**" -d $output_path > /dev/null

if test -n "$REQUIREMENTS_FILE"; then
    cat $REQUIREMENTS_FILE >> $output_real_path/requirements.txt
fi
if test -n "$REQUIREMENTS"; then
    echo $REQUIREMENTS >> $output_real_path/requirements.txt
fi

if test -n "$ENV_VARS_FILE"; then
    cat $ENV_VARS_FILE >> $output_real_path/.env.yaml
fi
echo "from $MODULE_NAME import $FUNCTION_NAME" > $output_real_path/main.py

pushd $output_real_path
zip -r $temp_archive_name .> /dev/null
popd

mv "$output_real_path/$temp_archive_name" $OUTPUT_ARCHIVE

